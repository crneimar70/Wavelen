import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/song.dart';
import '../state/app_settings.dart';

/// Reproductor a pantalla completa: fondo desenfocado con el color tomado
/// de la portada, controles y un panel de letra alternable. La reproduccion
/// real todavia no esta conectada: el avance del tiempo es simulado con un
/// Timer para poder probar el diseno.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.song});

  final Song song;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  ColorScheme? _dynamicScheme;
  bool _showLyrics = false;
  bool _isPlaying = true;
  Duration _position = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadDynamicScheme();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying) return;
      setState(() {
        _position += const Duration(seconds: 1);
        if (_position >= widget.song.duration) {
          _position = Duration.zero;
        }
      });
    });
  }

  Future<void> _loadDynamicScheme() async {
    try {
      final scheme = await ColorScheme.fromImageProvider(
        provider: NetworkImage(widget.song.coverUrl),
        brightness: Brightness.dark,
      );
      if (mounted) setState(() => _dynamicScheme = scheme);
    } catch (_) {
      // Si falla (ej. sin conexion), seguimos con el tema normal.
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _currentLyricIndex {
    final lyrics = widget.song.lyrics;
    if (lyrics.isEmpty) return -1;
    final perLine = widget.song.duration.inMilliseconds / lyrics.length;
    final idx = (_position.inMilliseconds / perLine).floor();
    return idx.clamp(0, lyrics.length - 1);
  }

  @override
  Widget build(BuildContext context) {
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
            Image.network(widget.song.coverUrl, fit: BoxFit.cover),
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
                  Expanded(
                    child: _showLyrics
                        ? _buildLyrics(context)
                        : _buildCoverAndInfo(context),
                  ),
                  _buildProgress(context),
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
              _showLyrics ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showLyrics = !_showLyrics),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverAndInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(widget.song.coverUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.song.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.song.artist,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLyrics(BuildContext context) {
    final lyrics = widget.song.lyrics;
    if (lyrics.isEmpty) {
      return const Center(
        child: Text(
          'Sin letra disponible todavia',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final current = _currentLyricIndex;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      itemCount: lyrics.length,
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
                lyrics[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: distance == 0 ? 26 : 20,
                  fontWeight: distance == 0 ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(BuildContext context) {
    final total = widget.song.duration;
    final maxMs = total.inMilliseconds.toDouble();
    final posMs = _position.inMilliseconds.toDouble().clamp(0.0, maxMs);

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
                  setState(() => _position = Duration(milliseconds: v.toInt())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('-${_fmt(total - _position)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.shuffle_rounded, color: Colors.white70),
          const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 34),
          GestureDetector(
            onTap: () => setState(() => _isPlaying = !_isPlaying),
            child: Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
    // Slider decorativo por ahora: se conecta cuando haya audio real.
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Icon(Icons.volume_down_rounded, color: Colors.white70, size: 20),
          Expanded(
            child: Slider(
              value: 0.7,
              onChanged: null,
              activeColor: Colors.white54,
              inactiveColor: Colors.white24,
            ),
          ),
          Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}
