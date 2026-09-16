class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.duration,
    this.lyrics = const [],
  });

  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final Duration duration;

  /// Letra linea por linea. Placeholder hasta conectar una fuente real.
  final List<String> lyrics;
}
