import 'dart:math' as math;

import 'judge.dart';
import 'level.dart';
import 'token.dart';

/// Uma igualdade encontrada pelo [Solver], já confirmada pelo [judge].
class Solution {
  const Solution(this.tokens, this.value);

  final List<Token> tokens;
  final double value;

  String get text => tokens.map((t) => t.symbol).join(' ');

  @override
  String toString() => text;
}

typedef _Piece = (TokenKind, int?);

class _Cand {
  const _Cand(this.value, this.pieces);
  final double value;
  final List<_Piece> pieces;
}

/// Procura uma igualdade válida para os dígitos (na ordem, sem concatenar)
/// usando só os operadores do nível.
///
/// A busca é por camadas, da mais barata para a mais cara:
/// - camada 0: só operações binárias (+ − × ÷ e potência, se o nível tiver);
/// - camada 1: mais uma operação unária (−x, |x|, √, ∛, !, ⌊⌋, ⌈⌉) em cada termo;
/// - camada 2: até duas operações unárias em cada dígito.
///
/// Se achar, a resposta é confirmada pelo [judge] (a mesma função que corrige
/// o jogador), então nunca devolve uma igualdade errada. Se não achar, o número
/// provavelmente não tem solução, mas a busca não é exaustiva.
class Solver {
  Solver(this.level, {this.maxTier = 2, this.maxSetSize = 20000});

  final Level level;
  final int maxTier;
  final int maxSetSize;

  static const _maxMagnitude = 1e6;

  final _cache = <String, Map<int, _Cand>>{};

  bool get _fractional => level.allowsFractionalDivision;

  Solution? solve(List<int> digits) {
    for (var tier = 0; tier <= maxTier; tier++) {
      for (var split = 1; split < digits.length; split++) {
        final left = _values(digits.sublist(0, split), tier);
        final right = _values(digits.sublist(split), tier);
        final small = left.length <= right.length ? left : right;
        final big = identical(small, left) ? right : left;
        for (final key in small.keys) {
          if (!big.containsKey(key)) continue;
          final solution = _confirm(left[key]!, right[key]!, digits);
          if (solution != null) return solution;
        }
      }
    }
    return null;
  }

  bool isSolvable(List<int> digits) => solve(digits) != null;

  Solution? _confirm(_Cand left, _Cand right, List<int> digits) {
    var id = 0;
    Token make(_Piece p) => p.$1 == TokenKind.digit
        ? Token.digit(p.$2!, id: 's${id++}')
        : Token(p.$1, id: 's${id++}');
    final tokens = [
      for (final p in _stripOuter(left.pieces)) make(p),
      make((TokenKind.equals, null)),
      for (final p in _stripOuter(right.pieces)) make(p),
    ];
    final verdict = judge(tokens, digits: digits, level: level);
    return verdict is Correct ? Solution(tokens, verdict.value) : null;
  }

  Map<int, _Cand> _values(List<int> digits, int tier) {
    final cacheKey = '${digits.join()}|$tier';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final out = <int, _Cand>{};
    if (digits.length == 1) {
      final d = digits.single;
      _add(out, _Cand(d.toDouble(), [(TokenKind.digit, d)]));
      _unaryClosure(out, depth: tier >= 2 ? 2 : tier);
    } else {
      for (var k = 1; k < digits.length; k++) {
        final a = _values(digits.sublist(0, k), tier);
        final b = _values(digits.sublist(k), tier);
        for (final x in a.values) {
          for (final y in b.values) {
            _binary(out, x, y);
          }
        }
      }
      _unaryClosure(out, depth: tier >= 1 ? 1 : 0);
    }
    _cache[cacheKey] = out;
    return out;
  }

  static int _key(double v) => (v * 1e6).round();

  bool _acceptable(double v) {
    if (!v.isFinite || v.abs() > _maxMagnitude) return false;
    return _fractional || _isInt(v);
  }

  void _add(Map<int, _Cand> out, _Cand c) {
    if (!_acceptable(c.value)) return;
    if (out.length >= maxSetSize) return;
    out.putIfAbsent(_key(c.value), () => c);
  }

  void _binary(Map<int, _Cand> out, _Cand a, _Cand b) {
    List<_Piece> wrap(TokenKind op) =>
        [(TokenKind.parenOpen, null), ...a.pieces, (op, null), ...b.pieces, (TokenKind.parenClose, null)];

    _add(out, _Cand(a.value + b.value, wrap(TokenKind.plus)));
    _add(out, _Cand(a.value - b.value, wrap(TokenKind.minus)));
    _add(out, _Cand(a.value * b.value, wrap(TokenKind.times)));
    if (b.value.abs() > 1e-9) {
      final q = a.value / b.value;
      if (_fractional || _isInt(q)) _add(out, _Cand(q, wrap(TokenKind.divide)));
    }
    if (level.allows(TokenKind.power) && _isInt(b.value) && b.value.abs() <= 12) {
      if (a.value != 0 || b.value > 0) {
        final p = math.pow(a.value, b.value).toDouble();
        _add(out, _Cand(p, wrap(TokenKind.power)));
      }
    }
  }

  void _unaryClosure(Map<int, _Cand> out, {required int depth}) {
    var frontier = out.values.toList();
    for (var i = 0; i < depth; i++) {
      final next = <_Cand>[];
      for (final c in frontier) {
        for (final u in _unary(c)) {
          final before = out.length;
          _add(out, u);
          if (out.length > before) next.add(u);
        }
      }
      frontier = next;
    }
  }

  Iterable<_Cand> _unary(_Cand c) sync* {
    final v = c.value;
    final p = c.pieces;
    const open = (TokenKind.parenOpen, null);
    const close = (TokenKind.parenClose, null);

    if (v != 0) yield _Cand(-v, [open, (TokenKind.minus, null), ...p, close]);
    if (v < 0 && level.allows(TokenKind.absOpen)) {
      yield _Cand(-v, [(TokenKind.absOpen, null), ...p, (TokenKind.absClose, null)]);
    }
    if (level.allows(TokenKind.sqrt) && v > 1) {
      final r = math.sqrt(v);
      if (_isInt(r)) yield _Cand(r.roundToDouble(), [open, (TokenKind.sqrt, null), ...p, close]);
    }
    if (level.allows(TokenKind.cbrt) && v.abs() > 1) {
      final r = math.pow(v.abs(), 1 / 3).toDouble();
      if (_isInt(r)) {
        final signed = v < 0 ? -r.roundToDouble() : r.roundToDouble();
        yield _Cand(signed, [open, (TokenKind.cbrt, null), ...p, close]);
      }
    }
    if (level.allows(TokenKind.factorial) && _isInt(v)) {
      final n = v.round();
      if (n == 0 || (n >= 3 && n <= 10)) {
        var f = 1.0;
        for (var i = 2; i <= n; i++) {
          f *= i;
        }
        yield _Cand(f, [open, ...p, (TokenKind.factorial, null), close]);
      }
    }
    if (!_isInt(v)) {
      if (level.allows(TokenKind.floorOpen)) {
        yield _Cand(v.floorToDouble(), [(TokenKind.floorOpen, null), ...p, (TokenKind.floorClose, null)]);
      }
      if (level.allows(TokenKind.ceilOpen)) {
        yield _Cand(v.ceilToDouble(), [(TokenKind.ceilOpen, null), ...p, (TokenKind.ceilClose, null)]);
      }
    }
  }

  static bool _isInt(double x) => (x - x.roundToDouble()).abs() < 1e-9 * math.max(1, x.abs());

  /// Tira um par de parênteses que envolve o lado inteiro, só para a resposta
  /// ficar mais legível.
  static List<_Piece> _stripOuter(List<_Piece> pieces) {
    if (pieces.length < 2 ||
        pieces.first.$1 != TokenKind.parenOpen ||
        pieces.last.$1 != TokenKind.parenClose) {
      return pieces;
    }
    var depth = 0;
    for (var i = 0; i < pieces.length - 1; i++) {
      final kind = pieces[i].$1;
      if (kind.isOpener) depth++;
      if (kind.isCloser) depth--;
      if (depth == 0) return pieces;
    }
    return pieces.sublist(1, pieces.length - 1);
  }
}
