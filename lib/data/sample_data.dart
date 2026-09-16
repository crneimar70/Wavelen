import '../models/playlist.dart';
import '../models/song.dart';

/// Letra de ejemplo (no pertenece a ninguna cancion real): solo sirve para
/// probar el scroll y el resaltado de la linea actual en el reproductor.
const List<String> _sampleLyrics = [
  'Esta es la primera linea de muestra',
  'Todavia no hay letras reales conectadas',
  'Cuando conectemos la API, esto vendra de ahi',
  'Por ahora sirve para probar el diseno',
  'La linea actual se ve mas grande y clara',
  'Las lineas lejanas se ven mas tenues',
  'Asi se sentira el scroll de la letra',
  'Ultimo renglon de la letra de ejemplo',
];

final List<Song> sampleSongs = [
  Song(
    id: 's1',
    title: 'Cancion de ejemplo uno',
    artist: 'Artista Demo',
    coverUrl: 'https://picsum.photos/seed/wavelen1/600',
    duration: const Duration(minutes: 3, seconds: 12),
    lyrics: _sampleLyrics,
  ),
  Song(
    id: 's2',
    title: 'Segunda pista de prueba',
    artist: 'Banda Ficticia',
    coverUrl: 'https://picsum.photos/seed/wavelen2/600',
    duration: const Duration(minutes: 2, seconds: 48),
    lyrics: _sampleLyrics,
  ),
  Song(
    id: 's3',
    title: 'Ritmo de muestra',
    artist: 'DJ Ejemplo',
    coverUrl: 'https://picsum.photos/seed/wavelen3/600',
    duration: const Duration(minutes: 3, seconds: 40),
    lyrics: _sampleLyrics,
  ),
  Song(
    id: 's4',
    title: 'Melodia placeholder',
    artist: 'Grupo Prueba',
    coverUrl: 'https://picsum.photos/seed/wavelen4/600',
    duration: const Duration(minutes: 4, seconds: 5),
    lyrics: _sampleLyrics,
  ),
];

final List<Playlist> samplePlaylists = [
  Playlist(
    id: 'p1',
    name: 'Favoritas',
    coverUrl: 'https://picsum.photos/seed/wavelenp1/600',
    songs: sampleSongs,
  ),
  Playlist(
    id: 'p2',
    name: 'Para estudiar',
    coverUrl: 'https://picsum.photos/seed/wavelenp2/600',
    songs: sampleSongs.take(2).toList(),
  ),
  Playlist(
    id: 'p3',
    name: 'Recien agregadas',
    coverUrl: 'https://picsum.photos/seed/wavelenp3/600',
    songs: sampleSongs.reversed.toList(),
  ),
];
