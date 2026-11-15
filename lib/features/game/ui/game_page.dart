import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/game_sound.dart';
import '../../../core/audio/sounds.dart';
import '../../../core/theme/game_palette.dart';
import '../../../core/ui/game_controls.dart';
import '../../../core/ui/page_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/judge.dart';
import '../domain/latex.dart';
import '../domain/level.dart';
import '../domain/token.dart';
import '../state/game_controller.dart';
import '../../shop/account.dart';
import 'clown_burst.dart';
import 'drag_support.dart';
import 'expression_board.dart';
import 'flight_layer.dart';
import 'game_texts.dart';
import 'latex_preview.dart';
import 'operator_palette.dart';
import 'score_badge.dart';
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

  /// Reação da última verificação (palhaços felizes no acerto, tristes no
  /// erro); cada mudança em [_reactions] solta uma leva na tela.
  ClownMood _mood = ClownMood.sad;
  int _reactions = 0;

  GameController get _controller => ref.read(gameControllerProvider(_level).notifier);

  @override
  void dispose() {
    _flightTimer?.cancel();
    super.dispose();
  }

  void _check() {
    final state = ref.read(gameControllerProvider(_level));
    final verdict = _controller.check();
    ref.read(soundsProvider).play(verdict is Correct ? GameSound.correct : GameSound.wrong);
    setState(() {
      _mood = verdict is Correct ? ClownMood.happy : ClownMood.sad;
      _reactions++;
    });
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
    final p = GamePalette.of(context);
    final state = ref.watch(gameControllerProvider(_level));
    final busy = _flights.isNotEmpty;
    // "Blip" quando uma peça entra na expressão (na mesma rodada).
    ref.listen(gameControllerProvider(_level), (previous, next) {
      if (previous != null && next.round == previous.round && next.board.length > previous.board.length) {
        ref.read(soundsProvider).play(GameSound.place);
      }
    });

    // O fundo e a navbar vêm do AppShell.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
          key: _stackKey,
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final content = constraints.maxWidth.clamp(0.0, 920.0) - (wide ? 64 : 32);
                final pieceSize = ((content - 24) / 9.9).clamp(30.0, 56.0);
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 32 : 16,
                    wide ? 40 : 24,
                    wide ? 32 : 16,
                    PageFrame.bottomInset,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GameTitle(l10n.appTitle, skin: ref.watch(equippedSkinProvider)),
                          const SizedBox(height: 8),
                          const Center(child: ScoreBadge()),
                          SizedBox(height: wide ? 20 : 14),
                          GameTabs<Level>(
                            values: Level.values,
                            selected: _level,
                            label: l10n.levelName,
                            onSelected: busy ? null : (level) => setState(() => _level = level),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.gameInstructions,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: p.textMuted),
                          ),
                          const SizedBox(height: 20),
                          ExpressionBoard(key: ValueKey(_level), level: _level, keys: _keys),
                          const SizedBox(height: 12),
                          LatexPreview(latex: boardToLatex(state.board), emptyText: l10n.gamePreviewEmpty),
                          const SizedBox(height: 16),
                          Center(
                            child: EqualsHolder(placed: state.equalsPlaced, keys: _keys, size: pieceSize),
                          ),
                          const SizedBox(height: 16),
                          OperatorPalette(level: _level, keys: _keys, size: pieceSize),
                          const SizedBox(height: 12),
                          Text(
                            l10n.gameRemoveHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: p.textMuted),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              GameButton(
                                label: l10n.gameSkip,
                                icon: Icons.skip_next_rounded,
                                kind: GameButtonKind.secondary,
                                onPressed: busy
                                    ? null
                                    : () {
                                        ref.read(soundsProvider).play(GameSound.skip);
                                        _controller.skip();
                                      },
                              ),
                              GameButton(
                                label: l10n.gameClear,
                                icon: Icons.backspace_outlined,
                                onPressed: state.hasOperators && !busy ? _controller.clearOperators : null,
                              ),
                              GameButton(
                                label: l10n.gameCheck,
                                icon: Icons.check_rounded,
                                kind: GameButtonKind.primary,
                                onPressed: state.hasOperators && !busy ? _check : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
            Positioned.fill(
              child: ClownBurst(mood: _mood, trigger: _reactions),
            ),
          ],
        ),
    );
  }
}
