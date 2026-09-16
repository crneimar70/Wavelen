import 'package:flutter/material.dart';

/// Preferencias visuales de la app (color de acento, tema, intensidad del
/// blur, si el reproductor usa el color de la portada). Se expone al arbol
/// de widgets mediante [AppSettingsScope].
class AppSettings extends ChangeNotifier {
  AppSettings({
    Color seedColor = const Color(0xFF6750A4),
    this.themeMode = ThemeMode.system,
    double blurIntensity = 0.7,
    this.useAlbumArtColor = true,
  })  : _seedColor = seedColor,
        _blurIntensity = blurIntensity;

  Color _seedColor;
  Color get seedColor => _seedColor;
  set seedColor(Color value) {
    if (value == _seedColor) return;
    _seedColor = value;
    notifyListeners();
  }

  ThemeMode themeMode;
  void setThemeMode(ThemeMode mode) {
    if (mode == themeMode) return;
    themeMode = mode;
    notifyListeners();
  }

  double _blurIntensity;
  double get blurIntensity => _blurIntensity;
  set blurIntensity(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped == _blurIntensity) return;
    _blurIntensity = clamped;
    notifyListeners();
  }

  bool useAlbumArtColor;
  void setUseAlbumArtColor(bool value) {
    if (value == useAlbumArtColor) return;
    useAlbumArtColor = value;
    notifyListeners();
  }
}

/// Provee la instancia unica de [AppSettings] a toda la app.
class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope no encontrado en el arbol');
    return scope!.notifier!;
  }
}
