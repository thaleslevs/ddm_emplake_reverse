import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/game_palette.dart';

/// Moldura das páginas simples do shell (Histórico, Configurações): título na
/// fonte pixel, largura máxima e espaço embaixo para a navbar.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  /// Espaço reservado para a navbar curva, que fica por cima do conteúdo.
  static const bottomInset = 96.0;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final narrow = MediaQuery.sizeOf(context).width < 480;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, narrow ? 24 : 40, 16, bottomInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GameType.display(narrow ? 40 : 56, p.text),
                  ),
                  SizedBox(height: narrow ? 20 : 32),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painel com cantos e borda no estilo do jogo.
class GamePanel extends StatelessWidget {
  const GamePanel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}
