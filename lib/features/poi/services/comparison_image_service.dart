import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Sendable bundle for the comparison-image `compute()` helper.
class ComparisonArgs {
  /// The captured shot (in its current edited state).
  final Uint8List capturedBytes;

  /// The anime-scene reference being compared against.
  final Uint8List referenceBytes;

  /// Gap in pixels between the two images in the output. Stays a thin
  /// constant — the goal is "side by side", not "thumbnail strip".
  final int gap;

  const ComparisonArgs({
    required this.capturedBytes,
    required this.referenceBytes,
    this.gap = 8,
  });
}

/// Produce a side-by-side JPEG of [capturedBytes] (left) and
/// [referenceBytes] (right), both resized to a shared height (the
/// shorter of the two, capped at 1600 px so a 4K reference doesn't
/// blow up the export size). Aspect ratios are preserved; the gap
/// between the two panels is filled with black.
Future<Uint8List> generateComparison(ComparisonArgs args) async {
  final captured = img.decodeImage(args.capturedBytes);
  final reference = img.decodeImage(args.referenceBytes);
  if (captured == null || reference == null) return args.capturedBytes;

  // Pick a target height: lower of the two so neither image is
  // upscaled, capped at 1600 so the result is shareable rather than
  // monstrous.
  const maxHeight = 1600;
  final targetHeight = math
      .min(maxHeight, math.min(captured.height, reference.height))
      .toInt();

  final capResized = captured.height == targetHeight
      ? captured
      : img.copyResize(captured, height: targetHeight);
  final refResized = reference.height == targetHeight
      ? reference
      : img.copyResize(reference, height: targetHeight);

  final gap = args.gap;
  final totalWidth = capResized.width + gap + refResized.width;

  // Fresh black canvas to host the two panels.
  final composite = img.Image(width: totalWidth, height: targetHeight);
  img.fill(composite, color: img.ColorRgb8(0, 0, 0));

  img.compositeImage(composite, capResized, dstX: 0, dstY: 0);
  img.compositeImage(
    composite,
    refResized,
    dstX: capResized.width + gap,
    dstY: 0,
  );

  return Uint8List.fromList(img.encodeJpg(composite, quality: 90));
}
