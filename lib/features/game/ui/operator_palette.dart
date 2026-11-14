import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../domain/level.dart';
import '../domain/token.dart';
import 'drag_support.dart';
import 'expression_board.dart';
import 'game_texts.dart';
import 'piece_tile.dart';

const _order = [
  TokenKind.plus,
  TokenKind.minus,
  TokenKind.times,
  TokenKind.divide,
  TokenKind.power,
  TokenKind.sqrt,
  TokenKind.cbrt,
  TokenKind.factorial,
  TokenKind.parenOpen,
  TokenKind.parenClose,
  TokenKind.absOpen,
  TokenKind.absClose,
  TokenKind.floorOpen,
  TokenKind.floorClose,
  TokenKind.ceilOpen,
  TokenKind.ceilClose,
];

class OperatorPalette extends StatelessWidget {
  const OperatorPalette({super.key, required this.level, required this.keys, this.size = 52});

  final Level level;
  final PieceKeys keys;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: size * 0.2,
      runSpacing: size * 0.2,
      children: [
        for (final kind in _order)
          if (level.operators.contains(kind))
            _PaletteButton(
              kind: kind,
              size: size,
              tooltip: l10n.operatorName(kind),
              positionKey: keys.palette(kind),
            ),
      ],
    );
  }
}

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({
    required this.kind,
    required this.size,
    required this.tooltip,
    required this.positionKey,
  });

  final TokenKind kind;
  final double size;
  final String tooltip;
  final GlobalKey positionKey;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: Draggable<PiecePayload>(
        data: NewPiece(kind),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: dragFeedback(kind, size),
        childWhenDragging: Opacity(
          opacity: 0.45,
          child: PieceTile(kind: kind, size: size),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: PieceTile(key: positionKey, kind: kind, size: size),
        ),
      ),
    );
  }
}

class EqualsHolder extends StatelessWidget {
  const EqualsHolder({super.key, required this.placed, required this.keys, this.size = 52});

  final bool placed;
  final PieceKeys keys;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final slot = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: placed
          ? Container(
              key: const ValueKey('empty'),
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                border: Border.all(color: scheme.outlineVariant, width: 1.5),
              ),
            )
          : Draggable<PiecePayload>(
              key: const ValueKey('equals'),
              data: const NewPiece(TokenKind.equals),
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: dragFeedback(TokenKind.equals, size),
              childWhenDragging: SizedBox(width: size, height: size),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: PieceTile(kind: TokenKind.equals, size: size),
              ),
            ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(key: keys.equalsHolder, width: size, height: size, child: slot),
        const SizedBox(width: 12),
        Flexible(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: placed ? 0.4 : 1,
            child: Text(l10n.gameEqualsHolder, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
