import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/game_palette.dart';
import '../l10n/gen/app_localizations.dart';

/// Regras do jogo, abertas pelo botão de Ajuda da navbar.
Future<void> showHelpDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final p = GamePalette.of(context);
      final text = Theme.of(context).textTheme;
      final rules = [
        l10n.helpRuleGoal,
        l10n.helpRuleDrag,
        l10n.helpRuleEquals,
        l10n.helpRuleNoJoin,
        l10n.helpRuleLevels,
        l10n.helpRuleSolved,
        l10n.helpRuleScore,
      ];
      return AlertDialog(
        backgroundColor: p.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.border),
        ),
        title: Text(l10n.helpTitle, style: GameType.display(32, p.text)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final rule in rules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 10),
                          child: Container(width: 6, height: 6, color: p.gold),
                        ),
                        Expanded(child: Text(rule, style: text.bodyMedium!.copyWith(color: p.text, height: 1.4))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.helpClose, style: TextStyle(color: p.gold, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );
}
