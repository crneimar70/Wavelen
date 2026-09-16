import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

/// Capa que reemplaza los datos de muestra por resultados reales.
/// Mismo enfoque que Metrolist: en vez de la API oficial de YouTube Data
/// (con cuota limitada), se resuelve todo -busqueda y audio- a traves de
/// los endpoints internos que ya usa el propio sitio de YouTube.
class YoutubeMusicService {
  YoutubeMusicService() : _yt = YoutubeExplode();

  final YoutubeExplode _yt;

  Future<List<Song>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final results = await _yt.search.search(query);
    return results
        .map(
          (video) => Song(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            coverUrl: video.thumbnails.highResUrl,
            duration: video.duration ?? Duration.zero,
          ),
        )
        .toList();
  }

  /// Resuelve la URL de audio reproducible para una cancion. Se pide justo
  /// antes de reproducir: las URLs de YouTube expiran despues de un rato,
  /// asi que no conviene guardarlas de antemano.
  Future<String> getAudioUrl(String videoId) async {
    final manifest = await _yt.videos.streams.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.ios, YoutubeApiClient.androidVr],
    );
    final audio = manifest.audioOnly.withHigestBitrate();
    return audio.url.toString();
  }

  void dispose() => _yt.close();
}
