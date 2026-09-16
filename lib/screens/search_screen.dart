import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/song.dart';
import '../widgets/glass_panel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.onSongSelected});

  final ValueChanged<Song> onSongSelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Song> _results = sampleSongs;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _results = query.isEmpty
          ? sampleSongs
          : sampleSongs
              .where((s) =>
                  s.title.toLowerCase().contains(query.toLowerCase()) ||
                  s.artist.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buscar', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 14),
                  GlassPanel(
                    borderRadius: BorderRadius.circular(30),
                    blurSigma: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _controller,
                      onChanged: _onQueryChanged,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Canciones, artistas o albumes',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _controller.clear();
                                  _onQueryChanged('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    children: ['Pop', 'Regueton', 'Rock', 'Lo-fi', 'Trap']
                        .map(
                          (g) => ActionChip(
                            label: Text(g),
                            onPressed: () {
                              _controller.text = g;
                              _onQueryChanged(g);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 140),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = _results[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      onTap: () => widget.onSongSelected(song),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.coverUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.play_circle_fill_rounded,
                        color: scheme.primary,
                      ),
                    ),
                  );
                },
                childCount: _results.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
