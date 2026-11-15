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
  String get loginSubtitle =>
      'Sign in to keep track of the numbers you\'ve solved.';

  @override
  String get registerSubtitle =>
      'Create an account to keep track of the numbers you solve.';

  @override
  String get loginTeam => 'Made by';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get signOut => 'Sign out';

  @override
  String get loadingSolved => 'Loading your numbers…';

  @override
  String get solvedLoadError =>
      'Couldn\'t load your solved numbers. New solves will still be saved.';

  @override
  String get navPlay => 'Play';

  @override
  String get navHistory => 'History';

  @override
  String get navHelp => 'Help';

  @override
  String get navSettings => 'Settings';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpRuleGoal =>
      'Build a true equality using the 4 digits of the number, in the order they appear.';

  @override
  String get helpRuleDrag =>
      'Drag operators before, between or after the digits. To remove a piece, drag it out or double-tap it.';

  @override
  String get helpRuleEquals =>
      'The = sign is a single piece: place it where the equality splits.';

  @override
  String get helpRuleNoJoin =>
      'Digits don\'t join: 2 3 is not 23. There must always be an operator between two digits.';

  @override
  String get helpRuleLevels =>
      'The harder the level, the fewer the operators. Only Easy accepts divisions that don\'t give a whole number.';

  @override
  String get helpRuleSolved =>
      'Every number you solve is saved to your account and won\'t show up again at that level. If you get stuck, use Skip.';

  @override
  String get helpClose => 'Got it';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty =>
      'You haven\'t solved any number yet. Your solves show up here.';

  @override
  String get historyLoadError => 'Couldn\'t load your history.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsMode => 'Appearance';

  @override
  String get modeSystem => 'System';

  @override
  String get modeLight => 'Light';

  @override
  String get modeDark => 'Dark';

  @override
  String get settingsAccent => 'Accent color';

  @override
  String get accentTheme => 'Theme\'s';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentSky => 'Sky';

  @override
  String get accentMint => 'Mint';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentRose => 'Rose';

  @override
  String get settingsFont => 'Text font';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get sizeExtraLarge => 'Extra large';

  @override
  String get settingsPreview => 'This is how the game text looks.';

  @override
  String get settingsSound => 'Sound';

  @override
  String get soundTurnOn => 'Turn sound on';

  @override
  String get soundTurnOff => 'Turn sound off';

  @override
  String get musicTurnOn => 'Turn music on';

  @override
  String get musicTurnOff => 'Turn music off';

  @override
  String get music => 'Music';

  @override
  String get musicHint =>
      'Original soundtrack, played by the game itself. Off by default.';

  @override
  String get themeToLight => 'Switch to light mode';

  @override
  String get themeToDark => 'Switch to dark mode';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsHint =>
      'Sounds for solving, mistakes, pieces and skipping. Off by default.';

  @override
  String settingsSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String themeTooltip(String name) {
    return 'Change theme (current: $name)';
  }

  @override
  String get themeFelt => 'Felt';

  @override
  String get themeCosmic => 'Cosmic';

  @override
  String get themeMinimal => 'Minimal';

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
