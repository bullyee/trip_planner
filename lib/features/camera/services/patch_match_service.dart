import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'band_runner.dart';
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
/// Hist building scans the full image once via raw byte access (instead
/// of `getPixel`), and the bilinear apply is split across worker isolates
/// — together they bring the 12 MP runtime down from ~6 s to under ~1 s.
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

  final width = captured.width;
  final height = captured.height;
  final capChannels = captured.numChannels;
  final refChannels = ref.numChannels;
  final patchW = width / _patchGridSize;
  final patchH = height / _patchGridSize;

  // Pull raw bytes once for both decoded images; histogram building reads
  // them directly instead of going through `Pixel` accessors.
  final capData = captured.toUint8List();
  final refData = ref.toUint8List();

  final luts = List<List<int>>.generate(
    _patchGridSize * _patchGridSize,
    (idx) {
      final i = idx ~/ _patchGridSize;
      final j = idx % _patchGridSize;
      final x0 = (j * patchW).floor();
      final y0 = (i * patchH).floor();
      final x1 = math.min(((j + 1) * patchW).ceil(), width);
      final y1 = math.min(((i + 1) * patchH).ceil(), height);

      final capH =
          _patchLumaHistBytes(capData, width, capChannels, x0, y0, x1, y1);
      final refH =
          _patchLumaHistBytes(refData, width, refChannels, x0, y0, x1, y1);
      return _matchLut(_cdf(capH), _cdf(refH));
    },
    growable: false,
  );

  return processBandsInParallel(
    captured: captured,
    bandFn: (bytes, ch, w, yOff, bH) => _applyPatchBrightnessBand(
      bytes,
      ch,
      w,
      yOff,
      bH,
      luts,
      patchW,
      patchH,
    ),
  );
}

Uint8List _applyPatchBrightnessBand(
  Uint8List bandBytes,
  int channels,
  int width,
  int yOffset,
  int bandHeight,
  List<List<int>> luts,
  double patchW,
  double patchH,
) {
  final result = Uint8List.fromList(bandBytes);
  final bytesPerRow = width * channels;

  for (var localY = 0; localY < bandHeight; localY++) {
    // Continuous patch-grid coordinate: 0 means the centre of patch row 0,
    // 1 means the centre of patch row 1, etc. Floor gives the patch row
    // whose centre is at or above the pixel.
    final globalY = yOffset + localY;
    final gy = globalY / patchH - 0.5;
    final i0 = gy.floor().clamp(0, _patchGridSize - 1);
    final i1 = (i0 + 1).clamp(0, _patchGridSize - 1);
    final wy = (gy - i0).clamp(0.0, 1.0);

    var off = localY * bytesPerRow;
    for (var x = 0; x < width; x++) {
      final gx = x / patchW - 0.5;
      final j0 = gx.floor().clamp(0, _patchGridSize - 1);
      final j1 = (j0 + 1).clamp(0, _patchGridSize - 1);
      final wx = (gx - j0).clamp(0.0, 1.0);

      final r = result[off].toDouble();
      final g = result[off + 1].toDouble();
      final b = result[off + 2].toDouble();
      final oldLuma = 0.299 * r + 0.587 * g + 0.114 * b;

      if (oldLuma >= 1.0) {
        final lumaIdx = oldLuma.round().clamp(0, 255);
        final lutTL = luts[i0 * _patchGridSize + j0][lumaIdx].toDouble();
        final lutTR = luts[i0 * _patchGridSize + j1][lumaIdx].toDouble();
        final lutBL = luts[i1 * _patchGridSize + j0][lumaIdx].toDouble();
        final lutBR = luts[i1 * _patchGridSize + j1][lumaIdx].toDouble();

        final newLuma = (1 - wx) * (1 - wy) * lutTL +
            wx * (1 - wy) * lutTR +
            (1 - wx) * wy * lutBL +
            wx * wy * lutBR;

        final scale = newLuma / oldLuma;
        result[off] = (r * scale).round().clamp(0, 255);
        result[off + 1] = (g * scale).round().clamp(0, 255);
        result[off + 2] = (b * scale).round().clamp(0, 255);
      }
      off += channels;
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
//  Local helpers — small enough to duplicate from color_match_service rather
//  than punch holes through that file's private API.
// ---------------------------------------------------------------------------

/// Build a 256-bin luminance histogram over the rectangle `[x0..x1) × [y0..y1)`
/// of a flat RGB(A) byte buffer. Direct buffer access is 5–10× faster than
/// `img.Image.getPixel(x, y)`, which matters here because this is called
/// 256 times per match (once per patch).
List<int> _patchLumaHistBytes(
  Uint8List data,
  int width,
  int channels,
  int x0,
  int y0,
  int x1,
  int y1,
) {
  final h = List<int>.filled(256, 0);
  final bytesPerRow = width * channels;
  for (var y = y0; y < y1; y++) {
    var off = y * bytesPerRow + x0 * channels;
    for (var x = x0; x < x1; x++) {
      final r = data[off];
      final g = data[off + 1];
      final b = data[off + 2];
      final luma =
          (0.299 * r + 0.587 * g + 0.114 * b).round().clamp(0, 255);
      h[luma]++;
      off += channels;
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
