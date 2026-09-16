import 'package:flutter/material.dart';

import '../state/app_settings.dart';
import '../theme/app_theme.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
        children: [
          Text('Personalizar', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Color de acento', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: wavelenSeedPalette.map((color) {
              final selected = settings.seedColor == color;
              return GestureDetector(
                onTap: () => settings.seedColor = color,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: scheme.onSurface, width: 3)
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Sistema'),
                icon: Icon(Icons.brightness_auto_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Claro'),
                icon: Icon(Icons.light_mode_rounded),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Oscuro'),
                icon: Icon(Icons.dark_mode_rounded),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (set) => settings.setThemeMode(set.first),
          ),
          const SizedBox(height: 32),
          Text(
            'Vidrio esmerilado (blur)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: settings.blurIntensity,
            onChanged: (v) => settings.blurIntensity = v,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Color dinamico segun la portada'),
            subtitle:
                const Text('El reproductor toma sus colores de cada cancion'),
            value: settings.useAlbumArtColor,
            onChanged: settings.setUseAlbumArtColor,
          ),
        ],
      ),
    );
  }
}
