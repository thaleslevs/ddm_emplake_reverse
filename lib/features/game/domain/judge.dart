import 'errors.dart';
import 'evaluator.dart';
import 'expression.dart';
import 'level.dart';
import 'parser.dart';
import 'token.dart';

/// Outcome of checking the board.
sealed class Verdict {
  const Verdict();
}

/// Both sides evaluate to the same [value].
final class Correct extends Verdict {
  const Correct(this.value);
  final double value;
}

/// Valid equation, but the sides differ.
final class Incorrect extends Verdict {
  const Incorrect(this.left, this.right);
  final double left;
  final double right;
}

/// The board cannot be evaluated.
final class Invalid extends Verdict {
  const Invalid(this.error);
  final EquationError error;
}

/// Parses the board into an [Equation], validating structure only
/// (no arithmetic). Throws [EquationError].
Equation parseEquation(List<Token> tokens) {
  final equalsAt = <int>[
    for (var i = 0; i < tokens.length; i++)
      if (tokens[i].kind == TokenKind.equals) i,
  ];
  if (equalsAt.isEmpty) throw const MissingEquals();
  if (equalsAt.length > 1) throw MultipleEquals(tokenIndex: equalsAt[1]);

  final eq = equalsAt.single;
  if (eq == 0) throw EmptySide(left: true, tokenIndex: eq);
  if (eq == tokens.length - 1) throw EmptySide(left: false, tokenIndex: eq);

  final left = SideParser(tokens.sublist(0, eq)).parse();
  final right = SideParser(tokens.sublist(eq + 1), offset: eq + 1).parse();
  return Equation(left, right);
}

/// Checks the board against the puzzle [digits] and the [level] rules.
Verdict judge(List<Token> tokens, {required List<int> digits, required Level level}) {
  try {
    for (var i = 0; i < tokens.length; i++) {
      if (!level.allows(tokens[i].kind)) {
        throw OperatorNotAllowed(tokens[i].kind, tokenIndex: i);
      }
    }

    final boardDigits = [
      for (final t in tokens)
        if (t.kind == TokenKind.digit) t.value!,
    ];
    if (!_sameList(boardDigits, digits)) throw const DigitsMismatch();

    final equation = parseEquation(tokens);
    final evaluator = Evaluator(level);
    final left = evaluator.evaluate(equation.left);
    final right = evaluator.evaluate(equation.right);
    return Evaluator.areEqual(left, right) ? Correct(left) : Incorrect(left, right);
  } on EquationError catch (e) {
    return Invalid(e);
  }
}

bool _sameList(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
