import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/audio/music.dart';
import 'core/config.dart';
import 'core/l10n/locale_controller.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/gen/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    if (googleWebClientId.isNotEmpty) GoogleProvider(clientId: googleWebClientId),
  ]);
  // Espera o Firebase restaurar a sessão salva, para o router já saber se
  // abre o login ou a última aba (sem piscar a tela de login).
  await FirebaseAuth.instance.authStateChanges().first;
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EmplakeApp(),
    ),
  );
}

class EmplakeApp extends ConsumerWidget {
  const EmplakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final music = ref.watch(musicProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildGameTheme(settings, Brightness.light),
      darkTheme: buildGameTheme(settings, Brightness.dark),
      themeMode: settings.themeMode,
      // Tamanho do texto escolhido nas configurações, por cima do do sistema.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return Listener(
          // Qualquer toque libera o áudio que o navegador tenha travado.
          onPointerDown: (_) => music.unlock(),
          behavior: HitTestBehavior.translucent,
          child: MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(mq.textScaler.scale(14) / 14 * settings.textSize.scale),
            ),
            child: child!,
          ),
        );
      },
      locale: ref.watch(localeProvider),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        // Traduz as telas do firebase_ui_auth (login, cadastro, erros).
        FirebaseUILocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}