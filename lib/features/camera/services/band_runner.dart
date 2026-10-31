import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Per-pixel filter work is split across this many worker isolates. 4 is a
/// pragmatic default — most Android phones expose 4–8 physical cores and
/// the gain tails off quickly past that because the per-filter decode +
/// LUT-build phases stay sequential.
const int _parallelBands = 4;

/// Per-band processing function. Receives the raw RGB(A) pixel bytes for one
/// horizontal slice of the captured image and must return the modified bytes
/// for that slice (same length, same layout, in place is fine — the helper
/// reads what comes back, not the original buffer).
///
/// `yOffset` + `bandHeight` tell the function where its slice sits inside
/// the full image. Only the patch-based filters actually need them; the
/// global histogram filters can ignore both via `_`.
typedef BandFn = Uint8List Function(
  Uint8List bandBytes,
  int channels,
  int width,
  int yOffset,
  int bandHeight,
);

/// Split [captured]'s decoded pixel buffer into [_parallelBands] horizontal
/// bands, run [bandFn] on each band in its own isolate via `Isolate.run`,
/// stitch the modified bands back into a contiguous buffer, wrap them in
/// a new `img.Image`, and re-encode as JPEG (quality 90).
///
/// Decode and LUT/stats prep stay sequential in the calling isolate — they
/// are cheap relative to the per-pixel apply phase, which is where the cost
/// lives on a 12 MP shot. `Isolate.run` works inside a `compute()` worker
/// because it's just a wrapper around `Isolate.spawn` and doesn't need the
/// root isolate token.
Future<Uint8List> processBandsInParallel({
  required img.Image captured,
  required BandFn bandFn,
}) async {
  // A copy: the bands are written back into it, and `captured` stays as
  // it was.
  final pixels = Uint8List.fromList(captured.toUint8List());
  await processPixelBands(
    pixels: pixels,
    width: captured.width,
    height: captured.height,
    channels: captured.numChannels,
    bandFn: bandFn,
  );
  assert(
    captured.numChannels == 3 || captured.numChannels == 4,
    'Expected RGB or RGBA image, got ${captured.numChannels} channels',
  );
  final newImage = img.Image.fromBytes(
    width: captured.width,
    height: captured.height,
    bytes: pixels.buffer,
    numChannels: captured.numChannels,
    format: captured.format,
  );
  return Uint8List.fromList(img.encodeJpg(newImage, quality: 90));
}

/// Runs [bandFn] over raw [pixels] — [width] × [height], [channels] bytes a
/// pixel, rows packed — split into [_parallelBands] horizontal bands, one
/// isolate each, and writes each band's result back into [pixels].
///
/// The full-resolution save render uses this directly on the decoded photo,
/// so its filters never go through a JPEG between steps.
Future<void> processPixelBands({
  required Uint8List pixels,
  required int width,
  required int height,
  required int channels,
  required BandFn bandFn,
}) async {
  assert(channels > 0 && channels <= 4, 'Channel count must be between 1 and 4');
  assert(
    pixels.lengthInBytes >= width * height * channels,
    'Pixel buffer size (${pixels.lengthInBytes}) is smaller than width * height * channels (${width * height * channels})',
  );
  final bytesPerRow = width * channels;

  // Ceil so the last band picks up any remainder rows.
  final bandRowCount = (height / _parallelBands).ceil();
  final starts = <int>[];
  final futures = <Future<Uint8List>>[];

  for (var b = 0; b < _parallelBands; b++) {
    final y0 = b * bandRowCount;
    if (y0 >= height) break;
    final y1 = math.min((b + 1) * bandRowCount, height);
    final actualHeight = y1 - y0;
    // `sublist` returns a fresh Uint8List, so each isolate gets its own
    // copy of its band to mutate without aliasing the source buffer.
    final bandBytes = pixels.sublist(y0 * bytesPerRow, y1 * bytesPerRow);

    starts.add(y0 * bytesPerRow);
    futures.add(
      Isolate.run(
        () => bandFn(bandBytes, channels, width, y0, actualHeight),
      ),
    );
  }

  final results = await Future.wait(futures);
  for (var b = 0; b < results.length; b++) {
    pixels.setRange(starts[b], starts[b] + results[b].length, results[b]);
  }
}
