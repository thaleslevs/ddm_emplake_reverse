// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Emplake';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get levelHard => 'Difícil';

  @override
  String get gameInstructions =>
      'Arraste as peças para formar uma igualdade verdadeira com os 4 dígitos.';

  @override
  String get gameRemoveHint =>
      'Para remover uma peça, arraste-a para fora da expressão ou toque nela duas vezes.';

  @override
  String get gameEqualsHolder => 'Arraste o = para a expressão';

  @override
  String get gamePreviewEmpty => 'A fórmula aparece aqui enquanto você monta.';

  @override
  String get gameCheck => 'Verificar';

  @override
  String get gameClear => 'Limpar';

  @override
  String get gameSkip => 'Pular';

  @override
  String gameNumberLabel(String number) {
    return 'Número $number';
  }

  @override
  String verdictCorrect(String value) {
    return 'Correto! Os dois lados valem $value.';
  }

  @override
  String verdictIncorrect(String left, String right) {
    return 'Ainda não: a esquerda vale $left e a direita vale $right.';
  }

  @override
  String get solvedTitle => 'Resolvido!';

  @override
  String get errMissingEquals => 'Coloque o sinal de = na expressão.';

  @override
  String get errMultipleEquals => 'Use apenas um sinal de =.';

  @override
  String get errEmptyLeft => 'Falta uma expressão à esquerda do =.';

  @override
  String get errEmptyRight => 'Falta uma expressão à direita do =.';

  @override
  String get errDigitsMismatch =>
      'Os quatro dígitos precisam continuar na ordem original.';

  @override
  String get errOperatorNotAllowed =>
      'Este operador não está disponível neste nível.';

  @override
  String get errMissingOperator =>
      'Falta um operador aqui. Os dígitos não se juntam: 2 3 não vira 23.';

  @override
  String get errMissingOperand =>
      'Falta um número ou expressão perto deste operador.';

  @override
  String get errUnclosedGroup => 'Este grupo foi aberto e não foi fechado.';

  @override
  String get errUnexpectedCloser =>
      'Este fechamento não combina com nenhuma abertura.';

  @override
  String get errMisplacedFactorial =>
      'O ! precisa vir logo depois de um número ou grupo.';

  @override
  String get errDivisionByZero => 'Não dá para dividir por zero.';

  @override
  String get errNonIntegerDivision =>
      'Neste nível, as divisões precisam dar um número inteiro.';

  @override
  String get errNegativeSqrt => 'Não existe raiz quadrada de número negativo.';

  @override
  String get errInvalidFactorial =>
      'O fatorial só existe para inteiros não negativos.';

  @override
  String errFactorialTooLarge(int max) {
    return 'Fatorial grande demais (o máximo é $max!).';
  }

  @override
  String get errUndefinedResult =>
      'Esta conta não resulta em um número válido.';

  @override
  String get opPlus => 'Soma';

  @override
  String get opMinus => 'Subtração ou sinal negativo';

  @override
  String get opTimes => 'Multiplicação';

  @override
  String get opDivide => 'Divisão';

  @override
  String get opPower => 'Potência';

  @override
  String get opSqrt => 'Raiz quadrada';

  @override
  String get opCbrt => 'Raiz cúbica';

  @override
  String get opFactorial => 'Fatorial';

  @override
  String get opParenOpen => 'Abre parêntese';

  @override
  String get opParenClose => 'Fecha parêntese';

  @override
  String get opAbsOpen => 'Abre módulo';

  @override
  String get opAbsClose => 'Fecha módulo';

  @override
  String get opFloorOpen => 'Abre piso (arredonda para baixo)';

  @override
  String get opFloorClose => 'Fecha piso';

  @override
  String get opCeilOpen => 'Abre teto (arredonda para cima)';

  @override
  String get opCeilClose => 'Fecha teto';

  @override
  String get opEquals => 'Igual';
}
