import 'package:flutter/material.dart';

import '../domain/token.dart';

class PieceTile extends StatelessWidget {
  const PieceTile({
    super.key,
    required this.kind,
    this.digit,
    this.size = 52,
    this.highlightError = false,
    this.lifted = false,
  });

  final TokenKind kind;
  final int? digit;
  final double size;
  final bool highlightError;

  final bool lifted;

  bool get _isDigit => kind == TokenKind.digit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (kind) {
      TokenKind.digit => scheme.surfaceContainerHighest,
      TokenKind.equals => scheme.tertiaryContainer,
      _ => scheme.primaryContainer,
    };
    final foreground = switch (kind) {
      TokenKind.digit => scheme.onSurface,
      TokenKind.equals => scheme.onTertiaryContainer,
      _ => scheme.onPrimaryContainer,
    };
    final label = _isDigit ? '$digit' : kind.symbol;
    final fontScale = label.length > 1 ? 0.36 : (_isDigit ? 0.56 : 0.48);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: _isDigit ? size * 0.8 : size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: highlightError ? scheme.error : Colors.transparent, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: lifted ? 0.30 : 0.12),
            blurRadius: lifted ? 14 : 3,
            offset: Offset(0, lifted ? 6 : 1.5),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: foreground,
          fontSize: size * fontScale,
          fontWeight: _isDigit ? FontWeight.w700 : FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
