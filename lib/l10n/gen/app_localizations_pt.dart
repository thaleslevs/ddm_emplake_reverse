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
  String get loginSubtitle =>
      'Entre para guardar os números que você já resolveu.';

  @override
  String get registerSubtitle =>
      'Crie uma conta para guardar os números que você resolver.';

  @override
  String get loginTeam => 'Desenvolvido por';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'English';

  @override
  String get signOut => 'Sair';

  @override
  String get loadingSolved => 'Carregando seus números…';

  @override
  String get solvedLoadError =>
      'Não deu para carregar seus números resolvidos. Os próximos acertos continuam sendo salvos.';

  @override
  String get navPlay => 'Jogar';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navHelp => 'Ajuda';

  @override
  String get navSettings => 'Configurações';

  @override
  String get helpTitle => 'Como jogar';

  @override
  String get helpRuleGoal =>
      'Monte uma igualdade verdadeira usando os 4 dígitos do número, na ordem em que aparecem.';

  @override
  String get helpRuleDrag =>
      'Arraste operadores para antes, entre ou depois dos dígitos. Para tirar uma peça, arraste-a para fora ou toque nela duas vezes.';

  @override
  String get helpRuleEquals =>
      'O sinal de = é uma peça só: coloque-o onde a igualdade se divide.';

  @override
  String get helpRuleNoJoin =>
      'Os dígitos não se juntam: 2 3 não vira 23. Entre dois dígitos sempre precisa haver um operador.';

  @override
  String get helpRuleLevels =>
      'Quanto mais difícil o nível, menos operadores. Só o Fácil aceita divisões que não dão número inteiro.';

  @override
  String get helpRuleSolved =>
      'Cada número resolvido fica salvo na sua conta e não volta a aparecer naquele nível. Se travar, use Pular.';

  @override
  String get helpClose => 'Entendi';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty =>
      'Você ainda não resolveu nenhum número. Os acertos aparecem aqui.';

  @override
  String get historyLoadError => 'Não deu para carregar o histórico.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsMode => 'Aparência';

  @override
  String get modeSystem => 'Sistema';

  @override
  String get modeLight => 'Claro';

  @override
  String get modeDark => 'Escuro';

  @override
  String get settingsAccent => 'Cor de destaque';

  @override
  String get accentTheme => 'Do tema';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentSky => 'Céu';

  @override
  String get accentMint => 'Menta';

  @override
  String get accentViolet => 'Violeta';

  @override
  String get accentRose => 'Rosa';

  @override
  String get settingsFont => 'Fonte do texto';

  @override
  String get settingsTextSize => 'Tamanho do texto';

  @override
  String get sizeSmall => 'Pequeno';

  @override
  String get sizeMedium => 'Médio';

  @override
  String get sizeLarge => 'Grande';

  @override
  String get sizeExtraLarge => 'Muito grande';

  @override
  String get settingsPreview => 'Assim fica o texto do jogo.';

  @override
  String get settingsSound => 'Som';

  @override
  String get soundTurnOn => 'Ligar o som';

  @override
  String get soundTurnOff => 'Desligar o som';

  @override
  String get musicTurnOn => 'Ligar a música';

  @override
  String get musicTurnOff => 'Desligar a música';

  @override
  String get music => 'Música';

  @override
  String get musicHint =>
      'Trilha original, tocada pelo próprio jogo. Começa desligada.';

  @override
  String get themeToLight => 'Mudar para o modo claro';

  @override
  String get themeToDark => 'Mudar para o modo escuro';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get soundEffectsHint =>
      'Sons de acerto, erro, peças e pular. Começa desligado.';

  @override
  String settingsSignedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String themeTooltip(String name) {
    return 'Trocar tema (atual: $name)';
  }

  @override
  String get themeFelt => 'Feltro';

  @override
  String get themeCosmic => 'Cósmico';

  @override
  String get themeMinimal => 'Minimalista';

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
