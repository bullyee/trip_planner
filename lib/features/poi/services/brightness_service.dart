import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../camera/services/band_runner.dart';

/// Sendable bundle for the brightness adjust `compute()` helper.
class BrightnessArgs {
  /// JPEG-encoded source — whatever the editor was displaying at the
  /// moment the user reached for this tool. The result chains on top.
  final Uint8List sourceBytes;

  /// Multiplier offset: `0` is identity, `+0.5` brightens (each RGB
  /// channel × 1.5, clamped), `-0.5` darkens (× 0.5). The editor's
  /// slider feeds values in [-0.5, +0.5]; out-of-range values are
  /// clamped by the filter.
  final double brightness;

  const BrightnessArgs({
    required this.sourceBytes,
    required this.brightness,
  });
}

/// Multiplicative brightness adjust over the whole image. Scaling
/// each channel by `(1 + brightness)` preserves hue exactly (the
/// channel ratio doesn't change) and keeps blacks at black —
/// additive shifts wash shadows out, which the gallery pickers
/// usually don't want.
Future<Uint8List> applyBrightness(BrightnessArgs args) async {
  final image = img.decodeImage(args.sourceBytes);
  if (image == null) return args.sourceBytes;
  final table = _brightnessTable(args.brightness);
  return processBandsInParallel(
    captured: image,
    bandFn: (bytes, ch, _, _, _) => _mapChannels(bytes, ch, table),
  );
}

/// [applyBrightness] on raw [pixels] ([channels] bytes a pixel, R G B
/// first), in place, for the full-resolution save render. A table lookup
/// per byte, so it doesn't need splitting across isolates.
void brightenPixels(Uint8List pixels, int channels, double brightness) {
  _mapChannels(pixels, channels, _brightnessTable(brightness));
}

/// What each 8-bit channel value becomes: scaled by `1 + brightness`,
/// rounded and clamped.
Uint8List _brightnessTable(double brightness) {
  final scale = 1 + brightness.clamp(-0.5, 0.5);
  return Uint8List.fromList([
    for (var v = 0; v < 256; v++) (v * scale).round().clamp(0, 255),
  ]);
}

/// Maps the R G B bytes of every pixel through [table], in place.
Uint8List _mapChannels(Uint8List bytes, int channels, Uint8List table) {
  final n = bytes.length;
  for (var i = 0; i < n; i += channels) {
    bytes[i] = table[bytes[i]];
    bytes[i + 1] = table[bytes[i + 1]];
    bytes[i + 2] = table[bytes[i + 2]];
  }
  return bytes;
}
