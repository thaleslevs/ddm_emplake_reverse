import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/theme/game_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../data/solved_repository.dart';
import '../state/solved_store.dart';
import 'game_page.dart';

/// Carrega do Firestore os números já resolvidos (com [FutureBuilder] e o
/// indicador de progresso) e só então abre o jogo, para o primeiro sorteio já
/// pular o que foi resolvido.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.repository});

  final SolvedRepository repository;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  /// `true` se carregou; `false` se falhou (o jogo abre mesmo assim).
  late final Future<bool> _loaded = _load();

  Future<bool> _load() async {
    try {
      final solved = await widget.repository.loadAll();
      ref.read(solvedProvider.notifier).seed(solved);
      return true;
    } catch (e) {
      debugPrint('Falha ao carregar resolvidos: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loaded,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const _Loading();
        return GamePage(loadFailed: snapshot.data == false);
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.staggeredDotsWave(color: p.gold, size: 56),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).loadingSolved,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
