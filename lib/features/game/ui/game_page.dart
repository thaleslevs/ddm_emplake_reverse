import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../domain/judge.dart';
import '../domain/latex.dart';
import '../domain/level.dart';
import '../domain/token.dart';
import '../state/game_controller.dart';
import 'drag_support.dart';
import 'expression_board.dart';
import 'flight_layer.dart';
import 'game_texts.dart';
import 'latex_preview.dart';
import 'operator_palette.dart';
import 'verdict_banner.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key, this.initialLevel = Level.easy});

  final Level initialLevel;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  late Level _level = widget.initialLevel;
  final _keys = PieceKeys();
  final _stackKey = GlobalKey();
  List<Flight> _flights = const [];
  Timer? _flightTimer;

  GameController get _controller => ref.read(gameControllerProvider(_level).notifier);

  @override
  void dispose() {
    _flightTimer?.cancel();
    super.dispose();
  }

  void _check() {
    final state = ref.read(gameControllerProvider(_level));
    final verdict = _controller.check();
    if (verdict is Correct) _sendPiecesHome(state.board);
  }

  void _sendPiecesHome(List<Token> board) {
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final flights = <Flight>[];
    if (stack != null) {
      for (final token in board.where((t) => t.kind != TokenKind.digit)) {
        final from = PieceKeys.rectOf(_keys.board(token.id), stack);
        final to = PieceKeys.rectOf(_keys.home(token.kind), stack);
        if (from != null && to != null) {
          flights.add(
            Flight(
              kind: token.kind,
              from: from,
              to: to,
              toKey: _keys.home(token.kind),
              order: flights.length,
            ),
          );
        }
      }
    }

    setState(() => _flights = flights);
    _controller.clearOperators();

    _flightTimer?.cancel();
    _flightTimer = Timer(FlightLayer.totalFor(flights.length) + const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _flights = const []);
      _controller.nextRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(gameControllerProvider(_level));
    final busy = _flights.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle), centerTitle: true),
      body: Stack(
        key: _stackKey,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final pieceSize = wide ? 56.0 : 46.0;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LevelSelector(
                          level: _level,
                          onChanged: busy ? null : (level) => setState(() => _level = level),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.gameInstructions,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ExpressionBoard(key: ValueKey(_level), level: _level, keys: _keys),
                        const SizedBox(height: 12),
                        LatexPreview(latex: boardToLatex(state.board), emptyText: l10n.gamePreviewEmpty),
                        const SizedBox(height: 20),
                        Center(
                          child: EqualsHolder(placed: state.equalsPlaced, keys: _keys, size: pieceSize),
                        ),
                        const SizedBox(height: 16),
                        OperatorPalette(level: _level, keys: _keys, size: pieceSize),
                        const SizedBox(height: 8),
                        Text(
                          l10n.gameRemoveHint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        _Actions(
                          canClear: state.hasOperators && !busy,
                          canCheck: state.hasOperators && !busy,
                          canSkip: !busy,
                          onClear: _controller.clearOperators,
                          onSkip: _controller.skip,
                          onCheck: _check,
                        ),
                        const SizedBox(height: 16),
                        VerdictBanner(verdict: state.verdict, solved: state.solved),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            child: FlightLayer(flights: _flights, stackKey: _stackKey),
          ),
        ],
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({required this.level, required this.onChanged});

  final Level level;
  final ValueChanged<Level>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SegmentedButton<Level>(
          segments: [for (final l in Level.values) ButtonSegment(value: l, label: Text(l10n.levelName(l)))],
          selected: {level},
          showSelectedIcon: false,
          onSelectionChanged: onChanged == null ? null : (s) => onChanged!(s.single),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.canClear,
    required this.canCheck,
    required this.canSkip,
    required this.onClear,
    required this.onSkip,
    required this.onCheck,
  });

  final bool canClear;
  final bool canCheck;
  final bool canSkip;
  final VoidCallback onClear;
  final VoidCallback onSkip;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        TextButton.icon(
          onPressed: canSkip ? onSkip : null,
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(l10n.gameSkip),
        ),
        OutlinedButton.icon(
          onPressed: canClear ? onClear : null,
          icon: const Icon(Icons.cleaning_services_rounded),
          label: Text(l10n.gameClear),
        ),
        FilledButton.icon(
          onPressed: canCheck ? onCheck : null,
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.gameCheck),
        ),
      ],
    );
  }
}
