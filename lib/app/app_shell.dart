import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/game_palette.dart';
import '../core/ui/felt_background.dart';
import '../core/ui/corner_buttons.dart';
import '../l10n/gen/app_localizations.dart';
import 'help_dialog.dart';

/// Moldura das páginas depois do login: fundo animado único e a navbar curva
/// (Jogar, Histórico, Ajuda, Configurações).
///
/// A Ajuda não é uma aba: abre um diálogo e a navbar fica onde estava.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Altura da navbar; as páginas reservam esse espaço embaixo.
  static const navBarHeight = 64.0;

  static const _helpSlot = 2;

  /// Posição na navbar de cada ramo do shell (a Ajuda ocupa o slot 2).
  static int _slotOf(int branch) => branch < _helpSlot ? branch : branch + 1;
  static int _branchOf(int slot) => slot < _helpSlot ? slot : slot - 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final current = _slotOf(shell.currentIndex);
    final items = [
      (Icons.grid_view_rounded, l10n.navPlay),
      (Icons.history_rounded, l10n.navHistory),
      (Icons.help_outline_rounded, l10n.navHelp),
      (Icons.settings_rounded, l10n.navSettings),
    ];

    return FeltBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // O conteúdo passa por baixo da curva da navbar.
        extendBody: true,
        body: Stack(
          children: [
            shell,
            // Visíveis em todas as abas: tema à esquerda, música e som à direita.
            const Positioned(
              top: 8,
              left: 8,
              child: SafeArea(child: ThemeModeToggleButton()),
            ),
            const Positioned(
              top: 8,
              right: 8,
              child: SafeArea(child: AudioButtons()),
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: current,
          height: navBarHeight,
          color: p.panel,
          buttonBackgroundColor: p.gold,
          backgroundColor: Colors.transparent,
          animationDuration: const Duration(milliseconds: 350),
          items: [
            for (var i = 0; i < items.length; i++)
              Tooltip(
                message: items[i].$2,
                child: Icon(items[i].$1, size: 26, color: i == current ? p.ink : p.text, semanticLabel: items[i].$2),
              ),
          ],
          letIndexChange: (slot) {
            if (slot == _helpSlot) {
              showHelpDialog(context);
              return false;
            }
            return true;
          },
          onTap: (slot) {
            final branch = _branchOf(slot);
            // Tocar na aba atual volta ao começo dela.
            shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
          },
        ),
      ),
    );
  }
}
