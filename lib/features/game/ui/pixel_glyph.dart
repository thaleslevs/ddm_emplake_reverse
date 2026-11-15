import 'package:flutter/material.dart';

import '../domain/token.dart';

/// Símbolos que a fonte pixel (Jersey 10) não tem, desenhados à mão na mesma
/// grade dela (veja [pixelsPerEm]).
class PixelGlyph extends StatelessWidget {
  const PixelGlyph({super.key, required this.kind, required this.unit, required this.color});

  final TokenKind kind;

  /// Tamanho de um "pixel" da grade, em pixels lógicos.
  final double unit;
  final Color color;

  static bool supports(TokenKind kind) => _glyphs.containsKey(kind);

  @override
  Widget build(BuildContext context) {
    final rows = _glyphs[kind]!;
    final cell = _halfResolution.contains(kind) ? unit / 2 : unit;
    return SizedBox(
      width: rows.first.length * cell,
      height: rows.length * cell,
      child: CustomPaint(painter: _PixelPainter(rows, color)),
    );
  }
}

class _PixelPainter extends CustomPainter {
  const _PixelPainter(this.rows, this.color);

  final List<String> rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / rows.first.length;
    // Um único path, com cada sequência horizontal de pixels virando um
    // retângulo, para não aparecer emenda entre pixels vizinhos.
    final path = Path();
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      var x = 0;
      while (x < row.length) {
        if (row[x] != '#') {
          x++;
          continue;
        }
        final start = x;
        while (x < row.length && row[x] == '#') {
          x++;
        }
        path.addRect(Rect.fromLTWH(start * u, y * u, (x - start) * u, u));
      }
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PixelPainter old) => old.rows != rows || old.color != color;
}

/// Na Jersey 10 um "pixel" mede ~0,108 em: dígitos têm 5 pixels de altura e
/// parênteses 6, com traço de 1 pixel. Os glifos abaixo seguem essa escala.
const pixelsPerEm = 0.108;

/// Glifos desenhados com meio pixel, para caber o "3" pequeno do ∛. Os traços
/// da raiz continuam com 2x2 meios pixels (um pixel inteiro).
const _halfResolution = {TokenKind.cbrt};

const _glyphs = <TokenKind, List<String>>{
  // Potência: ^ no alto, como um expoente.
  TokenKind.power: [
    '..#..',
    '.#.#.',
    '#...#',
    '.....',
    '.....',
    '.....',
  ],
  TokenKind.sqrt: [
    '....###',
    '....#..',
    '....#..',
    '#..#...',
    '.#.#...',
    '..#....',
  ],
  // Mesma raiz da √ em meio pixel, com o 3 pequeno em cima do tracinho.
  TokenKind.cbrt: [
    '###.....######',
    '..#.....######',
    '.##.....##....',
    '..#.....##....',
    '###.....##....',
    '........##....',
    '##....##......',
    '##....##......',
    '..##..##......',
    '..##..##......',
    '....##........',
    '....##........',
  ],
  TokenKind.floorOpen: [
    '#.',
    '#.',
    '#.',
    '#.',
    '#.',
    '##',
  ],
  TokenKind.floorClose: [
    '.#',
    '.#',
    '.#',
    '.#',
    '.#',
    '##',
  ],
  TokenKind.ceilOpen: [
    '##',
    '#.',
    '#.',
    '#.',
    '#.',
    '#.',
  ],
  TokenKind.ceilClose: [
    '##',
    '.#',
    '.#',
    '.#',
    '.#',
    '.#',
  ],
};
