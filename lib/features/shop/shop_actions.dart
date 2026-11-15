import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/state/solved_store.dart';
import '../ranking/leaderboard_repository.dart';
import 'account.dart';
import 'account_repository.dart';
import 'shop_catalog.dart';

enum BuyResult { bought, alreadyOwned, notEnoughPoints, failed }

/// Comprar, usar e renomear: atualiza o estado na hora e grava no Firestore.
final shopActionsProvider = Provider<ShopActions>(ShopActions.new);

class ShopActions {
  ShopActions(this._ref);

  final Ref _ref;

  AccountRepository? get _repo => _ref.read(accountRepositoryProvider);

  /// Compra e já passa a usar o item.
  Future<BuyResult> buy(ShopItem item) async {
    final account = _ref.read(accountProvider);
    if (account.owns(item)) return BuyResult.alreadyOwned;
    if (_ref.read(balanceProvider) < item.price) return BuyResult.notEnoughPoints;
    final repo = _repo;
    if (repo == null) return BuyResult.failed;
    try {
      await repo.buy(item);
    } catch (_) {
      return BuyResult.failed;
    }
    _ref.read(accountProvider.notifier).bought(item);
    await equip(item);
    return BuyResult.bought;
  }

  Future<void> equip(ShopItem item) async {
    if (!_ref.read(accountProvider).owns(item)) return;
    _ref.read(accountProvider.notifier).equipped(item);
    await _repo?.equip(item);
  }

  /// Troca o apelido do ranking (1 a 20 caracteres).
  Future<void> rename(String nickname) async {
    final name = nickname.trim();
    if (name.isEmpty || name.length > 20) return;
    _ref.read(accountProvider.notifier).renamed(name);
    await _repo?.rename(name);
    await _ref.read(leaderboardRepositoryProvider)?.sync(points: _ref.read(scoreProvider), name: name);
  }
}
