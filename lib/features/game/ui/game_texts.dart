import 'package:intl/intl.dart';

import '../../../core/theme/game_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/errors.dart';
import '../domain/evaluator.dart';
import '../domain/level.dart';
import '../domain/token.dart';

extension GameTexts on AppLocalizations {
  String themeName(ThemeVariant variant) => switch (variant) {
    ThemeVariant.felt => themeFelt,
    ThemeVariant.cosmic => themeCosmic,
    ThemeVariant.minimal => themeMinimal,
  };

  String levelName(Level level) => switch (level) {
    Level.easy => levelEasy,
    Level.intermediate => levelIntermediate,
    Level.advanced => levelAdvanced,
    Level.hard => levelHard,
  };

  String operatorName(TokenKind kind) => switch (kind) {
    TokenKind.plus => opPlus,
    TokenKind.minus => opMinus,
    TokenKind.times => opTimes,
    TokenKind.divide => opDivide,
    TokenKind.power => opPower,
    TokenKind.sqrt => opSqrt,
    TokenKind.cbrt => opCbrt,
    TokenKind.factorial => opFactorial,
    TokenKind.parenOpen => opParenOpen,
    TokenKind.parenClose => opParenClose,
    TokenKind.absOpen => opAbsOpen,
    TokenKind.absClose => opAbsClose,
    TokenKind.floorOpen => opFloorOpen,
    TokenKind.floorClose => opFloorClose,
    TokenKind.ceilOpen => opCeilOpen,
    TokenKind.ceilClose => opCeilClose,
    TokenKind.equals => opEquals,
    TokenKind.digit => '',
  };

  String errorMessage(EquationError error) => switch (error) {
    MissingEquals() => errMissingEquals,
    MultipleEquals() => errMultipleEquals,
    EmptySide(left: true) => errEmptyLeft,
    EmptySide(left: false) => errEmptyRight,
    DigitsMismatch() => errDigitsMismatch,
    OperatorNotAllowed() => errOperatorNotAllowed,
    MissingOperator() => errMissingOperator,
    MissingOperand() => errMissingOperand,
    UnclosedGroup() => errUnclosedGroup,
    UnexpectedCloser() => errUnexpectedCloser,
    MisplacedFactorial() => errMisplacedFactorial,
    DivisionByZero() => errDivisionByZero,
    NonIntegerDivision() => errNonIntegerDivision,
    NegativeSqrt() => errNegativeSqrt,
    InvalidFactorial() => errInvalidFactorial,
    FactorialTooLarge(:final max) => errFactorialTooLarge(max),
    UndefinedResult() => errUndefinedResult,
  };

  String formatValue(double value) {
    final format = NumberFormat.decimalPattern(localeName)..maximumFractionDigits = 4;
    return format.format(Evaluator.snap(value));
  }
}
