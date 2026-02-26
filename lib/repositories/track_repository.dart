import '../model/track_model.dart';
import '../services/deezer_service.dart';

class TrackRepository {
  final ItunesService _service;

  TrackRepository(this._service);

  Future<List<Track>> getTracks(String query, {int offset = 0}) async {
    return await _service.fetchTracks(query, offset: offset);
  }
}