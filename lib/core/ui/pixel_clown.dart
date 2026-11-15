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

/// Grade do desenho, montada em camadas:
/// 1. corpo base;
/// 2. rosto da expressão (olhos e boca);
/// 3. a skin por cima (chapéu, cabelo, máscara, capacete...);
/// 4. lágrimas do choro e a mão do joinha, que aparecem em qualquer skin.
///
/// Legenda: o contorno · w branco · k rosto · e olho · n nariz · c bochecha
/// m boca · r lágrima · h/H cabelo · t/T chapéu · s/S roupa · b botão
/// f sapato. Letras extras de cada skin estão em [ClownColors.extras].
abstract final class PixelClown {
  static final _shapes = <(ClownLook, String), List<String>>{};

  static List<String> shape(ClownLook look, [ClownSkin skin = ClownSkins.classic]) =>
      _shapes.putIfAbsent((look, skin.id), () => _compose(look, skin));

  static int columns(ClownLook look) => shape(look).first.length;
  static int rows(ClownLook look) => shape(look).length;

  /// Linha a partir da qual o desenho é perna/sapato.
  static const legsFrom = 18;

  static List<String> _compose(ClownLook look, ClownSkin skin) {
    var rows = _patch(_base, _faces[look] ?? const {});
    rows = _patch(rows, skin.overlay);
    switch (look) {
      case ClownLook.neutral:
        return rows;
      case ClownLook.crying:
        return _patch(rows, _tears);
      case ClownLook.thumbsUp:
        // A luva desse lado sobe para o joinha; no lugar fica a manga. O
        // desenho ganha 2 colunas de cada lado para caber a mão.
        rows = _patch(rows, const {16: '__s_____________'}).map((r) => '..$r..').toList();
        return _patch(rows, _thumbHand);
    }
  }

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

  static final _pictures = <(ClownLook, String, ClownColors), ui.Picture>{};

  /// O desenho gravado uma vez, em escala 1 (1 pixel do desenho = 1 unidade),
  /// para desenhar muitos palhaços por quadro sem refazer os retângulos.
  static ui.Picture picture(ClownLook look, ClownSkin skin, ClownColors colors) =>
      _pictures.putIfAbsent((look, skin.id, colors), () {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paints = <String, Paint>{};
        final rows = shape(look, skin);
        for (var y = 0; y < rows.length; y++) {
          paintRow(canvas, rows[y], y, colors, 1, paints, overlap: 0.06);
        }
        return recorder.endRecording();
      });
}

/// Aplica [patch] por cima de [base]: em cada linha do patch, `_` mantém o
/// pixel de baixo e qualquer outra letra (inclusive `.`, vazio) o substitui.
List<String> _patch(List<String> base, Map<int, String> patch) => [
  for (var y = 0; y < base.length; y++)
    if (patch[y] case final p?)
      String.fromCharCodes([
        for (var x = 0; x < base[y].length; x++)
          x < p.length && p[x] != '_' ? p.codeUnitAt(x) : base[y].codeUnitAt(x),
      ])
    else
      base[y],
];

const _base = [
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

const _faces = <ClownLook, Map<int, String>>{
  // Olhos apertados e boca para baixo.
  ClownLook.crying: {
    8: 'ohhkeekkkkeekhho',
    11: '..oHhkmkkmkhHo..',
  },
  // Olhos fechados de alegria (^ ^) e sorriso.
  ClownLook.thumbsUp: {
    7: '.ohhkekkkkekhho.',
    8: 'ohhkekekkekekhho',
    10: '.ohhkkmkkmkkhho.',
    11: '..oHhkkmmkkhHo..',
  },
};

/// Lágrimas escorrendo das bochechas, por cima de qualquer skin.
const _tears = {
  9: '____r______r____',
  10: '____r______r____',
};

/// Mão em joinha à esquerda (no desenho já alargado para 20 colunas).
const _thumbHand = {
  9: '_oo_________________',
  10: '_owo________________',
  11: 'oowwo_______________',
  12: 'owwwo_______________',
  13: 'owwwo_______________',
  14: '_ooo________________',
};

/// Uma skin: o que muda no desenho ([overlay], com `_` mantendo o pixel de
/// baixo) e as cores de cada palhaço que a usa.
class ClownSkin {
  const ClownSkin({
    required this.id,
    required this.left,
    required this.right,
    required this.happy,
    required this.sad,
    this.overlay = const {},
  });

  final String id;
  final Map<int, String> overlay;

  /// Os dois palhaços do título.
  final ClownColors left;
  final ClownColors right;

  /// As chuvas de acerto e de erro.
  final ClownColors happy;
  final ClownColors sad;
}

abstract final class ClownSkins {
  static const classic = ClownSkin(
    id: 'classic',
    left: ClownColors.green,
    right: ClownColors.purple,
    happy: ClownColors.redYellow,
    sad: ClownColors.blue,
  );

  /// Chapéu pontudo com estrelas e barba branca.
  static const wizard = ClownSkin(
    id: 'wizard',
    overlay: {
      0: '.......oo.......',
      1: '......otto......',
      2: '......otyo......',
      3: '.....otttTo.....',
      4: '....ottyttTo....',
      5: '..oTTTTTTTTTTo..',
      11: '..owwwwwwwwwwo..',
      13: '..ossowwwwosso..',
    },
    left: _wizardBlue,
    right: _wizardRed,
    happy: _wizardRed,
    sad: _wizardBlue,
  );

  /// Cabeça de metal com antena, visor e olhos brilhando.
  static const robot = ClownSkin(
    id: 'robot',
    overlay: {
      0: '.......nn.......',
      1: '.......oo.......',
      2: '.......oo.......',
      3: '....oooooooo....',
      4: '...oggggggggo...',
      5: '..oggGGGGGGggo..',
      6: '..oggggggggggo..',
      7: '.oggvvvvvvvvggo.',
      8: 'oggGvivvvvivGggo',
      9: 'oggGvvvvvvvvGggo',
      10: '.ogggggmmgggggo.',
      11: '..oGggggggggGo..',
    },
    left: _robotSteel,
    right: _robotCopper,
    happy: _robotCopper,
    sad: _robotSteel,
  );

  /// Bandana com nó, tapa-olho e brinco de ouro.
  static const pirate = ClownSkin(
    id: 'pirate',
    overlay: {
      0: '................',
      1: '................',
      2: '................',
      3: '................',
      4: '....oooooooo....',
      5: '...oddddddddo...',
      6: '..oddddddddddod.',
      7: '__________x___dd',
      8: '_________xxx____',
      10: '__y_____________',
    },
    left: _pirateRed,
    right: _pirateBlue,
    happy: _pirateRed,
    sad: _pirateBlue,
  );

  /// Máscara com só os olhos de fora e faixa na testa.
  static const ninja = ClownSkin(
    id: 'ninja',
    overlay: {
      0: '................',
      1: '................',
      2: '................',
      3: '................',
      4: '....oooooooo....',
      5: '...oxxxxxxxxo...',
      6: '..oxxxxxxxxxxo..',
      7: '.oxxddddddddxxod',
      8: 'oxxkkekkkkekkxxo',
      9: 'oxxxxxxxxxxxxxxo',
      10: '.oxxxxxxxxxxxxo.',
      11: '..oxxxxxxxxxxo..',
      12: '...oxxxxxxxxo...',
    },
    left: _ninjaBlack,
    right: _ninjaNavy,
    happy: _ninjaBlack,
    sad: _ninjaNavy,
  );

  /// Capacete branco com visor escuro e anel dourado no pescoço.
  static const astronaut = ClownSkin(
    id: 'astronaut',
    overlay: {
      0: '................',
      1: '................',
      2: '.....oooooo.....',
      3: '...oowwwwwwoo...',
      4: '..owwwwwwwwwwo..',
      5: '.owwwwwwwwwwwwo.',
      6: '.owwvvvvvvvvwwo.',
      7: 'owwvvlvvvvvvvwwo',
      8: 'owwvvkekkekvvwwo',
      9: 'owwvvkknnkkvvwwo',
      10: '.owwvvkmmkvvwwo.',
      11: '..owwvvvvvvwwo..',
      12: '...obbbbbbbbo...',
    },
    left: _astroWhite,
    right: _astroOrange,
    happy: _astroOrange,
    sad: _astroWhite,
  );

  /// Crânio com olhos fundos e dentes, roupa preta com costelas.
  static const skeleton = ClownSkin(
    id: 'skeleton',
    overlay: {
      0: '................',
      1: '................',
      2: '................',
      3: '................',
      4: '....oooooooo....',
      5: '...owwwwwwwwo...',
      6: '..owwwwwwwwwwo..',
      7: '.owwwwwwwwwwwwo.',
      8: 'owwxxwwwwwwxxwwo',
      9: 'owwxxwwxxwwxxwwo',
      10: '.owwwwwwwwwwwwo.',
      11: '..owwxwxwxwxwo..',
      14: '_____wwwwww_____',
      15: '_______ww_______',
      16: '_____wwwwww_____',
    },
    left: _skeletonBlack,
    right: _skeletonPurple,
    happy: _skeletonBlack,
    sad: _skeletonPurple,
  );

  static const all = [classic, wizard, robot, pirate, ninja, astronaut, skeleton];

  static ClownSkin byId(String? id) => all.firstWhere((s) => s.id == id, orElse: () => classic);
}

const _wizardBlue = ClownColors(
  hair: Color(0xFFCDD0DA),
  hairShade: Color(0xFF8E93A3),
  hat: Color(0xFF3E46C2),
  hatShade: Color(0xFF272C8A),
  suit: Color(0xFF4651C9),
  suitShade: Color(0xFF2E358F),
  shoe: Color(0xFF1E2147),
  extras: {'y': Color(0xFFFFD54A)},
);

const _wizardRed = ClownColors(
  hair: Color(0xFFCDD0DA),
  hairShade: Color(0xFF8E93A3),
  hat: Color(0xFFB0333F),
  hatShade: Color(0xFF7A1F29),
  suit: Color(0xFFC23A47),
  suitShade: Color(0xFF82232D),
  shoe: Color(0xFF3A1016),
  extras: {'y': Color(0xFFFFD54A)},
);

const _robotSteel = ClownColors(
  hair: Color(0xFF7D8896),
  hairShade: Color(0xFF5D6A79),
  hat: Color(0xFF7D8896),
  hatShade: Color(0xFF5D6A79),
  suit: Color(0xFF8E9BAA),
  suitShade: Color(0xFF5D6A79),
  shoe: Color(0xFF39424D),
  extras: {
    'g': Color(0xFFC3CCD6),
    'G': Color(0xFF7D8896),
    'v': Color(0xFF17202C),
    'i': Color(0xFF5EF2FF),
  },
);

const _robotCopper = ClownColors(
  hair: Color(0xFF8A5232),
  hairShade: Color(0xFF6B3D24),
  hat: Color(0xFF8A5232),
  hatShade: Color(0xFF6B3D24),
  suit: Color(0xFFC07A4A),
  suitShade: Color(0xFF8A5232),
  shoe: Color(0xFF4A2B1A),
  extras: {
    'g': Color(0xFFE0A070),
    'G': Color(0xFFA8643C),
    'v': Color(0xFF241510),
    'i': Color(0xFFFF6B5E),
  },
);

const _pirateRed = ClownColors(
  hair: Color(0xFF4A2E1E),
  hairShade: Color(0xFF2E1B10),
  hat: Color(0xFFC8322B),
  hatShade: Color(0xFF8E211C),
  suit: Color(0xFFECE6D6),
  suitShade: Color(0xFF2B3A67),
  shoe: Color(0xFF1A1A1A),
  extras: {
    'd': Color(0xFFC8322B),
    'x': Color(0xFF141418),
    'y': Color(0xFFF2C744),
  },
);

const _pirateBlue = ClownColors(
  hair: Color(0xFF2B1C12),
  hairShade: Color(0xFF1A110A),
  hat: Color(0xFF2C5DBF),
  hatShade: Color(0xFF1E3F85),
  suit: Color(0xFFECE6D6),
  suitShade: Color(0xFFA3262A),
  shoe: Color(0xFF1A1A1A),
  extras: {
    'd': Color(0xFF2C5DBF),
    'x': Color(0xFF141418),
    'y': Color(0xFFF2C744),
  },
);

const _ninjaBlack = ClownColors(
  hair: Color(0xFF1E1E26),
  hairShade: Color(0xFF111116),
  hat: Color(0xFF1E1E26),
  hatShade: Color(0xFF111116),
  suit: Color(0xFF2A2A33),
  suitShade: Color(0xFF16161C),
  shoe: Color(0xFF0F0F12),
  extras: {
    'x': Color(0xFF1E1E26),
    'd': Color(0xFFD63B33),
  },
);

const _ninjaNavy = ClownColors(
  hair: Color(0xFF1C2340),
  hairShade: Color(0xFF0F1428),
  hat: Color(0xFF1C2340),
  hatShade: Color(0xFF0F1428),
  suit: Color(0xFF243058),
  suitShade: Color(0xFF141B36),
  shoe: Color(0xFF0B0F1E),
  extras: {
    'x': Color(0xFF1C2340),
    'd': Color(0xFFF2C744),
  },
);

const _astroWhite = ClownColors(
  hair: Color(0xFFB7C0CC),
  hairShade: Color(0xFF8A94A3),
  hat: Color(0xFFEEF1F5),
  hatShade: Color(0xFFB7C0CC),
  suit: Color(0xFFEEF1F5),
  suitShade: Color(0xFFB7C0CC),
  shoe: Color(0xFF6E7887),
  extras: {
    'v': Color(0xFF1D2B4A),
    'l': Color(0xFF9FD8FF),
  },
);

const _astroOrange = ClownColors(
  hair: Color(0xFFB7C0CC),
  hairShade: Color(0xFF8A94A3),
  hat: Color(0xFFEEF1F5),
  hatShade: Color(0xFFB7C0CC),
  suit: Color(0xFFF08A3C),
  suitShade: Color(0xFFB85F22),
  shoe: Color(0xFF5A3A22),
  extras: {
    'v': Color(0xFF1D2B4A),
    'l': Color(0xFF9FD8FF),
  },
);

const _skeletonBlack = ClownColors(
  hair: Color(0xFF1B1B22),
  hairShade: Color(0xFF0E0E12),
  hat: Color(0xFF1B1B22),
  hatShade: Color(0xFF0E0E12),
  suit: Color(0xFF1B1B22),
  suitShade: Color(0xFF30303C),
  shoe: Color(0xFF0E0E12),
  extras: {'x': Color(0xFF121216)},
);

const _skeletonPurple = ClownColors(
  hair: Color(0xFF2A1B3D),
  hairShade: Color(0xFF1A1026),
  hat: Color(0xFF2A1B3D),
  hatShade: Color(0xFF1A1026),
  suit: Color(0xFF2A1B3D),
  suitShade: Color(0xFF44305E),
  shoe: Color(0xFF140C1E),
  extras: {'x': Color(0xFF121216)},
);

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
    this.extras = const {},
  });

  final Color hair;
  final Color hairShade;
  final Color hat;
  final Color hatShade;
  final Color suit;
  final Color suitShade;
  final Color shoe;

  /// Cores das letras próprias de cada skin (metal, visor, máscara...).
  final Map<String, Color> extras;

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

  Color? of(String key) =>
      extras[key] ??
      switch (key) {
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
