import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/game_palette.dart';
import '../../../core/ui/game_controls.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../state/game_controller.dart';
import 'game_texts.dart';

/// Aviso de acerto: fica na tela até o jogador pedir o próximo número, para
/// ninguém ficar sem saber se acertou. A expressão continua montada atrás.
Future<void> showSolvedDialog(BuildContext context, {required SolvedInfo solved, required int points}) {
  return showDialog<void>(
    context: context,
    // Fundo claro: os palhaços (ou o efeito de acerto) continuam visíveis.
    barrierColor: Colors.black26,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final p = GamePalette.of(context);
      final text = Theme.of(context).textTheme;
      return AlertDialog(
        backgroundColor: p.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.gold, width: 2),
        ),
        icon: Icon(Icons.check_circle_rounded, color: p.gold, size: 48),
        title: Text(l10n.solvedDialogTitle.toUpperCase(), style: GameType.display(40, p.gold)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  solved.latex,
                  textStyle: TextStyle(color: p.text, fontSize: 24),
                  onErrorFallback: (_) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.verdictCorrect(l10n.formatValue(solved.value)),
                textAlign: TextAlign.center,
                style: text.bodyLarge!.copyWith(color: p.text),
              ),
              const SizedBox(height: 8),
              Text(l10n.pointsGained(points), style: GameType.display(26, p.gold)),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          GameButton(
            label: l10n.gameNext,
            icon: Icons.arrow_forward_rounded,
            kind: GameButtonKind.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
