import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/player_controller.dart';
import '../services/youtube_music_service.dart';
import '../widgets/mini_player.dart';
import '../widgets/pill_dock.dart';
import 'library_screen.dart';
import 'personalization_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';

/// Cascaron principal: arma el dock inferior en forma de pildora y alterna
/// entre Buscar / Biblioteca / Personalizar. El servicio de YouTube Music
/// y el controlador de reproduccion viven aca (no en cada pantalla) para
/// que la musica siga sonando al navegar entre secciones.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final YoutubeMusicService _musicService;
  late final PlayerController _playerController;

  static const _dockItems = [
    DockItem(
      icon: Icons.search_rounded,
      selectedIcon: Icons.search_rounded,
      label: 'Buscar',
    ),
    DockItem(
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music_rounded,
      label: 'Biblioteca',
    ),
    DockItem(
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette_rounded,
      label: 'Personalizar',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _musicService = YoutubeMusicService();
    _playerController = PlayerController(_musicService);
  }

  @override
  void dispose() {
    _playerController.dispose();
    _musicService.dispose();
    super.dispose();
  }

  void _openPlayer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) =>
            PlayerScreen(controller: _playerController),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  void _playSong(Song song) {
    _playerController.play(song);
    _openPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      SearchScreen(musicService: _musicService, onSongSelected: _playSong),
      LibraryScreen(onSongSelected: _playSong),
      const PersonalizationScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AnimatedBuilder(
        animation: _playerController,
        builder: (context, _) {
          final nowPlaying = _playerController.currentSong;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nowPlaying != null)
                MiniPlayer(
                  song: nowPlaying,
                  isPlaying: _playerController.isPlaying,
                  onTap: _openPlayer,
                  onPlayPause: _playerController.togglePlayPause,
                ),
              PillDock(
                items: _dockItems,
                currentIndex: _index,
                onSelected: (i) => setState(() => _index = i),
              ),
            ],
          );
        },
      ),
    );
  }
}
