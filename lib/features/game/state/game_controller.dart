import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solved_repository.dart';
import 'solved_store.dart';

import '../domain/judge.dart';
import '../domain/latex.dart';
import '../domain/level.dart';
import '../domain/solver.dart';
import '../domain/token.dart';

class SolvedInfo {
  const SolvedInfo({required this.number, required this.latex, required this.value});
  final String number;
  final String latex;
  final double value;
}

class GameState {
  const GameState({
    required this.level,
    required this.digits,
    required this.board,
    required this.round,
    this.verdict,
    this.solved,
  });

  final Level level;

  final List<int> digits;

  final List<Token> board;

  final int round;

  final Verdict? verdict;

  final SolvedInfo? solved;

  String get number => digits.join();
  bool get equalsPlaced => board.any((t) => t.kind == TokenKind.equals);
  bool get hasOperators => board.any((t) => t.kind != TokenKind.digit);

  GameState copyWith({
    List<int>? digits,
    List<Token>? board,
    int? round,
    Verdict? Function()? verdict,
    SolvedInfo? Function()? solved,
  }) {
    return GameState(
      level: level,
      digits: digits ?? this.digits,
      board: board ?? this.board,
      round: round ?? this.round,
      verdict: verdict != null ? verdict() : this.verdict,
      solved: solved != null ? solved() : this.solved,
    );
  }
}

final gameControllerProvider = NotifierProvider.family<GameController, GameState, Level>(GameController.new);

class GameController extends Notifier<GameState> {
  GameController(this.level);

  final Level level;
  final _random = Random();
  late final _solver = Solver(level);
  int _nextId = 0;

  @override
  GameState build() => _freshRound(round: 0);

  String _id() => 'p${_nextId++}';

  GameState _freshRound({required int round, SolvedInfo? solved}) {
    final digits = _drawDigits();
    return GameState(
      level: level,
      digits: digits,
      board: [for (final d in digits) Token.digit(d, id: _id())],
      round: round,
      solved: solved,
    );
  }

  /// Sorteia até achar um número inédito que o [Solver] consiga resolver
  /// neste nível. Se der azar demais (não deve acontecer), aceita o último.
  List<int> _drawDigits() {
    final solved = ref.read(solvedProvider)[level]!;
    List<int>? fallback;
    for (var attempt = 0; attempt < 500; attempt++) {
      final digits = List.generate(4, (_) => _random.nextInt(10));
      if (solved.contains(digits.join())) continue;
      fallback = digits;
      if (_solver.isSolvable(digits)) return digits;
    }
    return fallback ?? List.generate(4, (_) => _random.nextInt(10));
  }

  void _setBoard(List<Token> board) {
    state = state.copyWith(board: board, verdict: () => null, solved: () => null);
  }

  void insertPiece(TokenKind kind, int index) {
    assert(kind != TokenKind.digit);
    if (kind == TokenKind.equals && state.equalsPlaced) {
      final equals = state.board.firstWhere((t) => t.kind == TokenKind.equals);
      movePiece(equals.id, index);
      return;
    }
    final board = [...state.board];
    board.insert(index.clamp(0, board.length), Token(kind, id: _id()));
    _setBoard(board);
  }

  void movePiece(String id, int index) {
    final board = [...state.board];
    final from = board.indexWhere((t) => t.id == id);
    if (from < 0 || board[from].kind == TokenKind.digit) return;
    final token = board.removeAt(from);
    board.insert(index.clamp(0, board.length), token);
    if (from == board.indexOf(token)) return;
    _setBoard(board);
  }

  void removePiece(String id) {
    final token = state.board.where((t) => t.id == id).firstOrNull;
    if (token == null || token.kind == TokenKind.digit) return;
    _setBoard([...state.board]..remove(token));
  }

  void clearOperators() {
    if (!state.hasOperators) return;
    state = state.copyWith(
      board: state.board.where((t) => t.kind == TokenKind.digit).toList(),
      verdict: () => null,
    );
  }

  Verdict check() {
    final verdict = judge(state.board, digits: state.digits, level: level);
    SolvedInfo? solved;
    if (verdict is Correct) {
      solved = SolvedInfo(
        number: state.number,
        latex: equationToLatex(parseEquation(state.board)),
        value: verdict.value,
      );
      ref.read(solvedProvider.notifier).add(level, solved.number);
      // Sem esperar: se a gravação falhar, o jogo segue e o número só volta
      // a poder ser sorteado depois de recarregar.
      ref
          .read(solvedRepositoryProvider)
          ?.markSolved(level, solved.number, latex: solved.latex)
          .catchError((Object e) => debugPrint('Falha ao salvar resolvido: $e'));
    }
    state = state.copyWith(verdict: () => verdict, solved: () => solved);
    return verdict;
  }

  void nextRound() {
    state = _freshRound(round: state.round + 1, solved: state.solved);
  }

  void skip() {
    state = _freshRound(round: state.round + 1);
  }
}
