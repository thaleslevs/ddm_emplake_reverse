import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/pixel_clown.dart';
import '../game/state/solved_store.dart';
import 'shop_catalog.dart';

/// O que o jogador comprou, gastou e está usando. Fica em `users/{uid}`.
@immutable
class Account {
  const Account({
    this.spent = 0,
    this.owned = const {},
    this.skinId = 'classic',
    this.effect = WinEffect.clowns,
    this.nickname = '',
  });

  /// Pontos gastos na loja. O saldo é o total ganho menos isso.
  final int spent;

  /// Ids dos itens comprados (os gratuitos não precisam estar aqui).
  final Set<String> owned;
  final String skinId;
  final WinEffect effect;

  /// Nome que aparece no ranking.
  final String nickname;

  bool owns(ShopItem item) => item.isFree || owned.contains(item.id);

  bool isEquipped(ShopItem item) =>
      item.kind == ShopKind.skin ? item.key == skinId : item.key == effect.name;

  Account copyWith({int? spent, Set<String>? owned, String? skinId, WinEffect? effect, String? nickname}) => Account(
    spent: spent ?? this.spent,
    owned: owned ?? this.owned,
    skinId: skinId ?? this.skinId,
    effect: effect ?? this.effect,
    nickname: nickname ?? this.nickname,
  );
}

final accountProvider = NotifierProvider<AccountStore, Account>(AccountStore.new);

class AccountStore extends Notifier<Account> {
  @override
  Account build() => const Account();

  void seed(Account account) => state = account;

  void bought(ShopItem item) =>
      state = state.copyWith(spent: state.spent + item.price, owned: {...state.owned, item.id});

  void equipped(ShopItem item) => state = item.kind == ShopKind.skin
      ? state.copyWith(skinId: item.key)
      : state.copyWith(effect: WinEffect.values.byName(item.key));

  void renamed(String nickname) => state = state.copyWith(nickname: nickname);
}

/// Pontos disponíveis para gastar na loja.
final balanceProvider = Provider<int>((ref) {
  final earned = ref.watch(scoreProvider);
  final int spent = ref.watch(accountProvider.select((a) => a.spent));
  final int left = earned - spent;
  return left < 0 ? 0 : left;
});

final equippedSkinProvider = Provider<ClownSkin>((ref) => ClownSkins.byId(ref.watch(accountProvider).skinId));

final equippedEffectProvider = Provider<WinEffect>((ref) => ref.watch(accountProvider).effect);
