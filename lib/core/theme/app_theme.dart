import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../settings/app_settings.dart';
import 'game_palette.dart';

abstract final class GameType {
  static TextStyle display(double size, Color color) =>
      GoogleFonts.jersey10(fontSize: size, color: color, height: 1, letterSpacing: size * 0.06);

  /// Peças (dígitos e operadores) na mesma fonte pixel do título.
  /// Os símbolos que a fonte não tem (√, ∛, ⌊⌋, ⌈⌉) são desenhados à mão em
  /// `PixelGlyph`.
  static TextStyle tile(double size, Color color) => GoogleFonts.jersey10(fontSize: size, color: color, height: 1);
}

/// Paleta efetiva: tema pronto + claro/escuro + cor semente.
GamePalette resolvePalette(AppSettings settings, Brightness brightness) {
  final base = GamePalette.forVariant(settings.variant, brightness: brightness);
  final accent = settings.accent.color;
  return accent == null ? base : base.withAccent(accent);
}

/// Tema do app para um brilho (claro ou escuro), a partir das configurações.
///
/// O acento da paleta é a cor semente do [ColorScheme]: os componentes do
/// Material (campos do login, diálogos, seleção) derivam dela.
ThemeData buildGameTheme(AppSettings settings, Brightness brightness) {
  final p = resolvePalette(settings, brightness);
  final scheme = ColorScheme.fromSeed(seedColor: p.gold, brightness: brightness).copyWith(
    primary: p.gold,
    onPrimary: p.ink,
    error: p.red,
    onError: GamePalette.onColor(p.red),
    surface: p.panel,
    onSurface: p.text,
    onSurfaceVariant: p.textMuted,
    outline: p.border,
    outlineVariant: p.border,
  );
  final base = ThemeData(colorScheme: scheme, brightness: brightness);
  TextStyle? font(TextStyle? style) => GoogleFonts.getFont(settings.fontFamily, textStyle: style);

  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    extensions: [p],
    textTheme: _textTheme(base.textTheme, font).apply(bodyColor: p.text, displayColor: p.text),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: font(TextStyle(color: p.text, fontSize: 12)),
    ),
    focusColor: p.blue.withValues(alpha: 0.25),
    hoverColor: p.blue.withValues(alpha: 0.08),
    splashFactory: NoSplash.splashFactory,
  );
}

TextTheme _textTheme(TextTheme t, TextStyle? Function(TextStyle?) font) => TextTheme(
  displayLarge: font(t.displayLarge),
  displayMedium: font(t.displayMedium),
  displaySmall: font(t.displaySmall),
  headlineLarge: font(t.headlineLarge),
  headlineMedium: font(t.headlineMedium),
  headlineSmall: font(t.headlineSmall),
  titleLarge: font(t.titleLarge),
  titleMedium: font(t.titleMedium),
  titleSmall: font(t.titleSmall),
  bodyLarge: font(t.bodyLarge),
  bodyMedium: font(t.bodyMedium),
  bodySmall: font(t.bodySmall),
  labelLarge: font(t.labelLarge),
  labelMedium: font(t.labelMedium),
  labelSmall: font(t.labelSmall),
);
