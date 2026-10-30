import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:trip_planner/features/camera/services/reinhard_match_service.dart';
import 'package:trip_planner/features/poi/services/brightness_service.dart';
import 'package:trip_planner/features/poi/services/edit_recipe.dart';
import 'package:trip_planner/features/poi/services/sharpness_service.dart';

/// A [width]×[height] image of random pixels, opaque when it has alpha.
img.Image _noise(int width, int height, {int channels = 4, int seed = 1}) {
  final rnd = math.Random(seed);
  final image = img.Image(width: width, height: height, numChannels: channels);
  for (final p in image) {
    p
      ..r = rnd.nextInt(256)
      ..g = rnd.nextInt(256)
      ..b = rnd.nextInt(256);
    if (channels == 4) p.a = 255;
  }
  return image;
}

RgbaImage _rgba(img.Image image) => RgbaImage(
  Uint8List.fromList(image.toUint8List()),
  image.width,
  image.height,
);

/// The R G B bytes of [pixels], dropping any other channel.
List<int> _rgb(Uint8List pixels, int channels) => [
  for (var i = 0; i < pixels.length; i += channels) ...[
    pixels[i],
    pixels[i + 1],
    pixels[i + 2],
  ],
];

void main() {
  group('gaussianBlurPixels', () {
    for (final channels in [3, 4]) {
      test(
        'matches package:image gaussianBlur(radius: 2), $channels channels',
        () {
          final image = _noise(37, 23, channels: channels);
          final expected = img.gaussianBlur(img.Image.from(image), radius: 2);
          final blurred = gaussianBlurPixels(
            image.toUint8List(),
            image.width,
            image.height,
            channels,
          );
          expect(
            _rgb(blurred, channels),
            _rgb(expected.toUint8List(), channels),
          );
        },
      );
    }
  });

  test(
    'sharpenPixels gives the same pixels as the unsharp mask it replaces',
    () {
      final image = _noise(29, 17, channels: 3);
      const amount = 0.6;
      final blur = img
          .gaussianBlur(img.Image.from(image), radius: 2)
          .toUint8List();
      final orig = image.toUint8List();
      final expected = [
        for (var i = 0; i < orig.length; i++)
          (orig[i] + amount * (orig[i] - blur[i])).round().clamp(0, 255),
      ];
      final pixels = Uint8List.fromList(orig);
      sharpenPixels(pixels, image.width, image.height, 3, amount);
      expect(pixels, expected);
    },
  );

  test('brightenPixels scales R G B and leaves alpha', () {
    final pixels = Uint8List.fromList([10, 100, 250, 255, 0, 51, 200, 128]);
    brightenPixels(pixels, 4, 0.2);
    expect(pixels, [12, 120, 255, 255, 0, 61, 240, 128]);
  });

  group('rotateAndCrop', () {
    final image = _noise(7, 5);
    const crops = <List<double>?>[
      null,
      [0.25, 0.2, 0.5, 0.6],
      [0.9, 0.9, 0.5, 0.5],
    ];
    for (final mirror in [false, true]) {
      for (var q = 0; q < 4; q++) {
        for (final crop in crops) {
          test('matches ${mirror ? 'flipHorizontal + ' : ''}copyRotate + '
              'copyCrop, $q quarter-turns, crop $crop', () {
            var expected = img.copyRotate(
              mirror ? img.flipHorizontal(img.Image.from(image)) : image,
              angle: 90 * q,
            );
            if (crop != null) {
              final w = expected.width, h = expected.height;
              final x = (crop[0] * w).round().clamp(0, w - 1);
              final y = (crop[1] * h).round().clamp(0, h - 1);
              expected = img.copyCrop(
                expected,
                x: x,
                y: y,
                width: (crop[2] * w).round().clamp(1, w - x),
                height: (crop[3] * h).round().clamp(1, h - y),
              );
            }
            final out = rotateAndCrop(_rgba(image), q, crop, mirror: mirror);
            expect((out.width, out.height), (expected.width, expected.height));
            expect(out.pixels, expected.toUint8List());
          });
        }
      }
    }
  });

  group('straightenAndCrop', () {
    test('keeps the photo as it is at 0°', () {
      final image = _rgba(_noise(9, 7));
      final out = straightenAndCrop(image, 0, null);
      expect((out.width, out.height), (9, 7));
      expect(out.pixels, image.pixels);
    });

    test('turns clockwise: 90° on a square is a quarter-turn', () {
      final image = _rgba(_noise(11, 11));
      expect(
        straightenAndCrop(image, 90, null).pixels,
        rotateAndCrop(image, 1, null).pixels,
      );
      expect(
        straightenAndCrop(image, -90, null).pixels,
        rotateAndCrop(image, 3, null).pixels,
      );
    });

    test('keeps the largest rectangle of the same shape', () {
      final out = straightenAndCrop(_rgba(_noise(400, 300)), 10, null);
      // 300 / (400 sin 10° + 300 cos 10°) = 0.822 of the photo.
      expect((out.width, out.height), (329, 247));
      expect(straightenScale(400, 300, -10), straightenScale(400, 300, 10));
    });

    test('samples inside the photo only, so a flat photo stays flat', () {
      final flat = img.Image(width: 60, height: 40, numChannels: 4);
      img.fill(flat, color: img.ColorRgba8(200, 120, 40, 255));
      final out = straightenAndCrop(_rgba(flat), 33, null);
      final words = out.pixels.buffer.asUint32List();
      expect(words.toSet(), {words.first});
    });

    test('crops the straightened frame', () {
      final image = _rgba(_noise(50, 30));
      const crop = [0.2, 0.1, 0.5, 0.7];
      final whole = straightenAndCrop(image, 7.5, null);
      final out = straightenAndCrop(image, 7.5, crop);
      final expected = rotateAndCrop(whole, 0, crop);
      expect((out.width, out.height), (expected.width, expected.height));
      expect(out.pixels, expected.pixels);
    });
  });

  group('Match Color on raw pixels', () {
    test('takes the same stats as the image-based thumbnail', () {
      for (final (w, h) in [(600, 300), (300, 600), (100, 80)]) {
        final image = _noise(w, h, channels: 3, seed: w);
        final raw = labStatsOfPixels(image.toUint8List(), w, h, 3);
        final viaImage = labStatsOfImage(image);
        expect(
          [raw.meanL, raw.meanA, raw.meanB, raw.stdL, raw.stdA, raw.stdB],
          [
            viaImage.meanL,
            viaImage.meanA,
            viaImage.meanB,
            viaImage.stdL,
            viaImage.stdA,
            viaImage.stdB,
          ],
        );
      }
    });

    test('blends with the original by strength and keeps alpha', () async {
      final photo = _noise(40, 30);
      final reference = Uint8List.fromList(
        img.encodePng(_noise(20, 20, seed: 9)),
      );
      Future<Uint8List> match(double strength) async {
        final pixels = Uint8List.fromList(photo.toUint8List());
        await matchColorPixels(
          pixels,
          40,
          30,
          4,
          reference,
          strength: strength,
        );
        return pixels;
      }

      final full = await match(1);
      final half = await match(0.5);
      final orig = photo.toUint8List();
      expect(full, isNot(orig));
      for (var i = 0; i < orig.length; i++) {
        if (i % 4 == 3) {
          expect(full[i], 255);
          expect(half[i], 255);
        } else {
          expect(half[i], closeTo((orig[i] + full[i]) / 2, 1));
        }
      }
    });
  });

  group('EditRecipe', () {
    test(
      'is empty when every step is a no-op and nothing is turned or cut',
      () {
        expect(const EditRecipe().isEmpty, isTrue);
        expect(
          const EditRecipe(
            steps: [
              EditStep('brightness', 0),
              EditStep('sharpness', 0),
              EditStep('match', 1),
              EditStep('match', 0, referencePath: 'ref.png'),
            ],
          ).isEmpty,
          isTrue,
        );
        expect(
          const EditRecipe(steps: [EditStep('brightness', 0.1)]).isEmpty,
          isFalse,
        );
        expect(const EditRecipe(quarters: 4).isEmpty, isTrue);
        expect(const EditRecipe(quarters: 1).isEmpty, isFalse);
        expect(const EditRecipe(mirror: true).isEmpty, isFalse);
        expect(const EditRecipe(angle: -2.5).isEmpty, isFalse);
        expect(const EditRecipe(crop: [0, 0, 0.5, 0.5]).isEmpty, isFalse);
      },
    );

    test('renderEdits mirrors, turns, straightens and crops', () async {
      final photo = _noise(30, 20);
      const recipe = EditRecipe(
        mirror: true,
        quarters: 3,
        angle: 12,
        crop: [0.1, 0.2, 0.6, 0.5],
      );
      final out = await renderEdits(
        RenderEditsArgs(_rgba(photo), recipe, const []),
      );
      final turned = rotateAndCrop(_rgba(photo), 3, null, mirror: true);
      final expected = straightenAndCrop(turned, 12, [0.1, 0.2, 0.6, 0.5]);
      expect((out.width, out.height), (expected.width, expected.height));
      expect(out.pixels, expected.pixels);
    });

    test(
      'renderEdits applies the tools in order, then turns and crops',
      () async {
        final photo = _noise(8, 6);
        const recipe = EditRecipe(
          steps: [EditStep('brightness', -0.3), EditStep('brightness', 0)],
          quarters: 1,
          crop: [0, 0.5, 1, 0.5],
        );
        final out = await renderEdits(
          RenderEditsArgs(_rgba(photo), recipe, const [null, null]),
        );

        final expected = _rgba(photo);
        brightenPixels(expected.pixels, 4, -0.3);
        final turned = rotateAndCrop(expected, 1, [0, 0.5, 1, 0.5]);
        expect((out.width, out.height), (6, 4));
        expect(out.pixels, turned.pixels);
      },
    );
  });
}
