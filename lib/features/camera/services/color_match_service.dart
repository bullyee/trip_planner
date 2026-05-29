import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

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

// ---------------------------------------------------------------------------
//  Public entry points
// ---------------------------------------------------------------------------

/// RGB per-channel histogram matching.
///
/// For each of R, G, B independently: build a 256-bin histogram on a 128px
/// thumbnail of both images, derive each side's CDF, and build a 256-entry
/// LUT that maps captured rank-X% to reference rank-X%. Apply the LUTs to
/// every pixel in the full-size captured image.
///
/// Best at white-balance / colour-cast correction — a yellow-tinted shot
/// matched against a cool reference comes out neutral. May nudge hue
/// slightly because channels move independently.
Future<Uint8List> histogramMatchRgb(MatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  final capThumb = _thumb(captured);
  final refThumb = _thumb(reference);

  final lutR = _matchLut(
    _cdf(_histChannel(capThumb, _channelR)),
    _cdf(_histChannel(refThumb, _channelR)),
  );
  final lutG = _matchLut(
    _cdf(_histChannel(capThumb, _channelG)),
    _cdf(_histChannel(refThumb, _channelG)),
  );
  final lutB = _matchLut(
    _cdf(_histChannel(capThumb, _channelB)),
    _cdf(_histChannel(refThumb, _channelB)),
  );

  for (final px in captured) {
    px.r = lutR[px.r.toInt().clamp(0, 255)].toDouble();
    px.g = lutG[px.g.toInt().clamp(0, 255)].toDouble();
    px.b = lutB[px.b.toInt().clamp(0, 255)].toDouble();
  }

  return Uint8List.fromList(img.encodeJpg(captured, quality: 90));
}

/// Luminance-only histogram matching.
///
/// Computes a luminance histogram (BT.601 weighted) on a 128px thumbnail
/// for each image, builds a 256-entry LUT mapping captured luminance
/// ranks to reference luminance ranks, and applies the LUT to the full
/// captured image by scaling RGB equally per pixel — every pixel's hue
/// is preserved exactly because R / G / B share the same multiplier.
///
/// Quickest of the three filters and the safest when the captured shot
/// already has the colour mood you want; ideal for matching brightness
/// distribution (highlights / midtones / shadows) without touching
/// colour temperature or saturation. The RGB and LAB filters will move
/// hue or chroma; this one will not.
Future<Uint8List> histogramMatchLuminance(MatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  final lumaLut = _matchLut(
    _cdf(_histLuminance(_thumb(captured))),
    _cdf(_histLuminance(_thumb(reference))),
  );

  for (final px in captured) {
    final r = px.r.toDouble();
    final g = px.g.toDouble();
    final b = px.b.toDouble();
    // BT.601 luminance — same weights as the histogram side, so a pixel
    // ends up mapped onto its own original histogram bin and the LUT
    // round-trip is meaningful.
    final oldLuma = 0.299 * r + 0.587 * g + 0.114 * b;
    if (oldLuma < 1.0) continue; // near-black pixels stay where they are
    final newLuma = lumaLut[oldLuma.round().clamp(0, 255)].toDouble();
    final scale = newLuma / oldLuma;
    px.r = (r * scale).clamp(0, 255);
    px.g = (g * scale).clamp(0, 255);
    px.b = (b * scale).clamp(0, 255);
  }

  return Uint8List.fromList(img.encodeJpg(captured, quality: 90));
}

List<int> _histLuminance(img.Image src) {
  final h = List<int>.filled(256, 0);
  for (final px in src) {
    final luma =
        (0.299 * px.r + 0.587 * px.g + 0.114 * px.b).round().clamp(0, 255);
    h[luma]++;
  }
  return h;
}

/// LAB colour-space matching.
///
/// Converts both images to LAB. Matches the L (luminance) channel via
/// histogram-based CDF, then matches the a (red-green) and b (blue-yellow)
/// channels via mean + stddev scale-and-shift — chroma channels don't need
/// the heavier histogram treatment and a linear adjustment keeps colour
/// drift predictable. Converts back to sRGB.
///
/// Slower than the RGB pass (~3-5x because of the per-pixel sRGB ↔ XYZ ↔
/// LAB conversions) but separates brightness from colour so the L
/// adjustment doesn't pull hue, and the a/b adjustment doesn't crush
/// shadows. Better choice when the reference image has strong colour
/// grading (sunset, night scene) and you want to preserve detail.
Future<Uint8List> histogramMatchLab(MatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  final capStats = _labStats(_thumb(captured));
  final refStats = _labStats(_thumb(reference));

  final lLut = _matchLut(_cdf(capStats.lHist), _cdf(refStats.lHist));

  // a / b: linear scale + shift to push captured mean+stddev toward
  // reference's, clamped so a saturated reference can't blow chroma out.
  final aScale =
      (refStats.aStdDev / math.max(capStats.aStdDev, 1.0)).clamp(0.7, 1.3);
  final aShift = refStats.aMean - capStats.aMean * aScale;
  final bScale =
      (refStats.bStdDev / math.max(capStats.bStdDev, 1.0)).clamp(0.7, 1.3);
  final bShift = refStats.bMean - capStats.bMean * bScale;

  for (final px in captured) {
    final lab = _rgbToLab(px.r, px.g, px.b);
    final lBin = ((lab.l / 100.0) * 255).round().clamp(0, 255);
    final newL = (lLut[lBin] / 255.0) * 100.0;
    final newA = lab.a * aScale + aShift;
    final newB = lab.b * bScale + bShift;
    final rgb = _labToRgb(newL, newA, newB);
    px.r = rgb.r.clamp(0, 255);
    px.g = rgb.g.clamp(0, 255);
    px.b = rgb.b.clamp(0, 255);
  }

  return Uint8List.fromList(img.encodeJpg(captured, quality: 90));
}

// ---------------------------------------------------------------------------
//  Shared statistics helpers
// ---------------------------------------------------------------------------

img.Image _thumb(img.Image src) {
  const longEdge = 128;
  if (src.width <= longEdge && src.height <= longEdge) return src;
  return src.width >= src.height
      ? img.copyResize(src, width: longEdge)
      : img.copyResize(src, height: longEdge);
}

const int _channelR = 0;
const int _channelG = 1;
const int _channelB = 2;

List<int> _histChannel(img.Image src, int channel) {
  final h = List<int>.filled(256, 0);
  for (final px in src) {
    final v = switch (channel) {
      _channelR => px.r.toInt(),
      _channelG => px.g.toInt(),
      _channelB => px.b.toInt(),
      _ => 0,
    };
    h[v.clamp(0, 255)]++;
  }
  return h;
}

List<double> _cdf(List<int> hist) {
  final total = hist.fold<int>(0, (a, b) => a + b);
  if (total == 0) return List<double>.filled(hist.length, 0);
  final cdf = List<double>.filled(hist.length, 0);
  var running = 0;
  for (var i = 0; i < hist.length; i++) {
    running += hist[i];
    cdf[i] = running / total;
  }
  return cdf;
}

List<int> _matchLut(List<double> srcCdf, List<double> dstCdf) {
  // For each src index i, find smallest dst index j such that
  // dstCdf[j] >= srcCdf[i]. Single forward sweep (both CDFs are monotonic).
  final lut = List<int>.filled(srcCdf.length, 0);
  var dstIdx = 0;
  for (var src = 0; src < srcCdf.length; src++) {
    while (dstIdx < dstCdf.length - 1 && dstCdf[dstIdx] < srcCdf[src]) {
      dstIdx++;
    }
    lut[src] = dstIdx;
  }
  return lut;
}

// ---------------------------------------------------------------------------
//  LAB conversion (D65 reference white, sRGB gamma)
// ---------------------------------------------------------------------------

class _LabPixel {
  final double l;
  final double a;
  final double b;
  const _LabPixel(this.l, this.a, this.b);
}

class _RgbPixel {
  final double r;
  final double g;
  final double b;
  const _RgbPixel(this.r, this.g, this.b);
}

double _srgbToLinear(double v8) {
  final v = v8 / 255.0;
  return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _linearToSrgb(double v) {
  final r = v <= 0.0031308
      ? 12.92 * v
      : 1.055 * math.pow(v, 1.0 / 2.4).toDouble() - 0.055;
  return r * 255.0;
}

double _labF(double t) {
  // t > (6/29)^3 ≈ 0.008856
  return t > 0.008856
      ? math.pow(t, 1.0 / 3.0).toDouble()
      : (7.787 * t) + (16.0 / 116.0);
}

double _labFInv(double t) {
  // t > 6/29
  return t > 0.206893
      ? t * t * t
      : (t - 16.0 / 116.0) / 7.787;
}

_LabPixel _rgbToLab(num r8, num g8, num b8) {
  final lr = _srgbToLinear(r8.toDouble());
  final lg = _srgbToLinear(g8.toDouble());
  final lb = _srgbToLinear(b8.toDouble());

  // Linear sRGB → XYZ (D65)
  final x = lr * 0.4124564 + lg * 0.3575761 + lb * 0.1804375;
  final y = lr * 0.2126729 + lg * 0.7151522 + lb * 0.0721750;
  final z = lr * 0.0193339 + lg * 0.1191920 + lb * 0.9503041;

  // XYZ → LAB (D65)
  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  final fx = _labF(x / xn);
  final fy = _labF(y / yn);
  final fz = _labF(z / zn);

  return _LabPixel(
    116.0 * fy - 16.0, // L: 0..100
    500.0 * (fx - fy), // a: roughly -127..127
    200.0 * (fy - fz), // b: roughly -127..127
  );
}

_RgbPixel _labToRgb(double l, double a, double b) {
  final fy = (l + 16.0) / 116.0;
  final fx = a / 500.0 + fy;
  final fz = fy - b / 200.0;

  // LAB → XYZ
  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  final x = xn * _labFInv(fx);
  final y = yn * _labFInv(fy);
  final z = zn * _labFInv(fz);

  // XYZ → linear sRGB (inverse of the matrix above)
  final lr = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
  final lg = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
  final lb = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

  return _RgbPixel(
    _linearToSrgb(lr.clamp(0.0, 1.0)),
    _linearToSrgb(lg.clamp(0.0, 1.0)),
    _linearToSrgb(lb.clamp(0.0, 1.0)),
  );
}

class _LabStats {
  final List<int> lHist;
  final double aMean;
  final double aStdDev;
  final double bMean;
  final double bStdDev;
  const _LabStats({
    required this.lHist,
    required this.aMean,
    required this.aStdDev,
    required this.bMean,
    required this.bStdDev,
  });
}

_LabStats _labStats(img.Image thumb) {
  final lHist = List<int>.filled(256, 0);
  var aSum = 0.0, aSumSq = 0.0;
  var bSum = 0.0, bSumSq = 0.0;
  var count = 0;

  for (final px in thumb) {
    final lab = _rgbToLab(px.r, px.g, px.b);
    final lBin = ((lab.l / 100.0) * 255).round().clamp(0, 255);
    lHist[lBin]++;
    aSum += lab.a;
    aSumSq += lab.a * lab.a;
    bSum += lab.b;
    bSumSq += lab.b * lab.b;
    count++;
  }

  if (count == 0) {
    return _LabStats(lHist: lHist, aMean: 0, aStdDev: 1, bMean: 0, bStdDev: 1);
  }
  final aMean = aSum / count;
  final bMean = bSum / count;
  final aVar = (aSumSq / count) - (aMean * aMean);
  final bVar = (bSumSq / count) - (bMean * bMean);

  return _LabStats(
    lHist: lHist,
    aMean: aMean,
    aStdDev: aVar > 0 ? math.sqrt(aVar) : 1.0,
    bMean: bMean,
    bStdDev: bVar > 0 ? math.sqrt(bVar) : 1.0,
  );
}
