import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Palhaços em pixel art desenhados à mão: a mesma figura em três jeitos.
enum ClownLook {
  /// Parado, expressão neutra (ao lado do título).
  neutral,

  /// Olhos apertados, lágrimas e boca para baixo (erro).
  crying,

  /// Sorrindo de olhos fechados e fazendo joinha (acerto).
  thumbsUp,
}

/// Grade do desenho de cada jeito. Legenda:
/// o contorno · w branco · k rosto · e olho · n nariz · c bochecha · m boca
/// r lágrima · h/H cabelo · t/T chapéu · s/S roupa · b botão · f sapato
abstract final class PixelClown {
  static List<String> shape(ClownLook look) => switch (look) {
    ClownLook.neutral => _neutral,
    ClownLook.crying => _crying,
    ClownLook.thumbsUp => _thumbsUp,
  };

  static int columns(ClownLook look) => shape(look).first.length;
  static int rows(ClownLook look) => shape(look).length;

  /// Linha a partir da qual o desenho é perna/sapato.
  static const legsFrom = 18;

  /// Pinta uma linha da grade com o topo na linha [top] (em pixels do desenho).
  static void paintRow(
    Canvas canvas,
    String row,
    int top,
    ClownColors colors,
    double unit,
    Map<String, Paint> paints, {
    int left = 0,
    double overlap = 0.5,
  }) {
    for (var x = 0; x < row.length; x++) {
      final color = colors.of(row[x]);
      if (color == null) continue;
      final paint = paints.putIfAbsent(row[x], () => Paint()..color = color);
      // Sobreposição evita fendas entre pixels vizinhos.
      canvas.drawRect(Rect.fromLTWH((left + x) * unit, top * unit, unit + overlap, unit + overlap), paint);
    }
  }

  static final _pictures = <(ClownLook, ClownColors), ui.Picture>{};

  /// O desenho gravado uma vez, em escala 1 (1 pixel do desenho = 1 unidade),
  /// para desenhar muitos palhaços por quadro sem refazer os retângulos.
  static ui.Picture picture(ClownLook look, ClownColors colors) => _pictures.putIfAbsent((look, colors), () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paints = <String, Paint>{};
    final rows = shape(look);
    for (var y = 0; y < rows.length; y++) {
      paintRow(canvas, rows[y], y, colors, 1, paints, overlap: 0.06);
    }
    return recorder.endRecording();
  });
}

const _neutral = [
  '......owwo......',
  '......owwo......',
  '......otto......',
  '.....ottTto.....',
  '....otttTTto....',
  '...owwwwwwwwo...',
  '..ohhhhhhhhhho..',
  '.ohhkkkkkkkkhho.',
  'ohhkkekkkkekkhho',
  'ohhkckknnkkckhho',
  '.ohhkkkmmkkkhho.',
  '..oHhkkkkkkhHo..',
  '...owwwwwwwwo...',
  '..osssssssssso..',
  '.ossSssbssssSso.',
  '.ossSsssssssSso.',
  '.owSsssbssssSwo.',
  '..osssssssssso..',
  '..ossso..ossso..',
  '..ossso..ossso..',
  '.offffo..offffo.',
  '.oooooo..oooooo.',
];

/// Olhos apertados, lágrimas escorrendo pelas bochechas, boca para baixo.
final _crying = _withRows(_neutral, {
  8: 'ohhkeekkkkeekhho',
  9: 'ohhkrkknnkkrkhho',
  10: '.ohhrkkmmkkrhho.',
  11: '..oHhkmkkmkhHo..',
});

/// Olhos fechados de alegria (^ ^), sorriso e a mão esquerda erguida num
/// joinha (o desenho ganha 2 colunas de cada lado para caber a mão).
final _thumbsUp = _overlay(
  _withRows(_neutral, {
    7: '.ohhkekkkkekhho.',
    8: 'ohhkekekkekekhho',
    10: '.ohhkkmkkmkkhho.',
    11: '..oHhkkmmkkhHo..',
    // A luva desse lado sobe para o joinha; no lugar fica a manga.
    16: '.osSsssbssssSwo.',
  }).map((r) => '..$r..').toList(),
  {
    9: '.oo..',
    10: '.owo.',
    11: 'oowwo',
    12: 'owwwo',
    13: 'owwwo',
    14: '.ooo.',
  },
);

List<String> _withRows(List<String> base, Map<int, String> rows) => [
  for (var y = 0; y < base.length; y++) rows[y] ?? base[y],
];

/// Sobrepõe os pixels não vazios de [patch] no começo de cada linha.
List<String> _overlay(List<String> base, Map<int, String> patch) => [
  for (var y = 0; y < base.length; y++)
    if (patch[y] case final p?)
      String.fromCharCodes([
        for (var x = 0; x < base[y].length; x++) x < p.length && p[x] != '.' ? p.codeUnitAt(x) : base[y].codeUnitAt(x),
      ])
    else
      base[y],
];

@immutable
class ClownColors {
  const ClownColors({
    required this.hair,
    required this.hairShade,
    required this.hat,
    required this.hatShade,
    required this.suit,
    required this.suitShade,
    required this.shoe,
  });

  final Color hair;
  final Color hairShade;
  final Color hat;
  final Color hatShade;
  final Color suit;
  final Color suitShade;
  final Color shoe;

  static const _outline = Color(0xFF1B1626);
  static const _white = Color(0xFFF4F1E8);
  static const _face = Color(0xFFFBF1E6);
  static const _nose = Color(0xFFE04848);
  static const _cheek = Color(0xFFF2A7A0);
  static const _mouth = Color(0xFF7A3340);
  static const _button = Color(0xFFE8C35A);
  static const _tear = Color(0xFF8FD8FF);

  static const green = ClownColors(
    hair: Color(0xFF55C27F),
    hairShade: Color(0xFF2F8A55),
    hat: Color(0xFF2E9A5C),
    hatShade: Color(0xFF1E6B3F),
    suit: Color(0xFF3DAF6B),
    suitShade: Color(0xFF247A48),
    shoe: Color(0xFF1E5C38),
  );

  static const purple = ClownColors(
    hair: Color(0xFFA77BEA),
    hairShade: Color(0xFF7550C2),
    hat: Color(0xFF8257D6),
    hatShade: Color(0xFF5A37A3),
    suit: Color(0xFF9466E0),
    suitShade: Color(0xFF6440B0),
    shoe: Color(0xFF4A2B86),
  );

  /// Azul, do palhaço que chora no erro.
  static const blue = ClownColors(
    hair: Color(0xFF41C4CB),
    hairShade: Color(0xFF248A92),
    hat: Color(0xFF3263BA),
    hatShade: Color(0xFF1F4183),
    suit: Color(0xFF3E74CC),
    suitShade: Color(0xFF274C8F),
    shoe: Color(0xFF1C3566),
  );

  /// Vermelho e amarelo, do palhaço que faz joinha no acerto.
  static const redYellow = ClownColors(
    hair: Color(0xFFF7C12E),
    hairShade: Color(0xFFD48714),
    hat: Color(0xFFD63B33),
    hatShade: Color(0xFF9B2420),
    suit: Color(0xFFE0483C),
    suitShade: Color(0xFFA8302A),
    shoe: Color(0xFF8C1F1C),
  );

  Color? of(String key) => switch (key) {
    'o' || 'e' => _outline,
    'w' => _white,
    'k' => _face,
    'n' => _nose,
    'c' => _cheek,
    'm' => _mouth,
    'r' => _tear,
    'b' => _button,
    'h' => hair,
    'H' => hairShade,
    't' => hat,
    'T' => hatShade,
    's' => suit,
    'S' => suitShade,
    'f' => shoe,
    _ => null,
  };
}
