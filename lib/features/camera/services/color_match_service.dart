import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Sendable bundle of the bytes that `compute(autoMatchBrightness, …)`
/// ships across the isolate boundary. Held as primitive types so nothing
/// from the caller's State / widget tree gets implicitly captured — same
/// pitfall we hit on the vlog `Isolate.run` work.
class AutoMatchArgs {
  final Uint8List capturedBytes;
  final Uint8List referenceBytes;

  const AutoMatchArgs({
    required this.capturedBytes,
    required this.referenceBytes,
  });
}

/// One-shot colour grade: nudges the captured photo's brightness and
/// contrast toward the reference image's. Decode + adjust + encode runs
/// in the worker isolate so the UI thread can keep painting.
///
/// MUST be a top-level function — `compute()` sends a `Function` reference
/// to the new isolate and only top-level / static functions are sendable.
Future<Uint8List> autoMatchBrightness(AutoMatchArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) {
    return args.capturedBytes; // give the user back what they had
  }

  // Statistics live on small thumbnails — a 128px-long-edge copy is
  // visually faithful enough for global mean / stddev and lets us walk
  // every pixel in ~16k operations rather than a few million.
  final capStats = _statsFor(_thumb(captured));
  final refStats = _statsFor(_thumb(reference));

  // adjustColor's `brightness` is an additive shift in -1..1 (where 1
  // pushes pure black to mid-grey). Express the luminance delta in the
  // same domain and clamp so an extreme reference can't blow out the
  // photo.
  final brightness =
      ((refStats.mean - capStats.mean) / 255.0).clamp(-0.5, 0.5);

  // `contrast` multiplies around mid-grey (1.0 == identity). Match the
  // reference's spread but cap the swing so a high-contrast night scene
  // doesn't crush a daytime shot.
  final contrast = (refStats.stdDev / math.max(capStats.stdDev, 1.0))
      .clamp(0.7, 1.4);

  final adjusted = img.adjustColor(
    captured,
    brightness: brightness,
    contrast: contrast,
  );

  return Uint8List.fromList(img.encodeJpg(adjusted, quality: 90));
}

img.Image _thumb(img.Image src) {
  const longEdge = 128;
  if (src.width <= longEdge && src.height <= longEdge) return src;
  if (src.width >= src.height) {
    return img.copyResize(src, width: longEdge);
  }
  return img.copyResize(src, height: longEdge);
}

class _LumStats {
  final double mean;
  final double stdDev;
  const _LumStats(this.mean, this.stdDev);
}

_LumStats _statsFor(img.Image thumb) {
  var sum = 0.0;
  var sumSq = 0.0;
  var count = 0;
  for (final px in thumb) {
    // ITU-R BT.601 luma — close enough for "is this scene bright?".
    final lum = 0.299 * px.r + 0.587 * px.g + 0.114 * px.b;
    sum += lum;
    sumSq += lum * lum;
    count++;
  }
  if (count == 0) return const _LumStats(0, 1);
  final mean = sum / count;
  final variance = (sumSq / count) - (mean * mean);
  final stdDev = variance > 0 ? math.sqrt(variance) : 0.0;
  return _LumStats(mean, stdDev);
}
