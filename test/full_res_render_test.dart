import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trip_planner/features/poi/services/edit_recipe.dart';
import 'package:trip_planner/features/poi/services/full_res_render.dart';

/// A [width]×[height] JPEG whose EXIF orientation tag is [orientation]
/// (6 = "rotate 90° clockwise", what phones write for portrait shots), with
/// a red top-left corner to tell the orientation by.
Uint8List _jpeg(int width, int height, {int orientation = 1}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(40, 120, 200));
  img.fillRect(
    image,
    x1: 0,
    y1: 0,
    x2: 7,
    y2: 7,
    color: img.ColorRgb8(255, 0, 0),
  );
  if (orientation != 1) image.exif.imageIfd.orientation = orientation;
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

/// Pixel size as stored in the file, before any EXIF rotation.
(int, int) _storedSize(Uint8List jpeg) {
  final info = img.JpegDecoder().startDecode(jpeg)!;
  return (info.width, info.height);
}

bool _isRed(RgbaImage image, int x, int y) {
  final i = (y * image.width + x) * 4;
  final p = image.pixels;
  return p[i] > 200 && p[i + 1] < 60 && p[i + 2] < 60;
}

void main() {
  testWidgets('the engine decode turns a tagged capture upright', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final decoded = await decodeRgba(_jpeg(40, 20, orientation: 6));
      expect((decoded.width, decoded.height), (20, 40));
      // "Rotate 90° clockwise" puts the stored top-left corner top-right.
      expect(_isRed(decoded, 18, 2), isTrue);
      expect(_isRed(decoded, 2, 2), isFalse);
    });
  });

  testWidgets('pixels survive the trip through an engine image', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final source = await decodeRgba(_jpeg(16, 12));
      final image = await imageFromRgba(source);
      final back = await rgbaOf(image);
      image.dispose();
      expect((back.width, back.height), (16, 12));
      expect(back.pixels, source.pixels);
    });
  });

  testWidgets('encodeJpeg falls back to the Dart encoder off Android', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final jpeg = await encodeJpeg(await decodeRgba(_jpeg(30, 10)));
      expect(_storedSize(jpeg), (30, 10));
    });
  });

  testWidgets('renderEditedJpeg renders the recipe on the upright photo', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('render_test');
      try {
        final path = '${dir.path}/photo.jpg';
        await File(path).writeAsBytes(_jpeg(40, 20, orientation: 6));
        // Upright 20×40, turned a quarter: 40×20; its left half: 20×20.
        const recipe = EditRecipe(
          steps: [EditStep('brightness', 0.2)],
          quarters: 1,
          crop: [0, 0, 0.5, 1],
        );
        final jpeg = await renderEditedJpeg(path, recipe);
        expect(_storedSize(jpeg), (20, 20));
        final image = await renderEditedImage(path, const EditRecipe());
        expect((image.width, image.height), (20, 40));
        image.dispose();
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });
}
