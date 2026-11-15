import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/solved_repository.dart';
import 'game_screen.dart';

/// Aba Jogar: o jogo do jogador logado.
class PlayTab extends ConsumerWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(solvedRepositoryProvider);
    if (repository == null) return const SizedBox.shrink();
    // A chave recria a tela (e recarrega os resolvidos) ao trocar de conta.
    return GameScreen(key: ValueKey(repository.uid), repository: repository);
  }
}
