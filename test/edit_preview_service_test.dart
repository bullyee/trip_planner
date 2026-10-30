import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trip_planner/features/poi/services/edit_preview_service.dart';

/// A [width]×[height] JPEG whose EXIF orientation tag is [orientation]
/// (6 = "rotate 90° clockwise", what phones write for portrait shots).
Uint8List _jpeg(int width, int height, {int orientation = 1}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 120, 40));
  if (orientation != 1) image.exif.imageIfd.orientation = orientation;
  return Uint8List.fromList(img.encodeJpg(image));
}

/// Pixel size as stored in the file, before any EXIF rotation is applied.
/// (`img.decodeJpg` applies the rotation, so it can't tell an upright file
/// from a tagged one.)
(int, int) _storedSize(Uint8List jpeg) {
  final info = img.JpegDecoder().startDecode(jpeg)!;
  return (info.width, info.height);
}

int _orientation(Uint8List jpeg) =>
    img.decodeJpgExif(jpeg)?.imageIfd.orientation ?? 1;

Future<Uint8List> _transform(
  Uint8List jpeg, {
  bool mirror = false,
  int quarters = 0,
  double angle = 0,
  List<double>? crop,
}) => transformJpeg(
  TransformArgs(
    jpeg,
    mirror: mirror,
    quarters: quarters,
    angle: angle,
    crop: crop,
  ),
);

void main() {
  test('the portrait test JPEG is stored sideways with a rotate tag', () {
    final jpeg = _jpeg(40, 20, orientation: 6);
    expect(_storedSize(jpeg), (40, 20));
    expect(_orientation(jpeg), 6);
  });

  group('downscaleForEditing', () {
    test('stores a portrait capture upright with no rotate tag', () async {
      final out = await downscaleForEditing(_jpeg(40, 20, orientation: 6));
      expect(_storedSize(out), (20, 40));
      expect(_orientation(out), 1);
    });

    test('caps the long edge after turning the image upright', () async {
      final out = await downscaleForEditing(_jpeg(2048, 1024, orientation: 6));
      expect(_storedSize(out), (
        editingPreviewMaxDim ~/ 2,
        editingPreviewMaxDim,
      ));
    });

    test('keeps a small upright image at its size', () async {
      final out = await downscaleForEditing(_jpeg(300, 200));
      expect(_storedSize(out), (300, 200));
    });
  });

  group('transformJpeg', () {
    test('returns the input untouched when there is nothing to do', () async {
      final input = _jpeg(40, 20);
      expect(identical(await _transform(input), input), isTrue);
      expect(identical(await _transform(input, quarters: 4), input), isTrue);
    });

    test('a quarter turn swaps width and height', () async {
      expect(_storedSize(await _transform(_jpeg(40, 20), quarters: 1)), (
        20,
        40,
      ));
    });

    test('a half turn keeps the size', () async {
      expect(_storedSize(await _transform(_jpeg(40, 20), quarters: 2)), (
        40,
        20,
      ));
    });

    test('maps the normalised crop rect onto pixels', () async {
      final out = await _transform(_jpeg(100, 50), crop: [0.25, 0.2, 0.5, 0.6]);
      expect(_storedSize(out), (50, 30));
    });

    test('clamps a crop rect that hangs off the edge', () async {
      final out = await _transform(_jpeg(100, 50), crop: [0.9, 0.9, 0.5, 0.5]);
      expect(_storedSize(out), (10, 5));
    });

    test('crops after rotating, in one pass', () async {
      // 100×50 turned a quarter is 50×100; its top half is 50×50.
      final out = await _transform(
        _jpeg(100, 50),
        quarters: 1,
        crop: [0, 0, 1, 0.5],
      );
      expect(_storedSize(out), (50, 50));
    });

    test('works relative to the upright image of a tagged capture', () async {
      // Upright the capture is 50×100: a quarter turn makes it 100×50, and
      // its left half is 50×50.
      final out = await _transform(
        _jpeg(100, 50, orientation: 6),
        quarters: 1,
        crop: [0, 0, 0.5, 1],
      );
      expect(_storedSize(out), (50, 50));
      expect(_orientation(out), 1);
    });

    test('mirrors left to right', () async {
      // Red on the left half, blue on the right; mirrored, blue is left.
      final image = img.Image(width: 40, height: 20);
      img.fillRect(
        image,
        x1: 0,
        y1: 0,
        x2: 19,
        y2: 19,
        color: img.ColorRgb8(220, 20, 20),
      );
      img.fillRect(
        image,
        x1: 20,
        y1: 0,
        x2: 39,
        y2: 19,
        color: img.ColorRgb8(20, 20, 220),
      );
      final out = img.decodeJpg(
        await _transform(
          Uint8List.fromList(img.encodeJpg(image)),
          mirror: true,
        ),
      )!;
      expect(out.getPixel(5, 10).b, greaterThan(150));
      expect(out.getPixel(34, 10).r, greaterThan(150));
    });

    test('straightening zooms in to keep the shape', () async {
      final out = await _transform(_jpeg(400, 300), angle: 10);
      expect(_storedSize(out), (329, 247));
    });
  });

  test('encodeRgbaJpeg encodes raw RGBA pixels', () async {
    final rgba = Uint8List(4 * 2 * 4);
    for (var i = 0; i < rgba.length; i += 4) {
      rgba
        ..[i] = 220
        ..[i + 1] = 30
        ..[i + 2] = 30
        ..[i + 3] = 255;
    }
    final jpeg = await encodeRgbaJpeg(RgbaJpegArgs(rgba, 4, 2));
    expect(_storedSize(jpeg), (4, 2));
    final pixel = img.decodeJpg(jpeg)!.getPixel(1, 1);
    expect(pixel.r, closeTo(220, 12));
    expect(pixel.g, closeTo(30, 12));
  });
}
