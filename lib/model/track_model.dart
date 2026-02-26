class Track {
  final String trackName;
  final String artistName;
  final String albumName;
  final String artworkUrl;
  final int trackTimeMillis;
  String? lyrics;

  Track({
    required this.trackName,
    required this.artistName,
    required this.albumName,
    required this.artworkUrl,
    required this.trackTimeMillis,
    this.lyrics,
  });

  factory Track.fromJson(Map<String, dynamic> json) => Track(
    trackName: json['trackName'] ?? '',
    artistName: json['artistName'] ?? '',
    albumName: json['collectionName'] ?? '',
    artworkUrl: (json['artworkUrl100'] ?? '').replaceAll('100x100', '60x60'),
    trackTimeMillis: json['trackTimeMillis'] ?? 0,
    lyrics: json['lyrics'] ?? '',
  );
}