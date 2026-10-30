import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'band_runner.dart';

/// Sendable bundle of input bytes for the colour-match `compute()` helpers.
/// Holds primitives only so closures inside instance methods can't leak the
/// surrounding widget state across the isolate boundary.
class MatchArgs {
  final Uint8List capturedBytes;
  final Uint8List referenceBytes;

  const MatchArgs({
    required this.capturedBytes,
    required this.referenceBytes,
  });
}

/// Sendable bundle for the lerp helper. JPEG-encoded buffers in, JPEG out.
class LerpArgs {
  final Uint8List jpegA;
  final Uint8List jpegB;
  final double strength;

  const LerpArgs({
    required this.jpegA,
    required this.jpegB,
    required this.strength,
  });
}

/// Reinhard, Adhikhmin, Gooch & Shirley (2001) "Color Transfer between
/// Images" applied as the "Match Color" filter.
///
/// Both images are converted to LAB. Mean + stddev for L, a, b are
/// computed on 256 px thumbnails. For every captured pixel:
///
///     new_L = (L - cap.meanL) * (ref.stdL / cap.stdL) + ref.meanL
///     new_a = (a - cap.meanA) * (ref.stdA / cap.stdA) + ref.meanA
///     new_b = (b - cap.meanB) * (ref.stdB / cap.stdB) + ref.meanB
///
/// Closed form, no iteration — the result is the "full strength" match.
/// The editor lerps this output against the original capture with a
/// strength slider, so this function does not itself need to know about
/// strength: 100 % match is the only thing it produces.
///
/// Each per-channel scale is clamped to [0.5, 2.0] so a monochrome or
/// very flat reference can't blow up the captured image's chroma.
Future<Uint8List> reinhardMatch(MatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  final capStats = labStatsOfImage(captured);
  final refStats = labStatsOfImage(reference);

  return processBandsInParallel(
    captured: captured,
    bandFn: (bytes, ch, _, _, _) =>
        _applyReinhardBand(bytes, ch, capStats, refStats, 1),
  );
}

/// [reinhardMatch] on raw [pixels] — [width] × [height], [channels] bytes a
/// pixel with R G B first, rows packed — in place, for the full-resolution
/// save render. [strength] blends the match with the original the way the
/// editor's slider does (1 = the full match), in the same pass instead of
/// [lerpJpegs]' second decode / encode.
Future<void> matchColorPixels(
  Uint8List pixels,
  int width,
  int height,
  int channels,
  Uint8List referenceBytes, {
  double strength = 1,
}) async {
  final reference = img.decodeImage(referenceBytes);
  if (reference == null) return;
  final capStats = labStatsOfPixels(pixels, width, height, channels);
  final refStats = labStatsOfImage(reference);
  final t = strength.clamp(0.0, 1.0);
  await processPixelBands(
    pixels: pixels,
    width: width,
    height: height,
    channels: channels,
    bandFn: (bytes, ch, _, _, _) =>
        _applyReinhardBand(bytes, ch, capStats, refStats, t),
  );
}

/// Changes [bandBytes] in place: each band runs in its own isolate on its
/// own copy.
Uint8List _applyReinhardBand(
  Uint8List bandBytes,
  int channels,
  LabStats cap,
  LabStats ref,
  double strength,
) {
  final result = bandBytes;
  final n = result.length;

  final scaleL = (ref.stdL / cap.stdL).clamp(0.5, 2.0);
  final scaleA = (ref.stdA / cap.stdA).clamp(0.5, 2.0);
  final scaleB = (ref.stdB / cap.stdB).clamp(0.5, 2.0);
  final blend = strength < 0.999;
  final keep = 1 - strength;

  for (var i = 0; i < n; i += channels) {
    final r0 = result[i], g0 = result[i + 1], b0 = result[i + 2];
    final lab = _rgbToLab(r0, g0, b0);
    final newL = (lab.l - cap.meanL) * scaleL + ref.meanL;
    final newA = (lab.a - cap.meanA) * scaleA + ref.meanA;
    final newB = (lab.b - cap.meanB) * scaleB + ref.meanB;
    final rgb = _labToRgb(newL, newA, newB);
    final r = rgb.r.round().clamp(0, 255);
    final g = rgb.g.round().clamp(0, 255);
    final b = rgb.b.round().clamp(0, 255);
    if (blend) {
      // Same blend as lerpJpegs, minus its JPEG round trip.
      result[i] = (r0 * keep + r * strength).round().clamp(0, 255);
      result[i + 1] = (g0 * keep + g * strength).round().clamp(0, 255);
      result[i + 2] = (b0 * keep + b * strength).round().clamp(0, 255);
    } else {
      result[i] = r;
      result[i + 1] = g;
      result[i + 2] = b;
    }
  }
  return result;
}

/// Per-byte linear blend between two same-sized JPEG buffers, re-encoded
/// as JPEG. Used by the editor's Confirm to flatten the Match Color
/// strength slider (which renders as a Flutter Stack at preview time)
/// into the step's preview bytes. Save blends inside [matchColorPixels].
///
/// Both buffers must decode to the same width × height × channel layout
/// — the function is only called from inside the editor after Reinhard
/// produced its match against this exact captured image, so that holds.
Future<Uint8List> lerpJpegs(LerpArgs args) async {
  final a = img.decodeImage(args.jpegA);
  final b = img.decodeImage(args.jpegB);
  if (a == null || b == null) return args.jpegA;

  final aData = a.toUint8List();
  final bData = b.toUint8List();
  if (aData.length != bData.length) return args.jpegA;

  final t = args.strength.clamp(0.0, 1.0);
  final invT = 1 - t;
  final out = Uint8List(aData.length);
  for (var i = 0; i < aData.length; i++) {
    out[i] = (aData[i] * invT + bData[i] * t).round().clamp(0, 255);
  }

  final newImage = img.Image.fromBytes(
    width: a.width,
    height: a.height,
    bytes: out.buffer,
    numChannels: a.numChannels,
  );
  return Uint8List.fromList(img.encodeJpg(newImage, quality: 90));
}

// ---------------------------------------------------------------------------
//  LAB stats + conversion — duplicated from color_match_service to keep
//  this file self-contained. Reach for a shared helper if a third LAB
//  consumer shows up.
// ---------------------------------------------------------------------------

const _thumbLongEdge = 256;

img.Image _thumb(img.Image src) {
  const longEdge = _thumbLongEdge;
  if (src.width <= longEdge && src.height <= longEdge) return src;
  return src.width >= src.height
      ? img.copyResize(src, width: longEdge)
      : img.copyResize(src, height: longEdge);
}

/// Mean and standard deviation of an image's L, a and b channels.
class LabStats {
  final double meanL, meanA, meanB;
  final double stdL, stdA, stdB;
  const LabStats({
    required this.meanL,
    required this.meanA,
    required this.meanB,
    required this.stdL,
    required this.stdA,
    required this.stdB,
  });
}

/// Lab stats of [src], taken on a 256 px thumbnail of it.
LabStats labStatsOfImage(img.Image src) {
  final acc = _LabAccumulator();
  for (final px in _thumb(src)) {
    acc.add(px.r, px.g, px.b);
  }
  return acc.stats;
}

/// [labStatsOfImage] for raw pixels ([channels] bytes a pixel, R G B
/// first), without building an `img.Image`: it samples the same pixels as
/// `copyResize`'s default nearest-neighbour resize, in the same order, so
/// the stats come out identical.
LabStats labStatsOfPixels(
  Uint8List pixels,
  int width,
  int height,
  int channels,
) {
  var tw = width, th = height;
  if (width > _thumbLongEdge || height > _thumbLongEdge) {
    if (width >= height) {
      tw = _thumbLongEdge;
      th = (tw * (height / width)).round();
    } else {
      th = _thumbLongEdge;
      tw = (th * (width / height)).round();
    }
  }
  final acc = _LabAccumulator();
  for (var y = 0; y < th; y++) {
    final row = ((y * height) ~/ th) * width;
    for (var x = 0; x < tw; x++) {
      final i = (row + (x * width) ~/ tw) * channels;
      acc.add(pixels[i], pixels[i + 1], pixels[i + 2]);
    }
  }
  return acc.stats;
}

class _LabAccumulator {
  var sumL = 0.0, sumA = 0.0, sumB = 0.0;
  var sqL = 0.0, sqA = 0.0, sqB = 0.0;
  var count = 0;

  void add(num r, num g, num b) {
    final lab = _rgbToLab(r, g, b);
    sumL += lab.l;
    sumA += lab.a;
    sumB += lab.b;
    sqL += lab.l * lab.l;
    sqA += lab.a * lab.a;
    sqB += lab.b * lab.b;
    count++;
  }

  LabStats get stats {
    if (count == 0) {
      return const LabStats(
        meanL: 0, meanA: 0, meanB: 0,
        stdL: 1, stdA: 1, stdB: 1,
      );
    }
    final meanL = sumL / count;
    final meanA = sumA / count;
    final meanB = sumB / count;
    final varL = math.max(0.0, sqL / count - meanL * meanL);
    final varA = math.max(0.0, sqA / count - meanA * meanA);
    final varB = math.max(0.0, sqB / count - meanB * meanB);
    return LabStats(
      meanL: meanL,
      meanA: meanA,
      meanB: meanB,
      stdL: math.max(1e-6, math.sqrt(varL)),
      stdA: math.max(1e-6, math.sqrt(varA)),
      stdB: math.max(1e-6, math.sqrt(varB)),
    );
  }
}

class _LabPixel {
  final double l, a, b;
  const _LabPixel(this.l, this.a, this.b);
}

class _RgbPixel {
  final double r, g, b;
  const _RgbPixel(this.r, this.g, this.b);
}

double _srgbToLinear(double v8) {
  final v = v8 / 255.0;
  return v <= 0.04045
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _linearToSrgb(double v) {
  final r = v <= 0.0031308
      ? 12.92 * v
      : 1.055 * math.pow(v, 1.0 / 2.4).toDouble() - 0.055;
  return r * 255.0;
}

double _labF(double t) {
  return t > 0.008856
      ? math.pow(t, 1.0 / 3.0).toDouble()
      : (7.787 * t) + (16.0 / 116.0);
}

double _labFInv(double t) {
  return t > 0.206893 ? t * t * t : (t - 16.0 / 116.0) / 7.787;
}

/// [_srgbToLinear] of every 8-bit value, so the per-pixel loop looks it up
/// instead of calling `pow` three times a pixel.
final _linearOf8Bit = Float64List.fromList([
  for (var v = 0; v < 256; v++) _srgbToLinear(v.toDouble()),
]);

double _toLinear(num v8) => v8 is int && v8 >= 0 && v8 < 256
    ? _linearOf8Bit[v8]
    : _srgbToLinear(v8.toDouble());

_LabPixel _rgbToLab(num r8, num g8, num b8) {
  final lr = _toLinear(r8);
  final lg = _toLinear(g8);
  final lb = _toLinear(b8);

  final x = lr * 0.4124564 + lg * 0.3575761 + lb * 0.1804375;
  final y = lr * 0.2126729 + lg * 0.7151522 + lb * 0.0721750;
  final z = lr * 0.0193339 + lg * 0.1191920 + lb * 0.9503041;

  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  final fx = _labF(x / xn);
  final fy = _labF(y / yn);
  final fz = _labF(z / zn);

  return _LabPixel(
    116.0 * fy - 16.0,
    500.0 * (fx - fy),
    200.0 * (fy - fz),
  );
}

_RgbPixel _labToRgb(double l, double a, double b) {
  final fy = (l + 16.0) / 116.0;
  final fx = a / 500.0 + fy;
  final fz = fy - b / 200.0;

  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  final x = xn * _labFInv(fx);
  final y = yn * _labFInv(fy);
  final z = zn * _labFInv(fz);

  final lr = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
  final lg = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
  final lb = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

  return _RgbPixel(
    _linearToSrgb(lr.clamp(0.0, 1.0)),
    _linearToSrgb(lg.clamp(0.0, 1.0)),
    _linearToSrgb(lb.clamp(0.0, 1.0)),
  );
}
