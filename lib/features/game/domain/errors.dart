import 'token.dart';

sealed class EquationError implements Exception {
  const EquationError({this.tokenIndex});
  final int? tokenIndex;
}

final class MissingEquals extends EquationError {
  const MissingEquals();
}

final class MultipleEquals extends EquationError {
  const MultipleEquals({super.tokenIndex});
}

final class EmptySide extends EquationError {
  const EmptySide({required this.left, super.tokenIndex});
  final bool left;
}

final class DigitsMismatch extends EquationError {
  const DigitsMismatch();
}

final class OperatorNotAllowed extends EquationError {
  const OperatorNotAllowed(this.kind, {super.tokenIndex});
  final TokenKind kind;
}

final class MissingOperator extends EquationError {
  const MissingOperator({super.tokenIndex});
}

final class MissingOperand extends EquationError {
  const MissingOperand({super.tokenIndex});
}

final class UnclosedGroup extends EquationError {
  const UnclosedGroup(this.opener, {super.tokenIndex});
  final TokenKind opener;
}

final class UnexpectedCloser extends EquationError {
  const UnexpectedCloser(this.closer, {super.tokenIndex});
  final TokenKind closer;
}

final class MisplacedFactorial extends EquationError {
  const MisplacedFactorial({super.tokenIndex});
}

final class DivisionByZero extends EquationError {
  const DivisionByZero({super.tokenIndex});
}

final class NonIntegerDivision extends EquationError {
  const NonIntegerDivision({super.tokenIndex});
}

final class NegativeSqrt extends EquationError {
  const NegativeSqrt({super.tokenIndex});
}

final class InvalidFactorial extends EquationError {
  const InvalidFactorial({super.tokenIndex});
}

final class FactorialTooLarge extends EquationError {
  const FactorialTooLarge(this.max, {super.tokenIndex});
  final int max;
}

final class UndefinedResult extends EquationError {
  const UndefinedResult({super.tokenIndex});
}
