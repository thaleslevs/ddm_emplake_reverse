import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/game_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/judge.dart';
import '../state/game_controller.dart';
import 'game_texts.dart';

class VerdictBanner extends StatelessWidget {
  const VerdictBanner({super.key, required this.verdict, required this.solved});

  final Verdict? verdict;
  final SolvedInfo? solved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);

    final Widget? content = switch ((verdict, solved)) {
      (_, final SolvedInfo s) => _Card(
        key: ValueKey('solved-${s.number}'),
        accent: p.gold,
        icon: Icons.check_rounded,
        title: l10n.solvedTitle,
        message: l10n.verdictCorrect(l10n.formatValue(s.value)),
        extra: Math.tex(
          s.latex,
          textStyle: TextStyle(color: p.text, fontSize: 18),
          onErrorFallback: (_) => const SizedBox.shrink(),
        ),
      ),
      (Incorrect(:final left, :final right), _) => _Card(
        key: ValueKey('incorrect-${identityHashCode(verdict)}'),
        accent: p.blue,
        icon: Icons.balance_rounded,
        message: l10n.verdictIncorrect(l10n.formatValue(left), l10n.formatValue(right)),
      ),
      (Invalid(:final error), _) => _Card(
        key: ValueKey('invalid-${identityHashCode(verdict)}'),
        accent: p.red,
        icon: Icons.close_rounded,
        message: l10n.errorMessage(error),
      ),
      _ => null,
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 140),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.08), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
        child: content ?? const SizedBox(key: ValueKey('none'), width: double.infinity),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    super.key,
    required this.accent,
    required this.icon,
    required this.message,
    this.title,
    this.extra,
  });

  final Color accent;
  final IconData icon;
  final String message;
  final String? title;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: p.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border, width: 1.5),
        boxShadow: [BoxShadow(color: p.backgroundDeep, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: accent, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(title!.toUpperCase(), style: GameType.display(26, accent)),
                            const SizedBox(height: 4),
                          ],
                          Text(message, style: text.bodyMedium!.copyWith(color: p.text)),
                          if (extra != null) ...[
                            const SizedBox(height: 8),
                            SingleChildScrollView(scrollDirection: Axis.horizontal, child: extra),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
