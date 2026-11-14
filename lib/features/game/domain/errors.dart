import 'token.dart';

/// Why an equation could not be evaluated. Messages are produced by the UI
/// through localization, so errors only carry data.
///
/// [tokenIndex] points at the offending piece when there is one, so the UI
/// can highlight it.
sealed class EquationError implements Exception {
  const EquationError({this.tokenIndex});
  final int? tokenIndex;
}

// --- Structure -------------------------------------------------------------

final class MissingEquals extends EquationError {
  const MissingEquals();
}

final class MultipleEquals extends EquationError {
  const MultipleEquals({super.tokenIndex});
}

/// One side of `=` is empty.
final class EmptySide extends EquationError {
  const EmptySide({required this.left, super.tokenIndex});
  final bool left;
}

/// The digits on the board do not match the puzzle (order changed or missing).
final class DigitsMismatch extends EquationError {
  const DigitsMismatch();
}

final class OperatorNotAllowed extends EquationError {
  const OperatorNotAllowed(this.kind, {super.tokenIndex});
  final TokenKind kind;
}

// --- Syntax ----------------------------------------------------------------

/// Two operands side by side, e.g. `2 3` or `2 (3)`. Digits never concatenate.
final class MissingOperator extends EquationError {
  const MissingOperator({super.tokenIndex});
}

/// An operand was expected (e.g. `2 + = 3`, `× 2`, `√ )`).
final class MissingOperand extends EquationError {
  const MissingOperand({super.tokenIndex});
}

final class UnclosedGroup extends EquationError {
  const UnclosedGroup(this.opener, {super.tokenIndex});
  final TokenKind opener;
}

/// A closer without its opener, or the wrong closer (e.g. `( 2 ⌋`).
final class UnexpectedCloser extends EquationError {
  const UnexpectedCloser(this.closer, {super.tokenIndex});
  final TokenKind closer;
}

/// `!` with nothing before it.
final class MisplacedFactorial extends EquationError {
  const MisplacedFactorial({super.tokenIndex});
}

// --- Math ------------------------------------------------------------------

final class DivisionByZero extends EquationError {
  const DivisionByZero({super.tokenIndex});
}

/// Non-integer division in a level that forbids it.
final class NonIntegerDivision extends EquationError {
  const NonIntegerDivision({super.tokenIndex});
}

final class NegativeSqrt extends EquationError {
  const NegativeSqrt({super.tokenIndex});
}

/// Factorial of a negative or non-integer value.
final class InvalidFactorial extends EquationError {
  const InvalidFactorial({super.tokenIndex});
}

final class FactorialTooLarge extends EquationError {
  const FactorialTooLarge(this.max, {super.tokenIndex});
  final int max;
}

/// Result is infinite, NaN or too large to compare reliably
/// (e.g. `0 ** -1`, `(-8) ** 0.5`, `9 ** 99`).
final class UndefinedResult extends EquationError {
  const UndefinedResult({super.tokenIndex});
}
