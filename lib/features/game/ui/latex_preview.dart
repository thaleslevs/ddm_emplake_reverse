import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexPreview extends StatelessWidget {
  const LatexPreview({super.key, required this.latex, required this.emptyText});

  final String latex;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall!.copyWith(color: theme.colorScheme.onSurface);

    return RepaintBoundary(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Center(
            child: latex.isEmpty
                ? Text(emptyText, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      latex,
                      mathStyle: MathStyle.display,
                      textStyle: style,
                      onErrorFallback: (_) => Text(latex, style: style),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
