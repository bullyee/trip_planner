import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'edit_recipe.dart';

/// Long edge of the editor's downscaled preview buffer. Most phone
/// screens are ~1080 px wide, so 1024 px stays visually crisp under
/// `BoxFit.contain` while keeping every per-pixel compute path well
/// under a second.
const int editingPreviewMaxDim = 1024;

/// Decode [sourceBytes], bake EXIF orientation into the pixels, then
/// downscale to [editingPreviewMaxDim] on the long edge when larger and
/// re-encode JPEG.
///
/// The result is always re-encoded with upright pixels and no rotation
/// tag, even when the source is already small enough, so the size the
/// editor reads from it (for the crop tool's aspect ratio) matches what
/// the user sees. `img.decodeImage` already applies EXIF orientation for
/// JPEG; [img.bakeOrientation] covers formats whose decoder doesn't.
///
/// Runs once when the editor mounts — every subsequent preview compute
/// (Match Color, Sharpness prepare, etc.) reads this output instead of
/// decoding the source again, so a 12 MP JPEG only pays its ~300-500 ms
/// decode cost a single time per editing session.
Future<Uint8List> downscaleForEditing(Uint8List sourceBytes) async {
  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) return sourceBytes;
  final image = img.bakeOrientation(decoded);
  final long = math.max(image.width, image.height);
  final prepared = long <= editingPreviewMaxDim
      ? image
      : img.copyResize(
          image,
          width: (image.width * (editingPreviewMaxDim / long)).round(),
          height: (image.height * (editingPreviewMaxDim / long)).round(),
        );
  return Uint8List.fromList(img.encodeJpg(prepared, quality: 90));
}

/// Sendable bundle for [transformJpeg]: the editor's mirror, rotation,
/// straightening and crop, baked into a JPEG in one decode / encode pass.
class TransformArgs {
  final Uint8List bytes;

  /// Mirror left to right, before the rotation.
  final bool mirror;

  /// Clockwise quarter-turns to apply. Matches Flutter's
  /// `RotatedBox(quarterTurns:)` direction so the saved file rotates the
  /// same way the editor preview showed it.
  final int quarters;

  /// Straightening after the quarter-turns, in degrees clockwise
  /// (`EditRecipe.angle`).
  final double angle;

  /// Optional crop as a normalised (0..1) rect — left, top, width, height —
  /// over the image *after* the rotation and straightening, i.e. the
  /// orientation the editor showed while the user drew it.
  final List<double>? crop;

  const TransformArgs(
    this.bytes, {
    this.mirror = false,
    this.quarters = 0,
    this.angle = 0,
    this.crop,
  });
}

/// Mirror, rotate, straighten and crop a JPEG buffer — the same pixels as
/// the full-resolution render's [applyGeometry] — and re-encode it at
/// quality 95. Returns the input untouched when there's nothing to do.
/// Decoding applies the source's EXIF orientation first, so all of it is
/// relative to the upright image the user saw.
///
/// One pass instead of one per step: a full-res JPEG decode + encode takes
/// seconds on a phone.
Future<Uint8List> transformJpeg(TransformArgs args) async {
  if (!args.mirror &&
      args.quarters % 4 == 0 &&
      args.angle == 0 &&
      args.crop == null) {
    return args.bytes;
  }
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;
  final rgba = decoded.convert(numChannels: 4, alpha: 255);
  final out = applyGeometry(
    RgbaImage(rgba.toUint8List(), rgba.width, rgba.height),
    mirror: args.mirror,
    quarters: args.quarters,
    angle: args.angle,
    crop: args.crop,
  );
  final image = img.Image.fromBytes(
    width: out.width,
    height: out.height,
    bytes: out.pixels.buffer,
    bytesOffset: out.pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

/// Sendable bundle for [encodeRgbaJpeg].
class RgbaJpegArgs {
  /// Straight RGBA pixels, row by row, e.g. `ui.Image.toByteData` in
  /// `rawRgba` for an opaque image.
  final Uint8List rgba;
  final int width;
  final int height;
  final int quality;

  const RgbaJpegArgs(this.rgba, this.width, this.height, {this.quality = 92});
}

/// Encode raw RGBA pixels as JPEG. Lets Compose go straight from its
/// composited `ui.Image` to the saved JPEG, instead of encoding a PNG and
/// decoding it again.
Future<Uint8List> encodeRgbaJpeg(RgbaJpegArgs args) async {
  final image = img.Image.fromBytes(
    width: args.width,
    height: args.height,
    bytes: args.rgba.buffer,
    bytesOffset: args.rgba.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return Uint8List.fromList(img.encodeJpg(image, quality: args.quality));
}
