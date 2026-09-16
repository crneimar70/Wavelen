import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/song.dart';
import '../widgets/mini_player.dart';
import '../widgets/pill_dock.dart';
import 'library_screen.dart';
import 'personalization_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';

/// Cascaron principal: arma el dock inferior en forma de pildora y alterna
/// entre Buscar / Biblioteca / Personalizar, ademas del mini-reproductor.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  Song? _nowPlaying = sampleSongs.first;

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

  void _openPlayer() {
    final song = _nowPlaying;
    if (song == null) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => PlayerScreen(song: song),
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
    setState(() => _nowPlaying = song);
    _openPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      SearchScreen(onSongSelected: _playSong),
      LibraryScreen(onSongSelected: _playSong),
      const PersonalizationScreen(),
    ];

    final nowPlaying = _nowPlaying;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (nowPlaying != null)
            MiniPlayer(song: nowPlaying, onTap: _openPlayer),
          PillDock(
            items: _dockItems,
            currentIndex: _index,
            onSelected: (i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}
