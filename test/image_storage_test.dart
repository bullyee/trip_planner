import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trip_planner/core/utils/image_storage.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.docsPath);
  final String docsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  late Directory tempDocs;

  setUp(() async {
    tempDocs = await Directory.systemTemp.createTemp('image_storage_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDocs.path);
  });

  tearDown(() async {
    if (await tempDocs.exists()) {
      await tempDocs.delete(recursive: true);
    }
  });

  test('writes bytes under appDocs/<subdir>/<uuid>.<ext> and returns path',
      () async {
    const jpegBytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10];
    final mock = MockClient(
      (request) async => http.Response.bytes(jpegBytes, 200),
    );

    final result = await downloadCoverImage(
      'https://example.com/anitabi/cover.jpg',
      client: mock,
    );

    expect(result, isNotNull);
    expect(result!.startsWith(p.join(tempDocs.path, 'poi_covers')), isTrue);
    expect(p.extension(result), '.jpg');
    final written = await File(result).readAsBytes();
    expect(written, jpegBytes);
  });

  test('falls back to .jpg extension when URL path has none', () async {
    final mock = MockClient(
      (request) async => http.Response.bytes([0, 1, 2], 200),
    );
    final result = await downloadCoverImage(
      'https://example.com/anitabi/cover?plan=h360',
      client: mock,
    );
    expect(result, isNotNull);
    expect(p.extension(result!), '.jpg');
  });

  test('returns null on HTTP 500 without writing anything', () async {
    final mock = MockClient(
      (request) async => http.Response('boom', 500),
    );

    final result = await downloadCoverImage(
      'https://example.com/anitabi/cover.jpg',
      client: mock,
    );

    expect(result, isNull);
    final covers = Directory(p.join(tempDocs.path, 'poi_covers'));
    if (await covers.exists()) {
      final entries = covers.listSync();
      expect(entries, isEmpty);
    }
  });

  test('returns null when the body is empty', () async {
    final mock = MockClient(
      (request) async => http.Response.bytes(const [], 200),
    );

    final result = await downloadCoverImage(
      'https://example.com/anitabi/cover.jpg',
      client: mock,
    );

    expect(result, isNull);
  });
}
