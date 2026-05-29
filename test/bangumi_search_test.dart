import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trip_planner/features/anime/services/bangumi_search_service.dart';

http.Response _jsonBytes(Object body, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
    );

void main() {
  group('BangumiSearchService.searchByName', () {
    test('parses a realistic K-On search response', () async {
      final calls = <String>[];
      final mock = MockClient((request) async {
        calls.add('${request.method} ${request.url}');
        return _jsonBytes({
          'data': [
            {
              'id': 1424,
              'name': 'けいおん！',
              'name_cn': '轻音少女',
              'platform': 'TV',
              'date': '2009-04-02',
              'summary': 'A K-On summary',
              'images': {
                'medium': 'https://lain.bgm.tv/m/1424.jpg',
                'common': 'https://lain.bgm.tv/c/1424.jpg',
              },
              'rating': {'score': 8.3},
            },
            {
              'id': 12426,
              'name': '映画けいおん！',
              'name_cn': '轻音少女 剧场版',
              'platform': '剧场版',
              'date': '2011-12-03',
              'images': {'medium': 'https://lain.bgm.tv/m/12426.jpg'},
              'rating': {'score': 8.4},
            },
            // entry without a usable id should be skipped
            {'name': 'no-id'},
            // entry without a name should be skipped
            {'id': 999},
          ],
          'total': 4,
          'limit': 5,
          'offset': 0,
        }, 200);
      });

      final results = await BangumiSearchService.searchByName(
        'K-On',
        client: mock,
      );

      expect(results, hasLength(2), reason: 'mock calls: $calls');
      expect(calls, hasLength(1));
      expect(calls.first.startsWith('POST https://api.bgm.tv/v0/search/subjects'),
          isTrue);
      expect(results[0].id, '1424');
      expect(results[0].name, 'けいおん！');
      expect(results[0].nameCn, '轻音少女');
      expect(results[0].platform, 'TV');
      expect(results[0].date, '2009-04-02');
      expect(results[0].imageUrl, 'https://lain.bgm.tv/m/1424.jpg');
      expect(results[0].score, 8.3);
      expect(results[1].id, '12426');
      expect(results[1].nameCn, '轻音少女 剧场版');
    });

    test('returns empty list on HTTP 500', () async {
      final mock = MockClient(
        (request) async => http.Response('server error', 500),
      );

      final results = await BangumiSearchService.searchByName(
        'anything',
        client: mock,
      );

      expect(results, isEmpty);
    });

    test('returns empty list on malformed JSON without throwing', () async {
      final mock = MockClient(
        (request) async => http.Response('not json {{{', 200),
      );

      final results = await BangumiSearchService.searchByName(
        'anything',
        client: mock,
      );

      expect(results, isEmpty);
    });

    test('returns empty list for empty keyword', () async {
      // Should never hit the network at all.
      var called = false;
      final mock = MockClient((_) async {
        called = true;
        return http.Response('', 200);
      });
      final results = await BangumiSearchService.searchByName(
        '  ',
        client: mock,
      );
      expect(results, isEmpty);
      expect(called, isFalse);
    });
  });
}
