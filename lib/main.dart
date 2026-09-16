import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'state/app_settings.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WavelenApp());
}

class WavelenApp extends StatefulWidget {
  const WavelenApp({super.key});

  @override
  State<WavelenApp> createState() => _WavelenAppState();
}

class _WavelenAppState extends State<WavelenApp> {
  final AppSettings _settings = AppSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        return AppSettingsScope(
          settings: _settings,
          child: MaterialApp(
            title: 'Wavelen',
            debugShowCheckedModeBanner: false,
            themeMode: _settings.themeMode,
            theme: WavelenTheme.build(
              seedColor: _settings.seedColor,
              brightness: Brightness.light,
            ),
            darkTheme: WavelenTheme.build(
              seedColor: _settings.seedColor,
              brightness: Brightness.dark,
            ),
            home: const HomeShell(),
          ),
        );
      },
    );
  }
}
