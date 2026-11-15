import 'package:flutter/material.dart';

enum ThemeVariant { felt, cosmic, minimal }

enum PatternStyle { none, lines, flames }

@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  const GamePalette({
    required this.background,
    required this.backgroundDeep,
    required this.well,
    required this.panel,
    required this.panelRaised,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.gold,
    required this.red,
    required this.blue,
    required this.tileFace,
    required this.tileEdge,
    required this.tileInk,
    required this.operatorFace,
    required this.operatorEdge,
    required this.equalsFace,
    required this.equalsEdge,
    required this.ink,
    required this.pattern,
    required this.patternColor,
  });

  final Color background;
  final Color backgroundDeep;
  final Color well;
  final Color panel;
  final Color panelRaised;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textMuted;
  final Color gold;
  final Color red;
  final Color blue;
  final Color tileFace;
  final Color tileEdge;
  final Color tileInk;
  final Color operatorFace;
  final Color operatorEdge;
  final Color equalsFace;
  final Color equalsEdge;
  final Color ink;
  final PatternStyle pattern;
  final Color patternColor;

  static const felt = GamePalette(
    background: Color(0xFF163328),
    backgroundDeep: Color(0xFF0C1A14),
    well: Color(0xFF101D18),
    panel: Color(0xFF20242B),
    panelRaised: Color(0xFF2B313B),
    border: Color(0xFF5E6875),
    borderStrong: Color(0xFF7C8794),
    text: Color(0xFFF2EEDF),
    textMuted: Color(0xFFC8C2B8),
    gold: Color(0xFFE7B94C),
    red: Color(0xFFD94B43),
    blue: Color(0xFF4AA3FF),
    tileFace: Color(0xFFEAE4D6),
    tileEdge: Color(0xFFADA593),
    tileInk: Color(0xFF1C1F26),
    operatorFace: Color(0xFF2B313B),
    operatorEdge: Color(0xFF161A20),
    equalsFace: Color(0xFFD94B43),
    equalsEdge: Color(0xFF8E2A25),
    ink: Color(0xFF1C1F26),
    pattern: PatternStyle.lines,
    patternColor: Color(0xFFB9D8C2),
  );

  static const cosmic = GamePalette(
    background: Color(0xFF1E1A3D),
    backgroundDeep: Color(0xFF110E25),
    well: Color(0xFF15122C),
    panel: Color(0xFF24203F),
    panelRaised: Color(0xFF302A52),
    border: Color(0xFF5F5A8C),
    borderStrong: Color(0xFF8A84B8),
    text: Color(0xFFF2EEDF),
    textMuted: Color(0xFFC3BED6),
    gold: Color(0xFFE7B94C),
    red: Color(0xFFE0544B),
    blue: Color(0xFF5CB2FF),
    tileFace: Color(0xFFEAE4D6),
    tileEdge: Color(0xFFA8A0B4),
    tileInk: Color(0xFF1A1730),
    operatorFace: Color(0xFF302A52),
    operatorEdge: Color(0xFF17132E),
    equalsFace: Color(0xFFE0544B),
    equalsEdge: Color(0xFF8C2C27),
    ink: Color(0xFF1A1730),
    pattern: PatternStyle.flames,
    patternColor: Color(0xFF6E45D6),
  );

  static const minimal = GamePalette(
    background: Color(0xFF15171B),
    backgroundDeep: Color(0xFF0D0F12),
    well: Color(0xFF101215),
    panel: Color(0xFF1C1F25),
    panelRaised: Color(0xFF262A31),
    border: Color(0xFF3A404A),
    borderStrong: Color(0xFF626B78),
    text: Color(0xFFECE8DF),
    textMuted: Color(0xFFA9A49B),
    gold: Color(0xFFD9B260),
    red: Color(0xFFC9483F),
    blue: Color(0xFF6AA8E8),
    tileFace: Color(0xFFE4DFD4),
    tileEdge: Color(0xFF9E988C),
    tileInk: Color(0xFF15171B),
    operatorFace: Color(0xFF262A31),
    operatorEdge: Color(0xFF0F1114),
    equalsFace: Color(0xFFC9483F),
    equalsEdge: Color(0xFF7E2A24),
    ink: Color(0xFF15171B),
    pattern: PatternStyle.none,
    patternColor: Color(0x00000000),
  );

  // Versões claras: fundos de papel tingidos com a cor de cada tema, texto
  // escuro, acento dourado mais fechado para manter o contraste.

  static const feltLight = GamePalette(
    background: Color(0xFFDDEADF),
    backgroundDeep: Color(0xFFBFD6C6),
    well: Color(0xFFF2F7F2),
    panel: Color(0xFFF8F6EF),
    panelRaised: Color(0xFFECE9DF),
    border: Color(0xFFB5C1B7),
    borderStrong: Color(0xFF8A988D),
    text: Color(0xFF1D2A22),
    textMuted: Color(0xFF526158),
    gold: Color(0xFFC08A1E),
    red: Color(0xFFC8423A),
    blue: Color(0xFF2F7FD6),
    tileFace: Color(0xFFFFFCF4),
    tileEdge: Color(0xFFC8BFAA),
    tileInk: Color(0xFF1C1F26),
    operatorFace: Color(0xFFE3EBE4),
    operatorEdge: Color(0xFFA7B8AC),
    equalsFace: Color(0xFFD24A42),
    equalsEdge: Color(0xFF8E2A25),
    ink: Color(0xFF1C1F26),
    pattern: PatternStyle.lines,
    patternColor: Color(0xFF2F6B4A),
  );

  static const cosmicLight = GamePalette(
    background: Color(0xFFE6E1F6),
    backgroundDeep: Color(0xFFCEC5EC),
    well: Color(0xFFF5F2FD),
    panel: Color(0xFFFAF8FF),
    panelRaised: Color(0xFFEDE9F9),
    border: Color(0xFFBBB3DC),
    borderStrong: Color(0xFF928ABF),
    text: Color(0xFF231E40),
    textMuted: Color(0xFF5A5482),
    gold: Color(0xFFC08A1E),
    red: Color(0xFFD0463E),
    blue: Color(0xFF3D7FE0),
    tileFace: Color(0xFFFFFCF4),
    tileEdge: Color(0xFFC3BBD3),
    tileInk: Color(0xFF1A1730),
    operatorFace: Color(0xFFE6E1F7),
    operatorEdge: Color(0xFFABA2D1),
    equalsFace: Color(0xFFD0463E),
    equalsEdge: Color(0xFF8C2C27),
    ink: Color(0xFF1A1730),
    pattern: PatternStyle.flames,
    patternColor: Color(0xFF8B6CE0),
  );

  static const minimalLight = GamePalette(
    background: Color(0xFFF1EFEA),
    backgroundDeep: Color(0xFFE1DED6),
    well: Color(0xFFFAF9F6),
    panel: Color(0xFFFFFFFF),
    panelRaised: Color(0xFFF2F0EB),
    border: Color(0xFFD3CFC6),
    borderStrong: Color(0xFFA8A297),
    text: Color(0xFF1D1F23),
    textMuted: Color(0xFF5C5851),
    gold: Color(0xFFB98A2E),
    red: Color(0xFFC4433A),
    blue: Color(0xFF2F74C0),
    tileFace: Color(0xFFFFFFFF),
    tileEdge: Color(0xFFCEC8BC),
    tileInk: Color(0xFF15171B),
    operatorFace: Color(0xFFECEAE5),
    operatorEdge: Color(0xFFC1BCB1),
    equalsFace: Color(0xFFC4433A),
    equalsEdge: Color(0xFF7E2A24),
    ink: Color(0xFF15171B),
    pattern: PatternStyle.none,
    patternColor: Color(0x00000000),
  );

  static GamePalette of(BuildContext context) => Theme.of(context).extension<GamePalette>()!;

  static GamePalette forVariant(ThemeVariant variant, {Brightness brightness = Brightness.dark}) {
    final dark = brightness == Brightness.dark;
    return switch (variant) {
      ThemeVariant.felt => dark ? felt : feltLight,
      ThemeVariant.cosmic => dark ? cosmic : cosmicLight,
      ThemeVariant.minimal => dark ? minimal : minimalLight,
    };
  }

  /// A mesma paleta com outra cor de acento (a "cor semente" das
  /// configurações) e um texto legível por cima dela.
  GamePalette withAccent(Color accent) => GamePalette(
    background: background,
    backgroundDeep: backgroundDeep,
    well: well,
    panel: panel,
    panelRaised: panelRaised,
    border: border,
    borderStrong: borderStrong,
    text: text,
    textMuted: textMuted,
    gold: accent,
    red: red,
    blue: blue,
    tileFace: tileFace,
    tileEdge: tileEdge,
    tileInk: tileInk,
    operatorFace: operatorFace,
    operatorEdge: operatorEdge,
    equalsFace: equalsFace,
    equalsEdge: equalsEdge,
    ink: onColor(accent),
    pattern: pattern,
    patternColor: patternColor,
  );

  /// Texto escuro ou claro, o que contrastar mais com [color].
  static Color onColor(Color color) =>
      color.computeLuminance() > 0.35 ? const Color(0xFF1C1F26) : const Color(0xFFFFFCF4);

  @override
  GamePalette copyWith() => this;

  @override
  GamePalette lerp(GamePalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return GamePalette(
      background: l(background, other.background),
      backgroundDeep: l(backgroundDeep, other.backgroundDeep),
      well: l(well, other.well),
      panel: l(panel, other.panel),
      panelRaised: l(panelRaised, other.panelRaised),
      border: l(border, other.border),
      borderStrong: l(borderStrong, other.borderStrong),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      gold: l(gold, other.gold),
      red: l(red, other.red),
      blue: l(blue, other.blue),
      tileFace: l(tileFace, other.tileFace),
      tileEdge: l(tileEdge, other.tileEdge),
      tileInk: l(tileInk, other.tileInk),
      operatorFace: l(operatorFace, other.operatorFace),
      operatorEdge: l(operatorEdge, other.operatorEdge),
      equalsFace: l(equalsFace, other.equalsFace),
      equalsEdge: l(equalsEdge, other.equalsEdge),
      ink: l(ink, other.ink),
      pattern: t < 0.5 ? pattern : other.pattern,
      patternColor: l(patternColor, other.patternColor),
    );
  }
}
