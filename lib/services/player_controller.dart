import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import 'youtube_music_service.dart';

/// Controla la reproduccion real de audio. Vive en HomeShell (no en la
/// pantalla del reproductor) para que la musica siga sonando -y el
/// mini-reproductor se mantenga sincronizado- sin importar que pantalla
/// este viendo el usuario.
class PlayerController extends ChangeNotifier {
  PlayerController(this._musicService) : _audioPlayer = AudioPlayer() {
    _stateSub = _audioPlayer.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  final YoutubeMusicService _musicService;
  final AudioPlayer _audioPlayer;
  late final StreamSubscription<PlayerState> _stateSub;

  Song? _currentSong;
  Song? get currentSong => _currentSong;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool get isPlaying => _audioPlayer.playing;
  double get volume => _audioPlayer.volume;
  Duration get position => _audioPlayer.position;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Future<void> play(Song song) async {
    _currentSong = song;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _musicService.getAudioUrl(song.id);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {
      _error = 'No se pudo reproducir esta cancion';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  Future<void> setVolume(double volume) => _audioPlayer.setVolume(volume);

  @override
  void dispose() {
    _stateSub.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
