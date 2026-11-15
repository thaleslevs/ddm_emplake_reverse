import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/game_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../state/solved_store.dart';

/// Pontuação do jogador; dá um pulinho quando sobe.
class ScoreBadge extends ConsumerWidget {
  const ScoreBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final score = ref.watch(scoreProvider);
    return Semantics(
      label: l10n.scoreLabel(score),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 4, 12, 4),
          decoration: BoxDecoration(
            color: p.panel.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 18, color: p.gold),
              const SizedBox(width: 6),
              Text(l10n.scoreTitle.toUpperCase(), style: GameType.display(18, p.textMuted)),
              const SizedBox(width: 8),
              TweenAnimationBuilder<double>(
                key: ValueKey(score),
                tween: Tween(begin: 1.35, end: 1),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Text('$score', style: GameType.display(22, p.gold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
