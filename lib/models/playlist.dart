import 'song.dart';

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.songs,
  });

  final String id;
  final String name;
  final String coverUrl;
  final List<Song> songs;
}
