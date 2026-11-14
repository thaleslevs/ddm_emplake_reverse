// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelHard => 'Hard';

  @override
  String get gameInstructions =>
      'Drag the pieces to build a true equality with the 4 digits.';

  @override
  String get gameRemoveHint =>
      'To remove a piece, drag it out of the expression or double-tap it.';

  @override
  String get gameEqualsHolder => 'Drag the = into the expression';

  @override
  String get gamePreviewEmpty => 'The formula shows up here as you build it.';

  @override
  String get gameCheck => 'Check';

  @override
  String get gameClear => 'Clear';

  @override
  String get gameSkip => 'Skip';

  @override
  String gameNumberLabel(String number) {
    return 'Number $number';
  }

  @override
  String verdictCorrect(String value) {
    return 'Correct! Both sides equal $value.';
  }

  @override
  String verdictIncorrect(String left, String right) {
    return 'Not yet: the left side is $left and the right side is $right.';
  }

  @override
  String get solvedTitle => 'Solved!';

  @override
  String get errMissingEquals => 'Place the = sign in the expression.';

  @override
  String get errMultipleEquals => 'Use only one = sign.';

  @override
  String get errEmptyLeft => 'Something is missing on the left of the =.';

  @override
  String get errEmptyRight => 'Something is missing on the right of the =.';

  @override
  String get errDigitsMismatch =>
      'The four digits must stay in their original order.';

  @override
  String get errOperatorNotAllowed =>
      'This operator is not available at this level.';

  @override
  String get errMissingOperator =>
      'An operator is missing here. Digits don\'t join: 2 3 is not 23.';

  @override
  String get errMissingOperand =>
      'A number or expression is missing next to this operator.';

  @override
  String get errUnclosedGroup => 'This group was opened but never closed.';

  @override
  String get errUnexpectedCloser =>
      'This closing piece doesn\'t match any opening.';

  @override
  String get errMisplacedFactorial =>
      'The ! must come right after a number or group.';

  @override
  String get errDivisionByZero => 'You can\'t divide by zero.';

  @override
  String get errNonIntegerDivision =>
      'At this level, divisions must result in a whole number.';

  @override
  String get errNegativeSqrt => 'Negative numbers have no square root.';

  @override
  String get errInvalidFactorial =>
      'Factorial only exists for non-negative integers.';

  @override
  String errFactorialTooLarge(int max) {
    return 'Factorial too large (the maximum is $max!).';
  }

  @override
  String get errUndefinedResult =>
      'This calculation doesn\'t produce a valid number.';

  @override
  String get opPlus => 'Addition';

  @override
  String get opMinus => 'Subtraction or negative sign';

  @override
  String get opTimes => 'Multiplication';

  @override
  String get opDivide => 'Division';

  @override
  String get opPower => 'Power';

  @override
  String get opSqrt => 'Square root';

  @override
  String get opCbrt => 'Cube root';

  @override
  String get opFactorial => 'Factorial';

  @override
  String get opParenOpen => 'Open parenthesis';

  @override
  String get opParenClose => 'Close parenthesis';

  @override
  String get opAbsOpen => 'Open absolute value';

  @override
  String get opAbsClose => 'Close absolute value';

  @override
  String get opFloorOpen => 'Open floor (round down)';

  @override
  String get opFloorClose => 'Close floor';

  @override
  String get opCeilOpen => 'Open ceiling (round up)';

  @override
  String get opCeilClose => 'Close ceiling';

  @override
  String get opEquals => 'Equals';
}
