import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/game_sound.dart';
import '../../core/audio/sounds.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/game_palette.dart';
import '../../core/ui/page_frame.dart';
import '../../core/ui/pixel_clown.dart';
import '../../l10n/gen/app_localizations.dart';
import '../game/state/solved_store.dart';
import '../game/ui/clown_burst.dart';
import 'account.dart';
import 'shop_actions.dart';
import 'shop_catalog.dart';

/// Aba Loja: troca pontos por skins dos palhaços e efeitos de acerto.
/// O saldo é o total ganho menos o que já foi gasto; gastar não muda o
/// ranking, que conta o total ganho.
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  WinEffect _preview = WinEffect.clowns;
  int _previews = 0;

  void _try(WinEffect effect) => setState(() {
    _preview = effect;
    _previews++;
  });

  Future<void> _buy(ShopItem item) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(shopActionsProvider).buy(item);
    if (result == BuyResult.bought) {
      ref.read(soundsProvider).play(GameSound.correct);
      if (item.kind == ShopKind.effect) _try(WinEffect.values.byName(item.key));
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          BuyResult.bought => l10n.shopBought,
          BuyResult.notEnoughPoints => l10n.shopNotEnough,
          BuyResult.alreadyOwned => l10n.shopBought,
          BuyResult.failed => l10n.shopBuyError,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    final balance = ref.watch(balanceProvider);
    final account = ref.watch(accountProvider);

    Widget action(ShopItem item) => _ItemAction(
      item: item,
      owned: account.owns(item),
      equipped: account.isEquipped(item),
      balance: balance,
      onBuy: () => _buy(item),
      onEquip: () => ref.read(shopActionsProvider).equip(item),
    );

    return Stack(
      children: [
        PageFrame(
          title: l10n.shopTitle,
          children: [
            GamePanel(
              child: Row(
                children: [
                  Icon(Icons.savings_rounded, color: p.gold, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.balanceLabel(balance), style: GameType.display(28, p.gold)),
                        Text(
                          l10n.earnedLabel(ref.watch(scoreProvider)),
                          style: text.bodyMedium!.copyWith(color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(l10n.shopSkins),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in ShopCatalog.skins)
                  _ItemCard(
                    selected: account.isEquipped(item),
                    preview: _SkinPreview(skin: ClownSkins.byId(item.key)),
                    name: _skinName(l10n, item.key),
                    action: action(item),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle(l10n.shopEffects),
            Text(l10n.shopEffectsHint, style: text.bodySmall!.copyWith(color: p.textMuted)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in ShopCatalog.effects)
                  _ItemCard(
                    selected: account.isEquipped(item),
                    preview: Icon(_effectIcon(item.key), size: 48, color: p.gold),
                    name: _effectName(l10n, item.key),
                    action: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        action(item),
                        TextButton.icon(
                          onPressed: () => _try(WinEffect.values.byName(item.key)),
                          icon: Icon(Icons.play_arrow_rounded, size: 18, color: p.textMuted),
                          label: Text(l10n.shopTry, style: TextStyle(color: p.textMuted)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned.fill(child: ClownBurst(mood: ClownMood.happy, trigger: _previews, effect: _preview)),
      ],
    );
  }

  static String _skinName(AppLocalizations l10n, String id) => switch (id) {
    'wizard' => l10n.skinWizard,
    'robot' => l10n.skinRobot,
    'pirate' => l10n.skinPirate,
    'ninja' => l10n.skinNinja,
    'astronaut' => l10n.skinAstronaut,
    'skeleton' => l10n.skinSkeleton,
    _ => l10n.skinClassic,
  };

  static String _effectName(AppLocalizations l10n, String id) => switch (WinEffect.values.byName(id)) {
    WinEffect.clowns => l10n.effectClowns,
    WinEffect.confetti => l10n.effectConfetti,
    WinEffect.stars => l10n.effectStars,
    WinEffect.coins => l10n.effectCoins,
    WinEffect.fireworks => l10n.effectFireworks,
  };

  static IconData _effectIcon(String id) => switch (WinEffect.values.byName(id)) {
    WinEffect.clowns => Icons.sentiment_very_satisfied_rounded,
    WinEffect.confetti => Icons.celebration_rounded,
    WinEffect.stars => Icons.auto_awesome_rounded,
    WinEffect.coins => Icons.monetization_on_rounded,
    WinEffect.fireworks => Icons.local_fire_department_rounded,
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title.toUpperCase(), style: GameType.display(26, GamePalette.of(context).gold)),
  );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.selected, required this.preview, required this.name, required this.action});

  final bool selected;
  final Widget preview;
  final String name;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? p.gold : p.border, width: selected ? 2 : 1),
      ),
      child: Column(
        children: [
          SizedBox(height: 76, child: Center(child: preview)),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: p.text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          action,
        ],
      ),
    );
  }
}

class _ItemAction extends StatelessWidget {
  const _ItemAction({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.balance,
    required this.onBuy,
    required this.onEquip,
  });

  final ShopItem item;
  final bool owned;
  final bool equipped;
  final int balance;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    if (equipped) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: p.gold),
          const SizedBox(width: 6),
          Text(l10n.shopEquipped, style: TextStyle(color: p.gold, fontWeight: FontWeight.w700)),
        ],
      );
    }
    if (owned) {
      return OutlinedButton(
        onPressed: onEquip,
        style: OutlinedButton.styleFrom(side: BorderSide(color: p.gold)),
        child: Text(l10n.shopEquip, style: TextStyle(color: p.gold)),
      );
    }
    final missing = item.price - balance;
    return FilledButton.icon(
      onPressed: missing > 0 ? null : onBuy,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.star_rounded, size: 16),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          missing > 0 ? l10n.shopMissing(missing) : l10n.shopBuy(item.price),
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}

/// Os dois palhaços do título com a skin, parados.
class _SkinPreview extends StatelessWidget {
  const _SkinPreview({required this.skin});

  final ClownSkin skin;

  @override
  Widget build(BuildContext context) {
    const unit = 3.2;
    final w = PixelClown.columns(ClownLook.neutral) * unit;
    final h = PixelClown.rows(ClownLook.neutral) * unit;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final colors in [skin.left, skin.right])
          SizedBox(
            width: w,
            height: h,
            child: CustomPaint(painter: _ClownPicturePainter(skin, colors)),
          ),
      ],
    );
  }
}

class _ClownPicturePainter extends CustomPainter {
  const _ClownPicturePainter(this.skin, this.colors);

  final ClownSkin skin;
  final ClownColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / PixelClown.columns(ClownLook.neutral);
    canvas
      ..scale(unit)
      ..drawPicture(PixelClown.picture(ClownLook.neutral, skin, colors));
  }

  @override
  bool shouldRepaint(_ClownPicturePainter old) => old.skin != skin || old.colors != colors;
}
