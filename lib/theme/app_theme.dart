import 'package:flutter/material.dart';

/// Tema "Material 3 Expressive" de Wavelen: parte del Material 3 estandar
/// de Flutter pero con formas mas redondeadas (pildora), tipografia mas
/// marcada y superficies mas separadas, para acercarse al lenguaje visual
/// expressive de Android.
class WavelenTheme {
  const WavelenTheme._();

  static ThemeData build({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: colorScheme.surface,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

/// Paleta de colores semilla que se ofrece en la pantalla de
/// personalizacion.
const List<Color> wavelenSeedPalette = [
  Color(0xFF6750A4), // violeta (Material por defecto)
  Color(0xFFEF5DA8), // rosa
  Color(0xFF3E7BFA), // azul
  Color(0xFF00A389), // verde azulado
  Color(0xFFFF7A45), // naranja
  Color(0xFFE64A4A), // rojo
  Color(0xFFFFC107), // ambar
  Color(0xFF8D6E63), // marron
];
