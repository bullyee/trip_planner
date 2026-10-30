import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Sendable bundle for the sharpness adjust `compute()` helper.
class SharpnessArgs {
  /// JPEG-encoded source. The unsharp mask runs on whatever the editor
  /// was displaying when the user reached for this tool.
  final Uint8List sourceBytes;

  /// Unsharp-mask amount in [0, 1]. `0` returns the source unchanged;
  /// `1` adds the full detail layer back. Out-of-range values are
  /// clamped by the filter.
  final double amount;

  const SharpnessArgs({
    required this.sourceBytes,
    required this.amount,
  });
}

/// Unsharp-mask sharpening.
///
/// 1. Blur the image with a small-radius Gaussian (radius 2 — wide
///    enough to pick up edges without obliterating texture, narrow
///    enough to stay cheap on a 12 MP shot).
/// 2. `result = original + amount * (original − blurred)`, clamped.
Future<Uint8List> applySharpness(SharpnessArgs args) async {
  final image = img.decodeImage(args.sourceBytes);
  if (image == null) return args.sourceBytes;
  final amount = args.amount.clamp(0.0, 1.0);
  if (amount == 0) return args.sourceBytes;

  final pixels = Uint8List.fromList(image.toUint8List());
  sharpenPixels(pixels, image.width, image.height, image.numChannels, amount);
  final sharpened = img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: pixels.buffer,
    numChannels: image.numChannels,
  );
  return Uint8List.fromList(img.encodeJpg(sharpened, quality: 90));
}

/// [applySharpness] on raw [pixels] — [width] × [height], [channels] bytes a
/// pixel with R G B first, rows packed — in place. The full-resolution save
/// render calls this on the decoded photo.
void sharpenPixels(
  Uint8List pixels,
  int width,
  int height,
  int channels,
  double amount,
) {
  final a = amount.clamp(0.0, 1.0);
  if (a == 0) return;
  final blurred = gaussianBlurPixels(pixels, width, height, channels);
  _sharpen(pixels, blurred, channels, _sharpenTable(a));
}

/// What a channel becomes under unsharp mask [amount], indexed by
/// `original << 8 | blurred`: one lookup a byte instead of the arithmetic.
Uint8List _sharpenTable(double amount) {
  final table = Uint8List(256 * 256);
  for (var orig = 0; orig < 256; orig++) {
    for (var blur = 0; blur < 256; blur++) {
      table[orig << 8 | blur] =
          (orig + amount * (orig - blur)).round().clamp(0, 255);
    }
  }
  return table;
}

/// Sharpens the R G B bytes of [pixels] in place against [blurred].
void _sharpen(
  Uint8List pixels,
  Uint8List blurred,
  int channels,
  Uint8List table,
) {
  final n = pixels.length;
  for (var i = 0; i < n; i += channels) {
    pixels[i] = table[pixels[i] << 8 | blurred[i]];
    pixels[i + 1] = table[pixels[i + 1] << 8 | blurred[i + 1]];
    pixels[i + 2] = table[pixels[i + 2] << 8 | blurred[i + 2]];
  }
}

/// The radius-2 kernel exactly as package:image builds it for
/// `gaussianBlur(radius: 2)`.
final List<double> _blurKernel = () {
  const radius = 2;
  final sigma = radius * (2.0 / 3.0);
  final s = 2.0 * sigma * sigma;
  final kernel = <double>[];
  var sum = 0.0;
  for (var x = -radius; x <= radius; ++x) {
    final c = math.exp(-(x * x) / s);
    sum += c;
    kernel.add(c);
  }
  final scale = 1.0 / sum;
  return [for (final c in kernel) c * scale];
}();

/// package:image's edge handling for a tap at [x] on a line of [max]
/// pixels, kept inside the line for tiny images.
int _reflect(int max, int x) {
  final r = x < 0 ? -x : (x >= max ? max - (x - max) - 1 : x);
  return r.clamp(0, max - 1);
}

/// `img.gaussianBlur(image, radius: 2)` on raw pixels, to the same values —
/// same kernel, edge reflection, pass order and truncation — but without
/// package:image's per-pixel objects, which made it take seconds on a 12 MP
/// photo. Blurs R G B; any other channel is copied as is. Returns a new
/// buffer.
Uint8List gaussianBlurPixels(
  Uint8List pixels,
  int width,
  int height,
  int channels,
) {
  final k0 = _blurKernel[0], k1 = _blurKernel[1], k2 = _blurKernel[2];
  final k3 = _blurKernel[3], k4 = _blurKernel[4];
  final rowBytes = width * channels;
  final tmp = Uint8List.fromList(pixels);
  final out = Uint8List.fromList(pixels);

  // Byte offset of each tap: entry i is for column / row i - 2.
  final cols = Int32List(width + 4);
  for (var i = 0; i < cols.length; i++) {
    cols[i] = _reflect(width, i - 2) * channels;
  }
  final rows = Int32List(height + 4);
  for (var i = 0; i < rows.length; i++) {
    rows[i] = _reflect(height, i - 2) * rowBytes;
  }

  // Horizontal pass, pixels → tmp.
  for (var y = 0; y < height; y++) {
    final row = y * rowBytes;
    for (var x = 0; x < width; x++) {
      final a = row + cols[x], b = row + cols[x + 1], c = row + cols[x + 2];
      final d = row + cols[x + 3], e = row + cols[x + 4];
      tmp[c] = (k0 * pixels[a] +
              k1 * pixels[b] +
              k2 * pixels[c] +
              k3 * pixels[d] +
              k4 * pixels[e])
          .toInt();
      tmp[c + 1] = (k0 * pixels[a + 1] +
              k1 * pixels[b + 1] +
              k2 * pixels[c + 1] +
              k3 * pixels[d + 1] +
              k4 * pixels[e + 1])
          .toInt();
      tmp[c + 2] = (k0 * pixels[a + 2] +
              k1 * pixels[b + 2] +
              k2 * pixels[c + 2] +
              k3 * pixels[d + 2] +
              k4 * pixels[e + 2])
          .toInt();
    }
  }

  // Vertical pass, tmp → out.
  for (var y = 0; y < height; y++) {
    final a = rows[y], b = rows[y + 1], c = rows[y + 2];
    final d = rows[y + 3], e = rows[y + 4];
    for (var x = 0; x < rowBytes; x += channels) {
      for (var ch = x; ch < x + 3; ch++) {
        out[c + ch] = (k0 * tmp[a + ch] +
                k1 * tmp[b + ch] +
                k2 * tmp[c + ch] +
                k3 * tmp[d + ch] +
                k4 * tmp[e + ch])
            .toInt();
      }
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
//  Slider-preview path: downscale + blur are precomputed once when the user
//  enters sharpness mode (only happens at chip tap), and every slider
//  release after that just runs the per-pixel combine on the cached
//  ~1280 px downscaled buffers + a small JPEG encode. Save renders the
//  full-res photo instead (`renderEdits`), so on-disk quality isn't
//  downscaled.
// ---------------------------------------------------------------------------
/// Sendable cache of the downscaled source + its Gaussian blur, used by
/// [applySharpnessQuick] for slider-release previews. Built once per
/// source via [prepareSharpness].
class PreparedSharpness {
  final Uint8List sourceRgba;
  final Uint8List blurredRgba;
  final int width;
  final int height;
  final int channels;

  const PreparedSharpness({
    required this.sourceRgba,
    required this.blurredRgba,
    required this.width,
    required this.height,
    required this.channels,
  });
}

class QuickSharpnessArgs {
  final PreparedSharpness prepared;
  final double amount;

  const QuickSharpnessArgs({
    required this.prepared,
    required this.amount,
  });
}

/// Decode the source, downscale to 1280 px on the long edge, and
/// Gaussian-blur the downscaled copy. The result is sendable and
/// stays cached on the editor for the lifetime of the sharpness tool —
/// subsequent slider releases reuse it via [applySharpnessQuick].
Future<PreparedSharpness> prepareSharpness(Uint8List sourceBytes) async {
  final image = img.decodeImage(sourceBytes);
  if (image == null) {
    throw StateError('prepareSharpness: decode failed');
  }

  const maxDim = 1280;
  final long = math.max(image.width, image.height);
  final img.Image downscaled;
  if (long <= maxDim) {
    downscaled = image;
  } else {
    final scale = maxDim / long;
    downscaled = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
    );
  }

  final source = downscaled.toUint8List();

  return PreparedSharpness(
    sourceRgba: source,
    blurredRgba: gaussianBlurPixels(
      source,
      downscaled.width,
      downscaled.height,
      downscaled.numChannels,
    ),
    width: downscaled.width,
    height: downscaled.height,
    channels: downscaled.numChannels,
  );
}

/// Apply unsharp mask against the cached downscaled source + blur,
/// encode the result as JPEG. Used for slider-release previews — ~300
/// ms on a typical 1280 px buffer instead of the ~2-3 s full-res path.
Future<Uint8List> applySharpnessQuick(QuickSharpnessArgs args) async {
  final amount = args.amount.clamp(0.0, 1.0);
  final source = args.prepared.sourceRgba;
  final blurred = args.prepared.blurredRgba;
  final channels = args.prepared.channels;

  final result = Uint8List.fromList(source);
  if (amount > 0) {
    _sharpen(result, blurred, channels, _sharpenTable(amount));
  }

  final image = img.Image.fromBytes(
    width: args.prepared.width,
    height: args.prepared.height,
    bytes: result.buffer,
    numChannels: channels,
  );
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}
