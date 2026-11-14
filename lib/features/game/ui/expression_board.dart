import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/judge.dart';
import '../domain/level.dart';
import '../domain/token.dart';
import '../state/game_controller.dart';
import 'drag_support.dart';
import 'piece_tile.dart';

class ExpressionBoard extends ConsumerStatefulWidget {
  const ExpressionBoard({super.key, required this.level, required this.keys});

  final Level level;
  final PieceKeys keys;

  @override
  ConsumerState<ExpressionBoard> createState() => _ExpressionBoardState();
}

class _ExpressionBoardState extends ConsumerState<ExpressionBoard> {
  int? _hoverIndex;

  String? _draggingId;

  GameController get _controller => ref.read(gameControllerProvider(widget.level).notifier);

  List<Token> _visible(List<Token> board) =>
      _draggingId == null ? board : board.where((t) => t.id != _draggingId).toList();

  int _indexFor(double globalX, List<Token> visible) {
    var index = 0;
    for (final token in visible) {
      final box = widget.keys.board(token.id).currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final centre = box.localToGlobal(box.size.center(Offset.zero)).dx;
      if (centre < globalX) index++;
    }
    return index;
  }

  void _setHover(int? index) {
    if (index != _hoverIndex) setState(() => _hoverIndex = index);
  }

  void _accept(PiecePayload payload, int index) {
    switch (payload) {
      case NewPiece(:final kind):
        _controller.insertPiece(kind, index);
      case PlacedPiece(:final token):
        _controller.movePiece(token.id, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider(widget.level));
    final visible = _visible(state.board);
    widget.keys.retainBoard(state.board.map((t) => t.id));

    final errorIndex = switch (state.verdict) {
      Invalid(:final error) => error.tokenIndex,
      _ => null,
    };
    final errorId = errorIndex != null && errorIndex < state.board.length ? state.board[errorIndex].id : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final slots = visible.length + (_hoverIndex != null ? 1 : 0) + 0.5;
        final tile = ((constraints.maxWidth - 24) / (slots * 1.08)).clamp(26.0, 56.0);
        final spacing = tile * 0.08;

        return DragTarget<PiecePayload>(
          onWillAcceptWithDetails: (_) => true,
          onMove: (details) => _setHover(_indexFor(details.offset.dx, visible)),
          onLeave: (_) => _setHover(null),
          onAcceptWithDetails: (details) {
            final index = _hoverIndex ?? _indexFor(details.offset.dx, visible);
            _setHover(null);
            _accept(details.data, index);
          },
          builder: (context, candidates, _) {
            final scheme = Theme.of(context).colorScheme;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: BoxConstraints(minHeight: tile + 32, minWidth: double.infinity),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: candidates.isNotEmpty
                    ? scheme.primaryContainer.withValues(alpha: 0.25)
                    : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: candidates.isNotEmpty ? scheme.primary : scheme.outlineVariant,
                  width: candidates.isNotEmpty ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _rowChildren(state, tile, spacing, errorId),
              ),
            );
          },
        );
      },
    );
  }

  // The dragged piece stays in the tree: removing its Draggable mid-drag would skip onDragEnd.
  List<Widget> _rowChildren(GameState state, double tile, double spacing, String? errorId) {
    final children = <Widget>[];
    var slot = 0;
    for (final token in state.board) {
      final dragging = token.id == _draggingId;
      if (!dragging) {
        children.add(
          _Gap(key: ValueKey('gap-$slot'), open: _hoverIndex == slot, tile: tile, spacing: spacing),
        );
        slot++;
      }
      children.add(
        _BoardPiece(
          key: ValueKey(token.id),
          token: token,
          tile: tile,
          verdictStamp: identityHashCode(state.verdict),
          positionKey: widget.keys.board(token.id),
          highlightError: token.id == errorId,
          onDragStarted: () => setState(() => _draggingId = token.id),
          onDragEnd: (accepted) {
            final id = _draggingId;
            setState(() {
              _draggingId = null;
              _hoverIndex = null;
            });
            if (!accepted && id != null) _controller.removePiece(id);
          },
          onDoubleTap: () => _controller.removePiece(token.id),
        ),
      );
    }
    children.add(_Gap(key: ValueKey('gap-$slot'), open: _hoverIndex == slot, tile: tile, spacing: spacing));
    return children;
  }
}

class _Gap extends StatelessWidget {
  const _Gap({super.key, required this.open, required this.tile, required this.spacing});

  final bool open;
  final double tile;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      width: open ? tile + spacing * 2 : spacing,
      height: tile,
      padding: EdgeInsets.symmetric(horizontal: open ? spacing : 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: open ? 1 : 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(tile * 0.22),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.6), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _BoardPiece extends StatelessWidget {
  const _BoardPiece({
    super.key,
    required this.token,
    required this.tile,
    required this.verdictStamp,
    required this.positionKey,
    required this.highlightError,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDoubleTap,
  });

  final Token token;
  final double tile;
  final int verdictStamp;
  final GlobalKey positionKey;
  final bool highlightError;
  final VoidCallback onDragStarted;
  final ValueChanged<bool> onDragEnd;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final piece = PieceTile(
      key: positionKey,
      kind: token.kind,
      digit: token.value,
      size: tile,
      highlightError: highlightError,
    );

    final shown = Animate(
      key: ValueKey('shake-$verdictStamp'),
      effects: highlightError ? const [ShakeEffect(hz: 5, offset: Offset(3, 0), rotation: 0)] : const [],
      child: piece,
    );

    if (token.kind == TokenKind.digit) {
      return shown
          .animate()
          .fadeIn(duration: 220.ms)
          .slideY(begin: -0.4, end: 0, duration: 260.ms, curve: Curves.easeOutBack);
    }

    final entering = shown.animate().scaleXY(begin: 0.6, end: 1, duration: 180.ms, curve: Curves.easeOutBack);

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Draggable<PiecePayload>(
        data: PlacedPiece(token),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _DragFeedback(kind: token.kind, size: tile),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: onDragStarted,
        onDragEnd: (details) => onDragEnd(details.wasAccepted),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: entering),
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.kind, required this.size});

  final TokenKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: Material(
        type: MaterialType.transparency,
        child: Transform.scale(
          scale: 1.12,
          child: PieceTile(kind: kind, size: size, lifted: true),
        ),
      ),
    );
  }
}

Widget dragFeedback(TokenKind kind, double size) => _DragFeedback(kind: kind, size: size);
