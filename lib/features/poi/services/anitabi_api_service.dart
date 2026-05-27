import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:trip_planner/core/database/database.dart';


class AnitabiApiService {
  static const String _apiBaseUrl = 'https://api.anitabi.cn';

  // Return a list of PoisCompanion instead of void
  static Future<List<PoisCompanion>> fetchAndImportPois(String subjectId) async {
    final url = Uri.parse('$_apiBaseUrl/bangumi/$subjectId/points/detail?haveImage=true');
    List<PoisCompanion> fetchedPois = []; // Initialize an empty list to store data

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));

        for (var json in jsonList) {
          String imageUrl = json['image'] ?? '';
          imageUrl = imageUrl.replaceAll('?plan=h160', '?plan=h360');

          int seconds = json['s'] ?? 0;
          String timeString = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

          String origin = json['origin'] ?? 'Unknown';
          String originUrl = json['originURL'] ?? '';
          String descriptionText = 'Ep ${json['ep']} - $timeString\nSource: $origin\n$originUrl'.trim();

          final companion = PoisCompanion(
            id: Value(json['id'].toString()), 
            name: Value(json['cn'] ?? json['name'] ?? 'Unknown POI'),
            lat: Value(json['geo'][0].toDouble()),
            lng: Value(json['geo'][1].toDouble()),
            animeSeriesRef: Value(subjectId), 
            coverImageUri: Value(imageUrl),
            description: Value(descriptionText),
            address: const Value(''),
            businessHours: const Value(''),
            contactInfo: const Value(''),
            tags: const Value('Anitabi'),
          );

          // Add the parsed object to the list
          fetchedPois.add(companion); 
        }
      }
    } catch (e) {
      // Silently handle errors, will return an empty list
    }
    
    return fetchedPois; // Return the complete list of POIs
  }
}