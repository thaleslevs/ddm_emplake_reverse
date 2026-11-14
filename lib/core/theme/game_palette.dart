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

  static GamePalette of(BuildContext context) => Theme.of(context).extension<GamePalette>()!;

  static GamePalette forVariant(ThemeVariant variant) => switch (variant) {
    ThemeVariant.felt => felt,
    ThemeVariant.cosmic => cosmic,
    ThemeVariant.minimal => minimal,
  };

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
