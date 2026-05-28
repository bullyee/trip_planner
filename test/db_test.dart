import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/core/utils/json_sync.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Anitabi dedup by bangumi_id', () {
    test('second upsert with same bangumi_id returns same anime row', () async {
      final id1 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'K-On!',
      );
      final id2 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'けいおん！',
      );

      expect(id1, equals(id2));

      final all = await db.getAllAnimes();
      expect(all.length, 1, reason: 'should not create a second row');
      expect(all.first.name, 'K-On!',
          reason: 'first name wins; upsert is no-op when exists');
      expect(all.first.bangumiId, '1424');
    });

    test('different bangumi_ids create independent rows', () async {
      await db.upsertAnimeByBangumiId(bangumiId: '1424', name: 'K-On!');
      await db.upsertAnimeByBangumiId(bangumiId: '17288', name: 'Hibike!');

      final all = await db.getAllAnimes();
      expect(all.length, 2);
      expect(all.map((a) => a.bangumiId).toSet(), {'1424', '17288'});
    });
  });

  group('JsonSync legacy v1 import', () {
    test(
        'reconstructs Animes / Tags rows and PoiAnimes / PoiTags junctions '
        'from anime_series_ref + comma-separated tags', () async {
      const v1Json = '''
      {
        "export_version": "1.0",
        "rois": [
          {
            "id": "roi-toyosato",
            "name": "Toyosato",
            "description": null,
            "is_offline_cached": 0,
            "created_at": 1700000000000,
            "pois": [
              {
                "id": "poi-1",
                "name": "Elementary School",
                "lat": 35.1234,
                "lng": 136.5678,
                "anime_series_ref": "K-On!",
                "tags": "school, Anitabi",
                "description": null,
                "address": null,
                "business_hours": null,
                "contact_info": null,
                "cover_image_uri": null,
                "time_chunks": [],
                "media_assets": []
              },
              {
                "id": "poi-2",
                "name": "Toyosato Station",
                "lat": 35.1240,
                "lng": 136.5700,
                "anime_series_ref": "K-On!",
                "tags": "station",
                "description": null,
                "address": null,
                "business_hours": null,
                "contact_info": null,
                "cover_image_uri": null,
                "time_chunks": [],
                "media_assets": []
              }
            ]
          }
        ]
      }
      ''';

      await JsonSync(db).importFromJson(v1Json);

      final animes = await db.getAllAnimes();
      expect(animes.length, 1,
          reason: 'two POIs reference the same anime name -> one Anime row');
      expect(animes.first.name, 'K-On!');

      final tags = await db.getAllTags();
      expect(tags.length, 3);
      expect(tags.map((t) => t.name).toSet(), {'school', 'Anitabi', 'station'});

      final pois = await db.getAllPois();
      expect(pois.length, 2);

      final poi1Animes = await db.watchAnimesForPoi('poi-1').first;
      expect(poi1Animes.length, 1);
      expect(poi1Animes.first.name, 'K-On!');

      final poi1Tags = await db.watchTagsForPoi('poi-1').first;
      expect(poi1Tags.map((t) => t.name).toSet(), {'school', 'Anitabi'});

      final poi2Tags = await db.watchTagsForPoi('poi-2').first;
      expect(poi2Tags.map((t) => t.name).toSet(), {'station'});
    });

    test('handles POI with no anime / no tags without throwing', () async {
      const v1Json = '''
      {
        "export_version": "1.0",
        "rois": [
          {
            "id": "r1",
            "name": "Akiba",
            "is_offline_cached": 0,
            "created_at": 1,
            "pois": [
              {
                "id": "p1",
                "name": "Some POI",
                "lat": 35.7,
                "lng": 139.7,
                "anime_series_ref": null,
                "tags": null,
                "time_chunks": [],
                "media_assets": []
              }
            ]
          }
        ]
      }
      ''';

      await JsonSync(db).importFromJson(v1Json);

      expect((await db.getAllAnimes()).length, 0);
      expect((await db.getAllTags()).length, 0);

      final pois = await db.getAllPois();
      expect(pois.length, 1);
      expect(pois.first.roiId, 'r1');
    });
  });

  group('v2 round-trip', () {
    test('export then import yields identical entity counts', () async {
      // Seed
      await db.upsertAnimeByBangumiId(bangumiId: '1424', name: 'K-On!');
      final animeId = (await db.getAllAnimes()).first.id;

      await db.insertRoi(RoisCompanion.insert(
        id: 'roi-1',
        name: 'Toyosato',
        createdAt: 1,
      ));

      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-1',
        name: 'School',
        lat: 35.1,
        lng: 136.2,
      ));

      await db.addAnimeToPoi('poi-1', animeId);

      final exported = await JsonSync(db).exportToJson();

      // Fresh DB
      await db.close();
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await JsonSync(db).importFromJson(exported);

      expect((await db.getAllAnimes()).length, 1);
      expect((await db.getAllRois()).length, 1);
      expect((await db.getAllPois()).length, 1);

      final animes = await db.watchAnimesForPoi('poi-1').first;
      expect(animes.length, 1);
      expect(animes.first.name, 'K-On!');
    });
  });
}
