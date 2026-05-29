import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'color_match_service.dart' show MatchArgs;

/// 16×16 grid was the sweet spot in dev — large enough that each patch
/// gets ~3 000+ pixels on a 1080p shot (stable histogram), small enough
/// that the bilinear blend has fine-grained spatial response.
const int _patchGridSize = 16;

/// Patch-based brightness match.
///
/// Same hue-preserving idea as the global `histogramMatchLuminance`
/// (luminance histogram → CDF → 256-entry LUT → scale RGB equally) but
/// applied per patch. The captured image is divided into a 16×16 grid;
/// every patch builds its own LUT against the same-position patch in
/// the reference. At apply time each pixel samples four surrounding
/// patch LUTs and bilinearly blends the result, so spatially distinct
/// regions (sky vs. shadow, foreground vs. background) get their own
/// tonal mapping without showing seams between patches.
///
/// Cost on a 12 MP shot is ~5-8 s in an isolate — slower than the
/// global pass but handles the "天空亮、地面暗" / "different areas,
/// different brightness" case the global one ignores.
Future<Uint8List> patchMatchBrightness(MatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  // Make the reference the same dimensions as the captured shot so the
  // patch grid aligns directly — no need to do feature matching when the
  // user is intentionally mirroring the anime camera framing.
  final ref = (reference.width == captured.width &&
          reference.height == captured.height)
      ? reference
      : img.copyResize(
          reference,
          width: captured.width,
          height: captured.height,
        );

  final patchW = captured.width / _patchGridSize;
  final patchH = captured.height / _patchGridSize;

  // Build all 256 (16×16) LUTs up front.
  final luts = List<List<int>>.generate(
    _patchGridSize * _patchGridSize,
    (idx) {
      final i = idx ~/ _patchGridSize;
      final j = idx % _patchGridSize;
      final x0 = (j * patchW).floor();
      final y0 = (i * patchH).floor();
      final x1 =
          math.min(((j + 1) * patchW).ceil(), captured.width);
      final y1 =
          math.min(((i + 1) * patchH).ceil(), captured.height);

      final capH = _patchLumaHist(captured, x0, y0, x1, y1);
      final refH = _patchLumaHist(ref, x0, y0, x1, y1);
      return _matchLut(_cdf(capH), _cdf(refH));
    },
    growable: false,
  );

  for (var y = 0; y < captured.height; y++) {
    // Continuous patch-grid coordinate: 0 means the centre of patch row 0,
    // 1 means the centre of patch row 1, etc. Floor gives the patch row
    // whose centre is at or above the pixel.
    final gy = y / patchH - 0.5;
    final i0 = gy.floor().clamp(0, _patchGridSize - 1);
    final i1 = (i0 + 1).clamp(0, _patchGridSize - 1);
    final wy = (gy - i0).clamp(0.0, 1.0);

    for (var x = 0; x < captured.width; x++) {
      final gx = x / patchW - 0.5;
      final j0 = gx.floor().clamp(0, _patchGridSize - 1);
      final j1 = (j0 + 1).clamp(0, _patchGridSize - 1);
      final wx = (gx - j0).clamp(0.0, 1.0);

      final px = captured.getPixel(x, y);
      final r = px.r.toDouble();
      final g = px.g.toDouble();
      final b = px.b.toDouble();
      final oldLuma = 0.299 * r + 0.587 * g + 0.114 * b;
      if (oldLuma < 1.0) continue; // leave near-black pixels alone

      final idx = oldLuma.round().clamp(0, 255);
      final lutTL = luts[i0 * _patchGridSize + j0][idx].toDouble();
      final lutTR = luts[i0 * _patchGridSize + j1][idx].toDouble();
      final lutBL = luts[i1 * _patchGridSize + j0][idx].toDouble();
      final lutBR = luts[i1 * _patchGridSize + j1][idx].toDouble();

      final newLuma = (1 - wx) * (1 - wy) * lutTL +
          wx * (1 - wy) * lutTR +
          (1 - wx) * wy * lutBL +
          wx * wy * lutBR;

      final scale = newLuma / oldLuma;
      px.r = (r * scale).clamp(0, 255);
      px.g = (g * scale).clamp(0, 255);
      px.b = (b * scale).clamp(0, 255);
    }
  }

  return Uint8List.fromList(img.encodeJpg(captured, quality: 90));
}

// ---------------------------------------------------------------------------
//  Local helpers — small enough to duplicate from color_match_service rather
//  than punch holes through that file's private API.
// ---------------------------------------------------------------------------

List<int> _patchLumaHist(img.Image src, int x0, int y0, int x1, int y1) {
  final h = List<int>.filled(256, 0);
  for (var y = y0; y < y1; y++) {
    for (var x = x0; x < x1; x++) {
      final px = src.getPixel(x, y);
      final luma =
          (0.299 * px.r + 0.587 * px.g + 0.114 * px.b).round().clamp(0, 255);
      h[luma]++;
    }
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
