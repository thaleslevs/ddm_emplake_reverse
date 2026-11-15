import '../../core/ui/pixel_clown.dart';

/// Efeito que aparece na tela quando o jogador acerta.
enum WinEffect { clowns, confetti, stars, coins, fireworks }

enum ShopKind { skin, effect }

/// Um item da loja. O [id] é o que fica salvo em `owned` no Firestore.
class ShopItem {
  const ShopItem._(this.id, this.kind, this.key, this.price);

  final String id;
  final ShopKind kind;

  /// Id da skin ou nome do efeito.
  final String key;
  final int price;

  bool get isFree => price == 0;
}

abstract final class ShopCatalog {
  static const _skinPrices = {
    'classic': 0,
    'wizard': 15,
    'robot': 20,
    'pirate': 20,
    'ninja': 25,
    'astronaut': 30,
    'skeleton': 35,
  };

  static const _effectPrices = {
    WinEffect.clowns: 0,
    WinEffect.confetti: 10,
    WinEffect.stars: 15,
    WinEffect.coins: 20,
    WinEffect.fireworks: 30,
  };

  static final skins = [
    for (final skin in ClownSkins.all) ShopItem._('skin.${skin.id}', ShopKind.skin, skin.id, _skinPrices[skin.id]!),
  ];

  static final effects = [
    for (final effect in WinEffect.values)
      ShopItem._('effect.${effect.name}', ShopKind.effect, effect.name, _effectPrices[effect]!),
  ];

  static ShopItem skin(String skinId) => skins.firstWhere((i) => i.key == skinId, orElse: () => skins.first);
  static ShopItem effect(WinEffect effect) => effects.firstWhere((i) => i.key == effect.name);
}
