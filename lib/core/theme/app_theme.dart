import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_palette.dart';

final themeVariantProvider = NotifierProvider<ThemeVariantController, ThemeVariant>(
  ThemeVariantController.new,
);

class ThemeVariantController extends Notifier<ThemeVariant> {
  @override
  ThemeVariant build() => ThemeVariant.felt;

  void select(ThemeVariant variant) => state = variant;

  void next() => state = ThemeVariant.values[(state.index + 1) % ThemeVariant.values.length];
}

abstract final class GameType {
  static TextStyle display(double size, Color color) =>
      GoogleFonts.jersey10(fontSize: size, color: color, height: 1, letterSpacing: size * 0.06);

  static TextStyle tile(double size, Color color) => GoogleFonts.inter(
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w700,
    height: 1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

ThemeData buildGameTheme(ThemeVariant variant) {
  final p = GamePalette.forVariant(variant);
  final scheme = ColorScheme.dark(
    primary: p.gold,
    onPrimary: p.ink,
    secondary: p.blue,
    onSecondary: p.ink,
    error: p.red,
    onError: p.text,
    surface: p.panel,
    onSurface: p.text,
    onSurfaceVariant: p.textMuted,
    outline: p.border,
    outlineVariant: p.border,
  );
  final base = ThemeData(colorScheme: scheme, brightness: Brightness.dark);

  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    extensions: [p],
    textTheme: _interTextTheme(base.textTheme).apply(bodyColor: p.text, displayColor: p.text),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.panel,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: GoogleFonts.inter(color: p.text, fontSize: 12),
    ),
    focusColor: p.blue.withValues(alpha: 0.25),
    hoverColor: p.blue.withValues(alpha: 0.08),
    splashFactory: NoSplash.splashFactory,
  );
}

TextTheme _interTextTheme(TextTheme t) {
  TextStyle? inter(TextStyle? style) => GoogleFonts.inter(textStyle: style);
  return TextTheme(
    displayLarge: inter(t.displayLarge),
    displayMedium: inter(t.displayMedium),
    displaySmall: inter(t.displaySmall),
    headlineLarge: inter(t.headlineLarge),
    headlineMedium: inter(t.headlineMedium),
    headlineSmall: inter(t.headlineSmall),
    titleLarge: inter(t.titleLarge),
    titleMedium: inter(t.titleMedium),
    titleSmall: inter(t.titleSmall),
    bodyLarge: inter(t.bodyLarge),
    bodyMedium: inter(t.bodyMedium),
    bodySmall: inter(t.bodySmall),
    labelLarge: inter(t.labelLarge),
    labelMedium: inter(t.labelMedium),
    labelSmall: inter(t.labelSmall),
  );
}
