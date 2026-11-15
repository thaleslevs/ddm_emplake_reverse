import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/game_palette.dart';
import '../../core/ui/felt_background.dart';
import '../../core/ui/game_controls.dart';
import '../../core/ui/language_selector.dart';
import '../../core/ui/corner_buttons.dart';
import '../../l10n/gen/app_localizations.dart';

/// Integrantes do grupo, mostrados na tela de login.
const teamMembers = ['Caio Monteiro Arraes', 'Thales Leonardo Euler Vieira de Sousa'];

/// Login com o `firebase_ui_auth` (e-mail/senha e, se configurado, Google),
/// com o título do jogo, os nomes do grupo e o seletor de idioma.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = GamePalette.of(context);
    final title = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GameTitle(l10n.appTitle),
    );

    return FeltBackground(
      child: Stack(
        children: [
          Theme(
            // O fundo do jogo aparece por trás da tela do firebase_ui.
            data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
            child: SignInScreen(
              providers: FirebaseUIAuth.providersFor(FirebaseAuth.instance.app),
              headerMaxExtent: 180,
              headerBuilder: (context, constraints, shrinkOffset) => Center(child: title),
              sideBuilder: (context, constraints) => Center(child: title),
              subtitleBuilder: (context, action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  action == AuthAction.signIn ? l10n.loginSubtitle : l10n.registerSubtitle,
                  style: theme.textTheme.bodyMedium!.copyWith(color: p.textMuted),
                ),
              ),
              footerBuilder: (context, action) => const _TeamFooter(),
            ),
          ),
          const Positioned(
            top: 8,
            left: 8,
            child: SafeArea(child: ThemeModeToggleButton()),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [LanguageSelector(), SizedBox(width: 8), AudioButtons()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamFooter extends StatelessWidget {
  const _TeamFooter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = GamePalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Text(l10n.loginTeam, style: text.labelMedium!.copyWith(color: p.textMuted)),
          const SizedBox(height: 4),
          for (final name in teamMembers)
            Text(
              name,
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(color: p.text, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}
