import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final Widget? content = switch ((verdict, solved)) {
      (_, final SolvedInfo s) => _Card(
        key: ValueKey('solved-${s.number}'),
        color: scheme.tertiaryContainer,
        onColor: scheme.onTertiaryContainer,
        icon: Icons.check_circle_rounded,
        title: l10n.solvedTitle,
        message: l10n.verdictCorrect(l10n.formatValue(s.value)),
        extra: Math.tex(
          s.latex,
          textStyle: text.titleMedium!.copyWith(color: scheme.onTertiaryContainer),
          onErrorFallback: (_) => const SizedBox.shrink(),
        ),
      ),
      (Incorrect(:final left, :final right), _) => _Card(
        key: ValueKey('incorrect-${identityHashCode(verdict)}'),
        color: scheme.secondaryContainer,
        onColor: scheme.onSecondaryContainer,
        icon: Icons.balance_rounded,
        message: l10n.verdictIncorrect(l10n.formatValue(left), l10n.formatValue(right)),
      ),
      (Invalid(:final error), _) => _Card(
        key: ValueKey('invalid-${identityHashCode(verdict)}'),
        color: scheme.errorContainer,
        onColor: scheme.onErrorContainer,
        icon: Icons.error_outline_rounded,
        message: l10n.errorMessage(error),
      ),
      _ => null,
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -0.15), end: Offset.zero).animate(animation),
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
    required this.color,
    required this.onColor,
    required this.icon,
    required this.message,
    this.title,
    this.extra,
  });

  final Color color;
  final Color onColor;
  final IconData icon;
  final String message;
  final String? title;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: text.titleMedium!.copyWith(color: onColor, fontWeight: FontWeight.w700),
                  ),
                Text(message, style: text.bodyMedium!.copyWith(color: onColor)),
                if (extra != null) ...[
                  const SizedBox(height: 6),
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: extra),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
