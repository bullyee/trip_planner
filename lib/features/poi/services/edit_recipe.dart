import 'dart:math' as math;
import 'dart:typed_data';

import '../../camera/services/reinhard_match_service.dart';
import 'brightness_service.dart';
import 'sharpness_service.dart';

/// A decoded image: four bytes a pixel, R G B A, rows packed.
class RgbaImage {
  final Uint8List pixels;
  final int width;
  final int height;

  const RgbaImage(this.pixels, this.width, this.height);
}

/// One editor tool applied to the photo, as data — what [renderEdits]
/// replays at full resolution.
class EditStep {
  /// `match`, `brightness` or `sharpness`.
  final String tool;

  /// The tool's slider value: Match Color strength (0..1), the brightness
  /// offset (-0.5..0.5), or the sharpness amount (0..1).
  final double amount;

  /// Match Color only: the reference image it matched against.
  final String? referencePath;

  const EditStep(this.tool, this.amount, {this.referencePath});

  /// Whether the step leaves the photo as it is, so the render skips it.
  bool get isNoOp => switch (tool) {
    'match' => referencePath == null || amount <= 0.001,
    'brightness' || 'sharpness' => amount == 0,
    _ => true,
  };
}

/// Everything the editor did to a photo: its tools in order, then the
/// mirror, the rotation, the straightening and the crop. Save hands it to
/// [renderEdits], which applies it to the full-resolution photo in one pass
/// — one decode and one encode in all, where each step used to decode and
/// re-encode a full-size JPEG.
class EditRecipe {
  final List<EditStep> steps;

  /// Mirror the photo left to right, before turning it.
  final bool mirror;

  /// Clockwise quarter-turns, as in `RotatedBox(quarterTurns:)`.
  final int quarters;

  /// Straightening after the quarter-turns, in degrees clockwise. The photo
  /// is zoomed in to the largest rectangle of its own shape that it still
  /// covers ([straightenScale]), so it has no empty corners.
  final double angle;

  /// Normalised (0..1) crop — left, top, width, height — over the photo
  /// after the rotation and straightening, or null for the whole frame.
  final List<double>? crop;

  const EditRecipe({
    this.steps = const [],
    this.mirror = false,
    this.quarters = 0,
    this.angle = 0,
    this.crop,
  });

  /// True when saving it would just copy the photo.
  bool get isEmpty =>
      steps.every((s) => s.isNoOp) &&
      !mirror &&
      quarters % 4 == 0 &&
      angle == 0 &&
      crop == null;
}

/// Sendable bundle for [renderEdits].
class RenderEditsArgs {
  final RgbaImage photo;
  final EditRecipe recipe;

  /// The encoded reference of each Match Color step, by index into
  /// `recipe.steps`; null for the other steps.
  final List<Uint8List?> references;

  const RenderEditsArgs(this.photo, this.recipe, this.references);
}

/// Applies a recipe to the full-resolution photo, for a `compute()` worker:
/// each tool in turn on the raw pixels (in place), then the geometry
/// ([applyGeometry]). Decoding before and encoding after happen once each,
/// outside.
Future<RgbaImage> renderEdits(RenderEditsArgs args) async {
  final photo = args.photo;
  final steps = args.recipe.steps;
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    if (step.isNoOp) continue;
    switch (step.tool) {
      case 'match':
        final reference = args.references[i];
        if (reference == null) continue;
        await matchColorPixels(
          photo.pixels,
          photo.width,
          photo.height,
          4,
          reference,
          strength: step.amount,
        );
      case 'brightness':
        brightenPixels(photo.pixels, 4, step.amount);
      case 'sharpness':
        sharpenPixels(photo.pixels, photo.width, photo.height, 4, step.amount);
    }
  }
  final recipe = args.recipe;
  return applyGeometry(
    photo,
    mirror: recipe.mirror,
    quarters: recipe.quarters,
    angle: recipe.angle,
    crop: recipe.crop,
  );
}

/// Mirrors, turns, straightens and crops [image], in that order — the
/// geometry of an [EditRecipe]. Without straightening it's one exact copy
/// ([rotateAndCrop]); with it, the turned photo is resampled once
/// ([straightenAndCrop]).
RgbaImage applyGeometry(
  RgbaImage image, {
  bool mirror = false,
  int quarters = 0,
  double angle = 0,
  List<double>? crop,
}) {
  if (angle == 0) return rotateAndCrop(image, quarters, crop, mirror: mirror);
  return straightenAndCrop(
    rotateAndCrop(image, quarters, null, mirror: mirror),
    angle,
    crop,
  );
}

/// Mirrors [image] left to right when [mirror] is set, rotates it by
/// [quarters] clockwise quarter-turns, then crops it to [crop] (normalised
/// left, top, width, height over the rotated image), in one copy. The same
/// pixels as package:image's `flipHorizontal` + `copyRotate` + `copyCrop`,
/// with the crop clamped the same way `transformJpeg` does.
RgbaImage rotateAndCrop(
  RgbaImage image,
  int quarters,
  List<double>? crop, {
  bool mirror = false,
}) {
  final turns = quarters % 4;
  if (turns == 0 && crop == null && !mirror) return image;
  final w = image.width, h = image.height;
  final rw = turns.isOdd ? h : w;
  final rh = turns.isOdd ? w : h;
  final (x0, y0, cw, ch) = _cropBox(crop, rw, rh);

  final src = _words(image);
  final out = Uint32List(cw * ch);

  // Index into src of rotated pixel (rx, ry). It's linear in rx and ry, so
  // the loop below steps through it instead of calling this per pixel.
  int indexOf(int rx, int ry) {
    var (px, py) = switch (turns) {
      0 => (rx, ry),
      1 => (ry, h - 1 - rx),
      2 => (w - 1 - rx, h - 1 - ry),
      _ => (w - 1 - ry, rx),
    };
    if (mirror) px = w - 1 - px;
    return py * w + px;
  }

  final origin = indexOf(x0, y0);
  final stepX = indexOf(x0 + 1, y0) - origin;
  final stepY = indexOf(x0, y0 + 1) - origin;
  for (var oy = 0; oy < ch; oy++) {
    var s = origin + oy * stepY;
    final o = oy * cw;
    for (var ox = 0; ox < cw; ox++) {
      out[o + ox] = src[s];
      s += stepX;
    }
  }
  return RgbaImage(out.buffer.asUint8List(), cw, ch);
}

/// The fraction of its size a [width]×[height] photo keeps when it's
/// straightened by [degrees]: the largest rectangle of the photo's shape
/// that fits inside the turned photo. The editor zooms in by the inverse,
/// so the straightened photo fills its frame with no empty corners.
double straightenScale(double width, double height, double degrees) {
  final t = degrees.abs() * math.pi / 180;
  final c = math.cos(t), s = math.sin(t);
  return math.min(
    width / (width * c + height * s),
    height / (width * s + height * c),
  );
}

/// Straightens [image]: turns it [degrees] clockwise about its centre and
/// keeps the largest rectangle of its shape that it still covers
/// ([straightenScale]), at [image]'s own pixel size, then crops that to
/// [crop] (normalised over it). Each output pixel is sampled once,
/// bilinearly.
RgbaImage straightenAndCrop(
  RgbaImage image,
  double degrees,
  List<double>? crop,
) {
  final w = image.width, h = image.height;
  final k = straightenScale(w.toDouble(), h.toDouble(), degrees);
  // The straightened frame, in whole pixels.
  final fw = math.max(1, (k * w).round());
  final fh = math.max(1, (k * h).round());
  final (x0, y0, cw, ch) = _cropBox(crop, fw, fh);

  final src = _words(image);
  final out = Uint32List(cw * ch);
  final t = degrees * math.pi / 180;
  final cos = math.cos(t), sin = math.sin(t);
  // Image pixels per frame pixel, so the frame spans exactly k·w × k·h.
  final sx = k * w / fw, sy = k * h / fh;
  for (var oy = 0; oy < ch; oy++) {
    // A pixel centre relative to the frame's centre, turned back by
    // -degrees into [image]'s pixel grid.
    final v = (y0 + oy + 0.5) * sy - k * h / 2;
    final o = oy * cw;
    for (var ox = 0; ox < cw; ox++) {
      final u = (x0 + ox + 0.5) * sx - k * w / 2;
      out[o + ox] = _bilinear(
        src,
        w,
        h,
        u * cos + v * sin + w / 2 - 0.5,
        -u * sin + v * cos + h / 2 - 0.5,
      );
    }
  }
  return RgbaImage(out.buffer.asUint8List(), cw, ch);
}

/// The colour at (x, y) on [src]'s grid of pixel centres, each channel
/// interpolated between the four nearest pixels; edges are clamped.
int _bilinear(Uint32List src, int w, int h, double x, double y) {
  final xf = x.floor(), yf = y.floor();
  final ax = x - xf, ay = y - yf;
  final x1 = xf.clamp(0, w - 1), x2 = (xf + 1).clamp(0, w - 1);
  final y1 = yf.clamp(0, h - 1), y2 = (yf + 1).clamp(0, h - 1);
  final p00 = src[y1 * w + x1], p10 = src[y1 * w + x2];
  final p01 = src[y2 * w + x1], p11 = src[y2 * w + x2];
  var result = 0;
  for (var shift = 0; shift < 32; shift += 8) {
    final c00 = (p00 >> shift) & 0xff, c10 = (p10 >> shift) & 0xff;
    final c01 = (p01 >> shift) & 0xff, c11 = (p11 >> shift) & 0xff;
    final top = c00 + (c10 - c00) * ax;
    final bottom = c01 + (c11 - c01) * ax;
    result |= (top + (bottom - top) * ay).round() << shift;
  }
  return result;
}

/// [crop] (normalised left, top, width, height) in whole pixels of a
/// [width]×[height] image — x, y, width, height — clamped to stay inside.
(int, int, int, int) _cropBox(List<double>? crop, int width, int height) {
  if (crop == null) return (0, 0, width, height);
  final x = (crop[0] * width).round().clamp(0, width - 1);
  final y = (crop[1] * height).round().clamp(0, height - 1);
  return (
    x,
    y,
    (crop[2] * width).round().clamp(1, width - x),
    (crop[3] * height).round().clamp(1, height - y),
  );
}

/// [image]'s pixels as 32-bit words; a view needs a 4-byte-aligned offset.
Uint32List _words(RgbaImage image) {
  final bytes = image.pixels.offsetInBytes % 4 == 0
      ? image.pixels
      : Uint8List.fromList(image.pixels);
  return bytes.buffer.asUint32List(
    bytes.offsetInBytes,
    image.width * image.height,
  );
}
