import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/track_model.dart';

class ItunesService {
  Future<List<Track>> fetchTracks(String query, {int offset = 0}) async {
    final uri = Uri.https(
      'itunes.apple.com',
      '/search',
      {
        'term': query,
        'media': 'music',
        'entity': 'song',
        'limit': '50',
        'offset': offset.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final results = jsonData['results'] as List<dynamic>? ?? [];
      return results.map((e) => Track.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tracks: ${response.statusCode}');
    }
  }
}