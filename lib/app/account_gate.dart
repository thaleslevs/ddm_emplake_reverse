import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../core/theme/game_palette.dart';
import '../core/ui/felt_background.dart';
import '../features/game/data/solved_repository.dart';
import '../features/game/domain/level.dart';
import '../features/game/state/solved_store.dart';
import '../features/ranking/leaderboard_repository.dart';
import '../features/shop/account.dart';
import '../features/shop/account_repository.dart';
import '../l10n/gen/app_localizations.dart';

/// Antes de mostrar as abas, carrega do Firestore (com [FutureBuilder] e o
/// indicador de progresso) os números resolvidos e a conta do jogador
/// (compras, itens em uso, apelido). Assim o primeiro sorteio já pula o que
/// foi resolvido e a loja, o ranking e as skins abrem prontos.
class AccountGate extends ConsumerWidget {
  const AccountGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solved = ref.watch(solvedRepositoryProvider);
    final account = ref.watch(accountRepositoryProvider);
    if (solved == null || account == null) return const _Loading();
    // A chave recarrega tudo ao trocar de conta.
    return _AccountLoader(key: ValueKey(solved.uid), solved: solved, account: account, child: child);
  }
}

class _AccountLoader extends ConsumerStatefulWidget {
  const _AccountLoader({super.key, required this.solved, required this.account, required this.child});

  final SolvedRepository solved;
  final AccountRepository account;
  final Widget child;

  @override
  ConsumerState<_AccountLoader> createState() => _AccountLoaderState();
}

class _AccountLoaderState extends ConsumerState<_AccountLoader> {
  /// `true` se carregou; `false` se falhou (o app abre mesmo assim).
  late final Future<bool> _loaded = _load();

  Future<bool> _load() async {
    try {
      final (solved, account) = await (widget.solved.loadAll(), widget.account.load()).wait;
      ref.read(solvedProvider.notifier).seed(solved);
      ref.read(accountProvider.notifier).seed(account);
      _syncInBackground(solved, account);
      return true;
    } catch (e) {
      debugPrint('Falha ao carregar a conta: $e');
      return false;
    }
  }

  /// Mantém a pontuação salva e o ranking em dia com os resolvidos.
  void _syncInBackground(Map<Level, Set<String>> solved, Account account) {
    void log(Object e) => debugPrint('Falha ao sincronizar: $e');
    widget.solved.syncScore(solved).catchError(log);
    ref.read(leaderboardRepositoryProvider)?.sync(points: scoreOf(solved), name: account.nickname).catchError(log);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loaded,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const _Loading();
        if (snapshot.data == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).solvedLoadError)),
            );
          });
        }
        return widget.child;
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
      body: FeltBackground(
        child: Center(
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
      ),
    );
  }
}
