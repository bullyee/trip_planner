import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/features/poi/services/anitabi_api_service.dart';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.docsPath);
  final String docsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => docsPath;
}

void main() {
  late AppDatabase db;
  late Directory tempDocs;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDocs = await Directory.systemTemp.createTemp('anitabi_import_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDocs.path);
  });

  tearDown(() async {
    await db.close();
    if (await tempDocs.exists()) {
      await tempDocs.delete(recursive: true);
    }
  });

  test('importBangumiSubject inserts POI, links anime, and downloads cover',
      () async {
    const jpegBytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46];
    final calls = <String>[];
    final mock = MockClient((request) async {
      calls.add('${request.method} ${request.url}');
      final path = request.url.path;
      if (path == '/bangumi/1424') {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'title': 'けいおん！'})),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      }
      if (path == '/bangumi/1424/points/detail') {
        return http.Response.bytes(
          utf8.encode(jsonEncode([
            {
              'id': 'anitabi-poi-1',
              'name': 'Toyosato Elementary School',
              'cn': '丰乡小学',
              'geo': [35.193, 136.247],
              'image': 'https://image.anitabi.cn/cover.jpg?plan=h160',
              's': 90,
              'ep': 1,
              'origin': 'Anitabi',
              'originURL': 'https://anitabi.cn/poi/anitabi-poi-1',
            },
          ])),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      }
      if (request.url.toString() ==
          'https://image.anitabi.cn/cover.jpg?plan=h360') {
        return http.Response.bytes(jpegBytes, 200);
      }
      return http.Response('unexpected: ${request.url}', 404);
    });

    final result = await AnitabiApiService.importBangumiSubject(
      db,
      '1424',
      client: mock,
    );

    expect(result, isNotNull, reason: 'mock calls: $calls');
    expect(result!.animeName, 'けいおん！');
    expect(result.poisImported, 1);
    expect(result.poisSkipped, 0);
    expect(result.coversPending, 1);

    // Cover downloads happen in the background; await completion so we can
    // assert on the final POI state.
    final coversDownloaded = await result.coverDownloadCompletion;
    expect(coversDownloaded, 1);

    final animes = await db.getAllAnimes();
    expect(animes, hasLength(1));
    expect(animes.first.bangumiId, '1424');

    final pois = await db.getAllPois();
    expect(pois, hasLength(1));
    expect(pois.first.name, '丰乡小学');

    final coverUri = pois.first.coverImageUri;
    expect(coverUri, isNotNull);
    expect(coverUri!.startsWith(p.join(tempDocs.path, 'poi_covers')), isTrue);
    expect(File(coverUri).existsSync(), isTrue);

    final junction = await db.watchAnimesForPoi(pois.first.id).first;
    expect(junction, hasLength(1));
    expect(junction.first.id, animes.first.id);
  });

  test('importBangumiSubject keeps URL when image download fails', () async {
    final mock = MockClient((request) async {
      final path = request.url.path;
      if (path == '/bangumi/2222') {
        return http.Response(
          jsonEncode({'title': 'Test'}),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }
      if (path == '/bangumi/2222/points/detail') {
        return http.Response(
          jsonEncode([
            {
              'id': 'p1',
              'name': 'Spot',
              'geo': [35.0, 135.0],
              'image': 'https://image.anitabi.cn/broken.jpg',
              's': 0,
              'ep': 1,
            },
          ]),
          200,
        );
      }
      // image download fails
      return http.Response('boom', 500);
    });

    final result = await AnitabiApiService.importBangumiSubject(
      db,
      '2222',
      client: mock,
    );

    expect(result!.poisImported, 1);
    expect(result.coversPending, 1);
    expect(await result.coverDownloadCompletion, 0);

    final pois = await db.getAllPois();
    expect(pois.first.coverImageUri,
        startsWith('https://image.anitabi.cn/'));
  });

  test('importBangumiSubject returns null on empty point list', () async {
    final mock = MockClient((request) async {
      if (request.url.path == '/bangumi/9999') {
        return http.Response(jsonEncode({'title': 'Empty'}), 200);
      }
      return http.Response(jsonEncode(const []), 200);
    });

    final result = await AnitabiApiService.importBangumiSubject(
      db,
      '9999',
      client: mock,
    );

    expect(result, isNull);
  });
}
