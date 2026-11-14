import 'package:flutter/material.dart';

import '../../../core/theme/game_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/level.dart';
import '../domain/token.dart';
import 'drag_support.dart';
import 'expression_board.dart';
import 'game_texts.dart';
import 'piece_tile.dart';

const _rows = [
  [
    TokenKind.plus,
    TokenKind.minus,
    TokenKind.times,
    TokenKind.divide,
    TokenKind.power,
    TokenKind.sqrt,
    TokenKind.cbrt,
    TokenKind.factorial,
  ],
  [
    TokenKind.parenOpen,
    TokenKind.parenClose,
    TokenKind.absOpen,
    TokenKind.absClose,
    TokenKind.floorOpen,
    TokenKind.floorClose,
    TokenKind.ceilOpen,
    TokenKind.ceilClose,
  ],
];

class OperatorPalette extends StatelessWidget {
  const OperatorPalette({super.key, required this.level, required this.keys, this.size = 52});

  final Level level;
  final PieceKeys keys;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    return Container(
      padding: EdgeInsets.all(size * 0.3),
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border, width: 1.5),
        boxShadow: [BoxShadow(color: p.backgroundDeep, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in _rows.map((r) => r.where(level.operators.contains).toList()))
            if (row.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: size * 0.12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: size * 0.2,
                  runSpacing: size * 0.24,
                  children: [
                    for (final kind in row)
                      _PaletteButton(
                        kind: kind,
                        size: size,
                        tooltip: l10n.operatorName(kind),
                        positionKey: keys.palette(kind),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _PaletteButton extends StatefulWidget {
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
  State<_PaletteButton> createState() => _PaletteButtonState();
}

class _PaletteButtonState extends State<_PaletteButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: Draggable<PiecePayload>(
        data: NewPiece(widget.kind),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: dragFeedback(widget.kind, widget.size),
        onDragStarted: () => setState(() => _hovered = false),
        onDragEnd: (_) => setState(() => _hovered = false),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: PieceTile(kind: widget.kind, size: widget.size),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: PieceTile(key: widget.positionKey, kind: widget.kind, size: widget.size, hovered: _hovered),
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
    final p = GamePalette.of(context);

    final slot = AnimatedSwitcher(
      duration: const Duration(milliseconds: 120),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: placed
          ? Container(
              key: const ValueKey('empty'),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: p.well,
                borderRadius: BorderRadius.circular(size * 0.14),
                border: Border.all(color: p.border, width: 1.5),
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
        const SizedBox(width: 14),
        Flexible(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: placed ? 0.45 : 1,
            child: Text(
              l10n.gameEqualsHolder,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: p.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
