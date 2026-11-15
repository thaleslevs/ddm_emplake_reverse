import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/game_palette.dart';
import '../domain/token.dart';
import 'pixel_glyph.dart';

class PieceTile extends StatelessWidget {
  const PieceTile({
    super.key,
    required this.kind,
    this.digit,
    this.size = 52,
    this.highlightError = false,
    this.lifted = false,
    this.hovered = false,
  });

  final TokenKind kind;
  final int? digit;
  final double size;
  final bool highlightError;
  final bool lifted;
  final bool hovered;

  bool get _isDigit => kind == TokenKind.digit;

  /// Tamanho da fonte pixel numa peça de operador de um caractere.
  static const _operatorScale = 0.72;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final (face, edge, ink) = switch (kind) {
      TokenKind.digit => (p.tileFace, p.tileEdge, p.tileInk),
      // Letra clara sobre o vermelho nos temas claros e escuros.
      TokenKind.equals => (p.equalsFace, p.equalsEdge, p.tileFace),
      _ => (p.operatorFace, p.operatorEdge, p.text),
    };
    final label = _isDigit ? '$digit' : kind.symbol;
    final fontScale = label.length > 1 ? 0.5 : (_isDigit ? 0.68 : _operatorScale);
    final glyph = PixelGlyph.supports(kind)
        ? PixelGlyph(kind: kind, unit: size * _operatorScale * pixelsPerEm, color: ink)
        : Text(label, maxLines: 1, textScaler: TextScaler.noScaling, style: GameType.tile(size * fontScale, ink));
    final depth = (size * 0.08).roundToDouble().clamp(2.0, 5.0);
    final border = highlightError
        ? p.red
        : hovered
        ? p.blue
        : Color.lerp(edge, p.backgroundDeep, 0.4)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      width: _isDigit ? size * 0.82 : size,
      height: size,
      decoration: BoxDecoration(
        color: edge,
        borderRadius: BorderRadius.circular(size * 0.14),
        border: Border.all(color: border, width: highlightError || hovered ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: lifted ? 0.45 : 0.3),
            blurRadius: lifted ? 12 : 0,
            offset: Offset(0, lifted ? 8 : 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: depth),
      child: DecoratedBox(
        decoration: BoxDecoration(color: face, borderRadius: BorderRadius.circular(size * 0.12)),
        child: Center(child: glyph),
      ),
    );
  }
}
