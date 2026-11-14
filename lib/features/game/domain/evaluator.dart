import 'dart:math' as math;

import 'errors.dart';
import 'expression.dart';
import 'level.dart';

class Evaluator {
  const Evaluator(this.level);

  final Level level;

  static const maxFactorial = 20;

  static const maxMagnitude = 1e15;

  static const _eps = 1e-9;

  double evaluate(Expr expr) {
    final value = switch (expr) {
      Num(:final value) => value.toDouble(),
      Negate(:final operand) => -evaluate(operand),
      Binary() => _binary(expr),
      Power() => _power(expr),
      Root() => _root(expr),
      Factorial() => _factorial(expr),
      Group() => _group(expr),
    };
    if (!value.isFinite || value.abs() > maxMagnitude) {
      throw UndefinedResult(tokenIndex: expr.tokenIndex);
    }
    return snap(value);
  }

  double _binary(Binary e) {
    final l = evaluate(e.left);
    final r = evaluate(e.right);
    switch (e.op) {
      case BinaryOp.add:
        return l + r;
      case BinaryOp.subtract:
        return l - r;
      case BinaryOp.multiply:
        return l * r;
      case BinaryOp.divide:
        if (r.abs() < _eps) throw DivisionByZero(tokenIndex: e.tokenIndex);
        final q = l / r;
        if (!level.allowsFractionalDivision && !isInteger(q)) {
          throw NonIntegerDivision(tokenIndex: e.tokenIndex);
        }
        return q;
    }
  }

  double _power(Power e) {
    final base = evaluate(e.base);
    final exponent = evaluate(e.exponent);
    final result = math.pow(base, exponent).toDouble();
    if (result.isNaN || result.isInfinite) {
      throw UndefinedResult(tokenIndex: e.tokenIndex);
    }
    return result;
  }

  double _root(Root e) {
    final v = evaluate(e.operand);
    switch (e.kind) {
      case RootKind.square:
        if (v < 0) throw NegativeSqrt(tokenIndex: e.tokenIndex);
        return math.sqrt(v);
      case RootKind.cube:
        final r = math.pow(v.abs(), 1 / 3).toDouble();
        return v < 0 ? -r : r;
    }
  }

  double _factorial(Factorial e) {
    final v = evaluate(e.operand);
    if (v < 0 || !isInteger(v)) throw InvalidFactorial(tokenIndex: e.tokenIndex);
    final n = v.round();
    if (n > maxFactorial) {
      throw FactorialTooLarge(maxFactorial, tokenIndex: e.tokenIndex);
    }
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double _group(Group e) {
    final v = evaluate(e.inner);
    return switch (e.kind) {
      GroupKind.paren => v,
      GroupKind.abs => v.abs(),
      GroupKind.floor => v.floorToDouble(),
      GroupKind.ceil => v.ceilToDouble(),
    };
  }

  static bool isInteger(double x) => (x - x.roundToDouble()).abs() < _eps * math.max(1, x.abs());

  static double snap(double x) => isInteger(x) ? x.roundToDouble() : x;

  static bool areEqual(double a, double b) => (a - b).abs() <= _eps * math.max(1, math.max(a.abs(), b.abs()));
}
