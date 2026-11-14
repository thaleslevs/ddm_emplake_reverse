import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @levelEasy.
  ///
  /// In pt, this message translates to:
  /// **'Fácil'**
  String get levelEasy;

  /// No description provided for @levelIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get levelAdvanced;

  /// No description provided for @levelHard.
  ///
  /// In pt, this message translates to:
  /// **'Difícil'**
  String get levelHard;

  /// No description provided for @gameInstructions.
  ///
  /// In pt, this message translates to:
  /// **'Arraste as peças para formar uma igualdade verdadeira com os 4 dígitos.'**
  String get gameInstructions;

  /// No description provided for @gameRemoveHint.
  ///
  /// In pt, this message translates to:
  /// **'Para remover uma peça, arraste-a para fora da expressão ou toque nela duas vezes.'**
  String get gameRemoveHint;

  /// No description provided for @gameEqualsHolder.
  ///
  /// In pt, this message translates to:
  /// **'Arraste o = para a expressão'**
  String get gameEqualsHolder;

  /// No description provided for @gamePreviewEmpty.
  ///
  /// In pt, this message translates to:
  /// **'A fórmula aparece aqui enquanto você monta.'**
  String get gamePreviewEmpty;

  /// No description provided for @gameCheck.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get gameCheck;

  /// No description provided for @gameClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get gameClear;

  /// No description provided for @gameSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get gameSkip;

  /// No description provided for @gameNumberLabel.
  ///
  /// In pt, this message translates to:
  /// **'Número {number}'**
  String gameNumberLabel(String number);

  /// No description provided for @verdictCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Correto! Os dois lados valem {value}.'**
  String verdictCorrect(String value);

  /// No description provided for @verdictIncorrect.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não: a esquerda vale {left} e a direita vale {right}.'**
  String verdictIncorrect(String left, String right);

  /// No description provided for @solvedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resolvido!'**
  String get solvedTitle;

  /// No description provided for @errMissingEquals.
  ///
  /// In pt, this message translates to:
  /// **'Coloque o sinal de = na expressão.'**
  String get errMissingEquals;

  /// No description provided for @errMultipleEquals.
  ///
  /// In pt, this message translates to:
  /// **'Use apenas um sinal de =.'**
  String get errMultipleEquals;

  /// No description provided for @errEmptyLeft.
  ///
  /// In pt, this message translates to:
  /// **'Falta uma expressão à esquerda do =.'**
  String get errEmptyLeft;

  /// No description provided for @errEmptyRight.
  ///
  /// In pt, this message translates to:
  /// **'Falta uma expressão à direita do =.'**
  String get errEmptyRight;

  /// No description provided for @errDigitsMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Os quatro dígitos precisam continuar na ordem original.'**
  String get errDigitsMismatch;

  /// No description provided for @errOperatorNotAllowed.
  ///
  /// In pt, this message translates to:
  /// **'Este operador não está disponível neste nível.'**
  String get errOperatorNotAllowed;

  /// No description provided for @errMissingOperator.
  ///
  /// In pt, this message translates to:
  /// **'Falta um operador aqui. Os dígitos não se juntam: 2 3 não vira 23.'**
  String get errMissingOperator;

  /// No description provided for @errMissingOperand.
  ///
  /// In pt, this message translates to:
  /// **'Falta um número ou expressão perto deste operador.'**
  String get errMissingOperand;

  /// No description provided for @errUnclosedGroup.
  ///
  /// In pt, this message translates to:
  /// **'Este grupo foi aberto e não foi fechado.'**
  String get errUnclosedGroup;

  /// No description provided for @errUnexpectedCloser.
  ///
  /// In pt, this message translates to:
  /// **'Este fechamento não combina com nenhuma abertura.'**
  String get errUnexpectedCloser;

  /// No description provided for @errMisplacedFactorial.
  ///
  /// In pt, this message translates to:
  /// **'O ! precisa vir logo depois de um número ou grupo.'**
  String get errMisplacedFactorial;

  /// No description provided for @errDivisionByZero.
  ///
  /// In pt, this message translates to:
  /// **'Não dá para dividir por zero.'**
  String get errDivisionByZero;

  /// No description provided for @errNonIntegerDivision.
  ///
  /// In pt, this message translates to:
  /// **'Neste nível, as divisões precisam dar um número inteiro.'**
  String get errNonIntegerDivision;

  /// No description provided for @errNegativeSqrt.
  ///
  /// In pt, this message translates to:
  /// **'Não existe raiz quadrada de número negativo.'**
  String get errNegativeSqrt;

  /// No description provided for @errInvalidFactorial.
  ///
  /// In pt, this message translates to:
  /// **'O fatorial só existe para inteiros não negativos.'**
  String get errInvalidFactorial;

  /// No description provided for @errFactorialTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'Fatorial grande demais (o máximo é {max}!).'**
  String errFactorialTooLarge(int max);

  /// No description provided for @errUndefinedResult.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta não resulta em um número válido.'**
  String get errUndefinedResult;

  /// No description provided for @opPlus.
  ///
  /// In pt, this message translates to:
  /// **'Soma'**
  String get opPlus;

  /// No description provided for @opMinus.
  ///
  /// In pt, this message translates to:
  /// **'Subtração ou sinal negativo'**
  String get opMinus;

  /// No description provided for @opTimes.
  ///
  /// In pt, this message translates to:
  /// **'Multiplicação'**
  String get opTimes;

  /// No description provided for @opDivide.
  ///
  /// In pt, this message translates to:
  /// **'Divisão'**
  String get opDivide;

  /// No description provided for @opPower.
  ///
  /// In pt, this message translates to:
  /// **'Potência'**
  String get opPower;

  /// No description provided for @opSqrt.
  ///
  /// In pt, this message translates to:
  /// **'Raiz quadrada'**
  String get opSqrt;

  /// No description provided for @opCbrt.
  ///
  /// In pt, this message translates to:
  /// **'Raiz cúbica'**
  String get opCbrt;

  /// No description provided for @opFactorial.
  ///
  /// In pt, this message translates to:
  /// **'Fatorial'**
  String get opFactorial;

  /// No description provided for @opParenOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abre parêntese'**
  String get opParenOpen;

  /// No description provided for @opParenClose.
  ///
  /// In pt, this message translates to:
  /// **'Fecha parêntese'**
  String get opParenClose;

  /// No description provided for @opAbsOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abre módulo'**
  String get opAbsOpen;

  /// No description provided for @opAbsClose.
  ///
  /// In pt, this message translates to:
  /// **'Fecha módulo'**
  String get opAbsClose;

  /// No description provided for @opFloorOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abre piso (arredonda para baixo)'**
  String get opFloorOpen;

  /// No description provided for @opFloorClose.
  ///
  /// In pt, this message translates to:
  /// **'Fecha piso'**
  String get opFloorClose;

  /// No description provided for @opCeilOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abre teto (arredonda para cima)'**
  String get opCeilOpen;

  /// No description provided for @opCeilClose.
  ///
  /// In pt, this message translates to:
  /// **'Fecha teto'**
  String get opCeilClose;

  /// No description provided for @opEquals.
  ///
  /// In pt, this message translates to:
  /// **'Igual'**
  String get opEquals;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
