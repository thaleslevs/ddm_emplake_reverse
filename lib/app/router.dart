import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/locale_controller.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_page.dart';
import '../features/game/state/game_controller.dart';
import '../features/game/state/solved_store.dart';
import '../features/game/ui/play_tab.dart';
import '../features/ranking/scores_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shop/account.dart';
import '../features/shop/shop_page.dart';
import 'account_gate.dart';
import 'app_shell.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const play = '/play';
  static const scores = '/scores';
  static const shop = '/shop';
  static const settings = '/settings';

  /// Abas da navbar, na ordem dos ramos do shell.
  static const tabs = [play, scores, shop, settings];
}

const _lastRouteKey = 'lastRoute';

/// Rotas do app:
/// - `/login` fora do shell, só para quem não está logado;
/// - `/play`, `/history` e `/settings` dentro do shell com a navbar.
///
/// A última aba aberta fica salva e o app reabre nela.
final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);

  // Faz o go_router reavaliar o redirect quando o login muda.
  final authChanged = ValueNotifier<int>(0);
  ref
    ..listen(authUserProvider, (previous, next) {
      // Ao trocar de conta, descarta o estado do jogador anterior.
      if (previous?.value?.uid != next.value?.uid) {
        ref
          ..invalidate(gameControllerProvider)
          ..invalidate(solvedProvider)
          ..invalidate(accountProvider);
      }
      authChanged.value++;
    })
    ..onDispose(authChanged.dispose);

  String lastTab() {
    final saved = prefs.getString(_lastRouteKey);
    return AppRoutes.tabs.contains(saved) ? saved! : AppRoutes.play;
  }

  final router = GoRouter(
    initialLocation: lastTab(),
    refreshListenable: authChanged,
    redirect: (context, state) {
      // `main()` espera o Firebase restaurar a sessão antes de abrir o app,
      // então o usuário atual já é confiável aqui.
      final signedIn = FirebaseAuth.instance.currentUser != null;
      final atLogin = state.matchedLocation == AppRoutes.login;
      if (!signedIn) return atLogin ? null : AppRoutes.login;
      if (atLogin) return lastTab();
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AccountGate(child: AppShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.play, builder: (context, state) => const PlayTab())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.scores, builder: (context, state) => const ScoresPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.shop, builder: (context, state) => const ShopPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsPage())],
          ),
        ],
      ),
    ],
  );

  void rememberTab() {
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (AppRoutes.tabs.contains(path)) prefs.setString(_lastRouteKey, path);
  }

  router.routerDelegate.addListener(rememberTab);
  ref.onDispose(() {
    router.routerDelegate.removeListener(rememberTab);
    router.dispose();
  });
  return router;
});
