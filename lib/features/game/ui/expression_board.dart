import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/game_palette.dart';
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

  /// Posição de inserção na ordem de leitura: conta as peças que ficam antes
  /// do ponteiro (linhas de cima inteiras e, na mesma linha, as da esquerda).
  /// Funciona também quando a expressão quebra em várias linhas.
  int _indexFor(Offset global, List<Token> visible) {
    var index = 0;
    for (final token in visible) {
      final box = widget.keys.board(token.id).currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final before = rect.bottom < global.dy
          ? true
          : rect.top > global.dy
          ? false
          : rect.center.dx < global.dx;
      if (before) index++;
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
        // Encolhe as peças para caber numa linha; abaixo de 30 px, quebra a
        // expressão em mais linhas em vez de estourar a tela.
        final tile = ((constraints.maxWidth - 28) / (slots * 1.08)).clamp(30.0, 64.0);
        final spacing = tile * 0.08;

        return DragTarget<PiecePayload>(
          onWillAcceptWithDetails: (_) => true,
          onMove: (details) => _setHover(_indexFor(details.offset, visible)),
          onLeave: (_) => _setHover(null),
          onAcceptWithDetails: (details) {
            final index = _hoverIndex ?? _indexFor(details.offset, visible);
            _setHover(null);
            _accept(details.data, index);
          },
          builder: (context, candidates, _) {
            final p = GamePalette.of(context);
            final active = candidates.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              constraints: BoxConstraints(minHeight: tile + 40, minWidth: double.infinity),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? p.blue : p.borderStrong, width: 2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Sombra interna no topo; mais leve no tema claro.
                  colors: [
                    Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.08),
                    p.well,
                    p.well,
                  ],
                  stops: const [0, 0.18, 1],
                ),
                boxShadow: [BoxShadow(color: p.backgroundDeep, offset: const Offset(0, 4))],
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: tile * 0.3,
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
    final p = GamePalette.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      width: open ? tile + spacing * 2 : spacing,
      height: tile,
      padding: EdgeInsets.symmetric(horizontal: open ? spacing : 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: open ? 1 : 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(tile * 0.14),
            border: Border.all(color: p.blue, width: 1.5),
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
