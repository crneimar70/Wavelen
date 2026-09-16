import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/player_controller.dart';
import '../state/app_settings.dart';

/// Reproductor a pantalla completa: fondo desenfocado con el color tomado
/// de la portada, controles y un panel de letra alternable. Todo lo que
/// muestra sale del PlayerController compartido (mismo que usa el
/// mini-reproductor), asi que refleja el estado real de la reproduccion.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.controller});

  final PlayerController controller;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  ColorScheme? _dynamicScheme;
  String? _coverForScheme;
  bool _showLyrics = false;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.controller.volume;
    widget.controller.addListener(_onControllerChanged);
    _maybeLoadDynamicScheme();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _maybeLoadDynamicScheme();
    setState(() {});
  }

  Future<void> _maybeLoadDynamicScheme() async {
    final song = widget.controller.currentSong;
    if (song == null) return;
    if (song.coverUrl == _coverForScheme) return;
    _coverForScheme = song.coverUrl;
    try {
      final scheme = await ColorScheme.fromImageProvider(
        provider: NetworkImage(song.coverUrl),
        brightness: Brightness.dark,
      );
      if (mounted) setState(() => _dynamicScheme = scheme);
    } catch (_) {
      // Si falla (ej. sin conexion), seguimos con el tema normal.
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _lyricIndexFor(Song song, Duration position, Duration total) {
    final lyrics = song.lyrics;
    if (lyrics.isEmpty || total.inMilliseconds <= 0) return -1;
    final perLine = total.inMilliseconds / lyrics.length;
    final idx = (position.inMilliseconds / perLine).floor();
    return idx.clamp(0, lyrics.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.controller.currentSong;
    if (song == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Nada sonando todavia',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final settings = AppSettingsScope.of(context);
    final baseScheme = Theme.of(context).colorScheme;
    final scheme =
        settings.useAlbumArtColor ? (_dynamicScheme ?? baseScheme) : baseScheme;
    final blur = 20 + settings.blurIntensity * 60;

    return Theme(
      data: Theme.of(context).copyWith(colorScheme: scheme),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(song.coverUrl, fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    scheme.primary.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  if (widget.controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  if (widget.controller.error != null)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        widget.controller.error!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: _showLyrics
                        ? _buildLyrics(context, song)
                        : _buildCoverAndInfo(context, song),
                  ),
                  _buildProgress(context, song),
                  _buildControls(context),
                  _buildVolume(context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showLyrics
                  ? Icons.auto_awesome_rounded
                  : Icons.auto_awesome_outlined,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showLyrics = !_showLyrics),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverAndInfo(BuildContext context, Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(song.coverUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            song.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            song.artist,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyrics(BuildContext context, Song song) {
    if (song.lyrics.isEmpty) {
      return const Center(
        child: Text(
          'Sin letra disponible todavia',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return StreamBuilder<Duration>(
      stream: widget.controller.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final total = widget.controller.duration;
        final current = _lyricIndexFor(song, position, total);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          itemCount: song.lyrics.length,
          itemBuilder: (context, index) {
            final distance = (index - current).abs();
            final double opacity;
            if (distance == 0) {
              opacity = 1.0;
            } else if (distance == 1) {
              opacity = 0.55;
            } else if (distance == 2) {
              opacity = 0.3;
            } else {
              opacity = 0.15;
            }
            final scale = distance == 0 ? 1.0 : 0.92;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: opacity,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    song.lyrics[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: distance == 0 ? 26 : 20,
                      fontWeight:
                          distance == 0 ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgress(BuildContext context, Song song) {
    return StreamBuilder<Duration>(
      stream: widget.controller.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        var total = widget.controller.duration;
        if (total <= Duration.zero) total = song.duration;
        final maxMs = total.inMilliseconds > 0
            ? total.inMilliseconds.toDouble()
            : 1.0;
        final posMs =
            position.inMilliseconds.toDouble().clamp(0.0, maxMs);
        final remaining = total > position ? total - position : Duration.zero;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: posMs,
                  max: maxMs,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (v) =>
                      widget.controller.seek(Duration(milliseconds: v.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(position),
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('-${_fmt(remaining)}',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    final isPlaying = widget.controller.isPlaying;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.shuffle_rounded, color: Colors.white70),
          const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 34),
          GestureDetector(
            onTap: widget.controller.togglePlayPause,
            child: Container(
              width: 66,
              height: 66,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 34,
              ),
            ),
          ),
          const Icon(Icons.skip_next_rounded, color: Colors.white, size: 34),
          const Icon(Icons.repeat_rounded, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildVolume(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          const Icon(Icons.volume_down_rounded, color: Colors.white70, size: 20),
          Expanded(
            child: Slider(
              value: _volume,
              onChanged: (v) {
                setState(() => _volume = v);
                widget.controller.setVolume(v);
              },
              activeColor: Colors.white54,
              inactiveColor: Colors.white24,
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}
