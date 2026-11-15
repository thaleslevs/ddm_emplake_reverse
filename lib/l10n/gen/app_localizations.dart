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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Emplake'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para guardar os números que você já resolveu.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma conta para guardar os números que você resolver.'**
  String get registerSubtitle;

  /// No description provided for @loginTeam.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvido por'**
  String get loginTeam;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @loadingSolved.
  ///
  /// In pt, this message translates to:
  /// **'Carregando seus números…'**
  String get loadingSolved;

  /// No description provided for @solvedLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para carregar seus números resolvidos. Os próximos acertos continuam sendo salvos.'**
  String get solvedLoadError;

  /// No description provided for @navPlay.
  ///
  /// In pt, this message translates to:
  /// **'Jogar'**
  String get navPlay;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @navHelp.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get navHelp;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @helpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como jogar'**
  String get helpTitle;

  /// No description provided for @helpRuleGoal.
  ///
  /// In pt, this message translates to:
  /// **'Monte uma igualdade verdadeira usando os 4 dígitos do número, na ordem em que aparecem.'**
  String get helpRuleGoal;

  /// No description provided for @helpRuleDrag.
  ///
  /// In pt, this message translates to:
  /// **'Arraste operadores para antes, entre ou depois dos dígitos. Para tirar uma peça, arraste-a para fora ou toque nela duas vezes.'**
  String get helpRuleDrag;

  /// No description provided for @helpRuleEquals.
  ///
  /// In pt, this message translates to:
  /// **'O sinal de = é uma peça só: coloque-o onde a igualdade se divide.'**
  String get helpRuleEquals;

  /// No description provided for @helpRuleNoJoin.
  ///
  /// In pt, this message translates to:
  /// **'Os dígitos não se juntam: 2 3 não vira 23. Entre dois dígitos sempre precisa haver um operador.'**
  String get helpRuleNoJoin;

  /// No description provided for @helpRuleLevels.
  ///
  /// In pt, this message translates to:
  /// **'Quanto mais difícil o nível, menos operadores. Só o Fácil aceita divisões que não dão número inteiro.'**
  String get helpRuleLevels;

  /// No description provided for @helpRuleSolved.
  ///
  /// In pt, this message translates to:
  /// **'Cada número resolvido fica salvo na sua conta e não volta a aparecer naquele nível. Se travar, use Pular.'**
  String get helpRuleSolved;

  /// No description provided for @helpClose.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get helpClose;

  /// No description provided for @helpRuleScore.
  ///
  /// In pt, this message translates to:
  /// **'Cada número resolvido vale pontos conforme o nível: Fácil 1, Intermediário 2, Avançado 3 e Difícil 5. A pontuação fica salva na sua conta.'**
  String get helpRuleScore;

  /// No description provided for @helpRuleShop.
  ///
  /// In pt, this message translates to:
  /// **'Gaste pontos na Loja em skins para os palhaços e efeitos de acerto. O ranking conta todos os pontos que você já ganhou, mesmo os que gastou.'**
  String get helpRuleShop;

  /// No description provided for @navScores.
  ///
  /// In pt, this message translates to:
  /// **'Placar'**
  String get navScores;

  /// No description provided for @navShop.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get navShop;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @earnedLabel.
  ///
  /// In pt, this message translates to:
  /// **'{points, plural, =1{1 ponto ganho} other{{points} pontos ganhos}}'**
  String earnedLabel(int points);

  /// No description provided for @balanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'{points, plural, =1{Saldo: 1 ponto} other{Saldo: {points} pontos}}'**
  String balanceLabel(int points);

  /// No description provided for @scoresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Placar'**
  String get scoresTitle;

  /// No description provided for @scoresRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking geral'**
  String get scoresRanking;

  /// No description provided for @scoresMine.
  ///
  /// In pt, this message translates to:
  /// **'Meus números'**
  String get scoresMine;

  /// No description provided for @rankingNickname.
  ///
  /// In pt, this message translates to:
  /// **'Seu apelido: {name}'**
  String rankingNickname(String name);

  /// No description provided for @rankingEditNickname.
  ///
  /// In pt, this message translates to:
  /// **'Mudar'**
  String get rankingEditNickname;

  /// No description provided for @rankingNote.
  ///
  /// In pt, this message translates to:
  /// **'O ranking usa todos os pontos que cada jogador já ganhou; gastar na loja não tira ninguém do lugar.'**
  String get rankingNote;

  /// No description provided for @rankingLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para carregar o ranking.'**
  String get rankingLoadError;

  /// No description provided for @rankingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém pontuou ainda. Seja o primeiro!'**
  String get rankingEmpty;

  /// No description provided for @rankingYou.
  ///
  /// In pt, this message translates to:
  /// **'você'**
  String get rankingYou;

  /// No description provided for @rankingPosition.
  ///
  /// In pt, this message translates to:
  /// **'{position}º'**
  String rankingPosition(int position);

  /// No description provided for @nicknameDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu apelido no ranking'**
  String get nicknameDialogTitle;

  /// No description provided for @nicknameHint.
  ///
  /// In pt, this message translates to:
  /// **'De 1 a 20 caracteres'**
  String get nicknameHint;

  /// No description provided for @shopTitle.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get shopTitle;

  /// No description provided for @shopSkins.
  ///
  /// In pt, this message translates to:
  /// **'Skins dos palhaços'**
  String get shopSkins;

  /// No description provided for @shopEffects.
  ///
  /// In pt, this message translates to:
  /// **'Efeito de acerto'**
  String get shopEffects;

  /// No description provided for @shopEffectsHint.
  ///
  /// In pt, this message translates to:
  /// **'O que aparece na tela quando você acerta. Toque em Testar para ver.'**
  String get shopEffectsHint;

  /// No description provided for @shopBuy.
  ///
  /// In pt, this message translates to:
  /// **'{price, plural, =0{Grátis} other{Comprar · {price}}}'**
  String shopBuy(int price);

  /// No description provided for @shopMissing.
  ///
  /// In pt, this message translates to:
  /// **'{points, plural, =1{Falta 1} other{Faltam {points}}}'**
  String shopMissing(int points);

  /// No description provided for @shopEquip.
  ///
  /// In pt, this message translates to:
  /// **'Usar'**
  String get shopEquip;

  /// No description provided for @shopEquipped.
  ///
  /// In pt, this message translates to:
  /// **'Em uso'**
  String get shopEquipped;

  /// No description provided for @shopTry.
  ///
  /// In pt, this message translates to:
  /// **'Testar'**
  String get shopTry;

  /// No description provided for @shopBought.
  ///
  /// In pt, this message translates to:
  /// **'Comprado! Já está em uso.'**
  String get shopBought;

  /// No description provided for @shopNotEnough.
  ///
  /// In pt, this message translates to:
  /// **'Pontos insuficientes.'**
  String get shopNotEnough;

  /// No description provided for @shopBuyError.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para concluir a compra. Tente de novo.'**
  String get shopBuyError;

  /// No description provided for @skinClassic.
  ///
  /// In pt, this message translates to:
  /// **'Clássico'**
  String get skinClassic;

  /// No description provided for @skinWizard.
  ///
  /// In pt, this message translates to:
  /// **'Mago'**
  String get skinWizard;

  /// No description provided for @skinRobot.
  ///
  /// In pt, this message translates to:
  /// **'Robô'**
  String get skinRobot;

  /// No description provided for @skinPirate.
  ///
  /// In pt, this message translates to:
  /// **'Pirata'**
  String get skinPirate;

  /// No description provided for @skinNinja.
  ///
  /// In pt, this message translates to:
  /// **'Ninja'**
  String get skinNinja;

  /// No description provided for @skinAstronaut.
  ///
  /// In pt, this message translates to:
  /// **'Astronauta'**
  String get skinAstronaut;

  /// No description provided for @skinSkeleton.
  ///
  /// In pt, this message translates to:
  /// **'Caveira'**
  String get skinSkeleton;

  /// No description provided for @effectClowns.
  ///
  /// In pt, this message translates to:
  /// **'Palhaços'**
  String get effectClowns;

  /// No description provided for @effectConfetti.
  ///
  /// In pt, this message translates to:
  /// **'Confete'**
  String get effectConfetti;

  /// No description provided for @effectStars.
  ///
  /// In pt, this message translates to:
  /// **'Estrelas'**
  String get effectStars;

  /// No description provided for @effectCoins.
  ///
  /// In pt, this message translates to:
  /// **'Chuva de moedas'**
  String get effectCoins;

  /// No description provided for @effectFireworks.
  ///
  /// In pt, this message translates to:
  /// **'Fogos de artifício'**
  String get effectFireworks;

  /// No description provided for @musicVolume.
  ///
  /// In pt, this message translates to:
  /// **'Volume da música'**
  String get musicVolume;

  /// No description provided for @soundVolume.
  ///
  /// In pt, this message translates to:
  /// **'Volume dos efeitos'**
  String get soundVolume;

  /// No description provided for @scoreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get scoreTitle;

  /// No description provided for @scoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'{score, plural, =1{1 ponto} other{{score} pontos}}'**
  String scoreLabel(int score);

  /// No description provided for @historySolvedCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{Nenhum número resolvido ainda} =1{1 número resolvido} other{{count} números resolvidos}}'**
  String historySolvedCount(int count);

  /// No description provided for @pointsGained.
  ///
  /// In pt, this message translates to:
  /// **'{points, plural, =1{+1 ponto} other{+{points} pontos}}'**
  String pointsGained(int points);

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não resolveu nenhum número. Os acertos aparecem aqui.'**
  String get historyEmpty;

  /// No description provided for @historyLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para carregar o histórico.'**
  String get historyLoadError;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccount;

  /// No description provided for @settingsMode.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsMode;

  /// No description provided for @modeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get modeSystem;

  /// No description provided for @modeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get modeLight;

  /// No description provided for @modeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get modeDark;

  /// No description provided for @settingsAccent.
  ///
  /// In pt, this message translates to:
  /// **'Cor de destaque'**
  String get settingsAccent;

  /// No description provided for @accentTheme.
  ///
  /// In pt, this message translates to:
  /// **'Do tema'**
  String get accentTheme;

  /// No description provided for @accentCoral.
  ///
  /// In pt, this message translates to:
  /// **'Coral'**
  String get accentCoral;

  /// No description provided for @accentSky.
  ///
  /// In pt, this message translates to:
  /// **'Céu'**
  String get accentSky;

  /// No description provided for @accentMint.
  ///
  /// In pt, this message translates to:
  /// **'Menta'**
  String get accentMint;

  /// No description provided for @accentViolet.
  ///
  /// In pt, this message translates to:
  /// **'Violeta'**
  String get accentViolet;

  /// No description provided for @accentRose.
  ///
  /// In pt, this message translates to:
  /// **'Rosa'**
  String get accentRose;

  /// No description provided for @settingsFont.
  ///
  /// In pt, this message translates to:
  /// **'Fonte do texto'**
  String get settingsFont;

  /// No description provided for @settingsTextSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get settingsTextSize;

  /// No description provided for @sizeSmall.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get sizeLarge;

  /// No description provided for @sizeExtraLarge.
  ///
  /// In pt, this message translates to:
  /// **'Muito grande'**
  String get sizeExtraLarge;

  /// No description provided for @settingsPreview.
  ///
  /// In pt, this message translates to:
  /// **'Assim fica o texto do jogo.'**
  String get settingsPreview;

  /// No description provided for @settingsSound.
  ///
  /// In pt, this message translates to:
  /// **'Som'**
  String get settingsSound;

  /// No description provided for @soundTurnOn.
  ///
  /// In pt, this message translates to:
  /// **'Ligar o som'**
  String get soundTurnOn;

  /// No description provided for @soundTurnOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligar o som'**
  String get soundTurnOff;

  /// No description provided for @musicTurnOn.
  ///
  /// In pt, this message translates to:
  /// **'Ligar a música'**
  String get musicTurnOn;

  /// No description provided for @musicTurnOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligar a música'**
  String get musicTurnOff;

  /// No description provided for @music.
  ///
  /// In pt, this message translates to:
  /// **'Música'**
  String get music;

  /// No description provided for @musicHint.
  ///
  /// In pt, this message translates to:
  /// **'Trilha original, tocada pelo próprio jogo. Começa desligada.'**
  String get musicHint;

  /// No description provided for @themeToLight.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para o modo claro'**
  String get themeToLight;

  /// No description provided for @themeToDark.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para o modo escuro'**
  String get themeToDark;

  /// No description provided for @soundEffects.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos sonoros'**
  String get soundEffects;

  /// No description provided for @soundEffectsHint.
  ///
  /// In pt, this message translates to:
  /// **'Sons de acerto, erro, peças e pular. Começa desligado.'**
  String get soundEffectsHint;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In pt, this message translates to:
  /// **'Conectado como {email}'**
  String settingsSignedInAs(String email);

  /// No description provided for @themeTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Trocar tema (atual: {name})'**
  String themeTooltip(String name);

  /// No description provided for @themeFelt.
  ///
  /// In pt, this message translates to:
  /// **'Feltro'**
  String get themeFelt;

  /// No description provided for @themeCosmic.
  ///
  /// In pt, this message translates to:
  /// **'Cósmico'**
  String get themeCosmic;

  /// No description provided for @themeMinimal.
  ///
  /// In pt, this message translates to:
  /// **'Minimalista'**
  String get themeMinimal;

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

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

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
