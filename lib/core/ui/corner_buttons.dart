import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../audio/game_sound.dart';
import '../audio/sounds.dart';
import '../settings/app_settings.dart';
import '../theme/game_palette.dart';

/// Canto superior direito: música e efeitos sonoros, cada um com seu botão.
class AudioButtons extends StatelessWidget {
  const AudioButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [MusicToggleButton(), SizedBox(width: 8), SoundToggleButton()],
    );
  }
}

/// Liga e desliga os efeitos sonoros (mesma opção das Configurações).
class SoundToggleButton extends ConsumerWidget {
  const SoundToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(settingsProvider.select((s) => s.soundEnabled));
    return _CornerButton(
      active: on,
      icon: on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
      tooltip: on ? l10n.soundTurnOff : l10n.soundTurnOn,
      onPressed: () {
        ref.read(settingsProvider.notifier).setSoundEnabled(!on);
        if (!on) ref.read(soundsProvider).preview(GameSound.correct);
      },
    );
  }
}

/// Liga e desliga a música de fundo (separada dos efeitos sonoros).
class MusicToggleButton extends ConsumerWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(settingsProvider.select((s) => s.musicEnabled));
    return _CornerButton(
      active: on,
      icon: on ? Icons.music_note_rounded : Icons.music_off_rounded,
      tooltip: on ? l10n.musicTurnOff : l10n.musicTurnOn,
      onPressed: () => ref.read(settingsProvider.notifier).setMusicEnabled(!on),
    );
  }
}

/// Canto superior esquerdo: alterna entre modo escuro e claro.
class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _CornerButton(
      active: false,
      // Mostra o modo para onde o botão leva.
      icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      tooltip: dark ? l10n.themeToLight : l10n.themeToDark,
      onPressed: () => ref.read(settingsProvider.notifier).toggleBrightness(Theme.of(context).brightness),
    );
  }
}

class _CornerButton extends StatelessWidget {
  const _CornerButton({required this.active, required this.icon, required this.tooltip, required this.onPressed});

  final bool active;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    // Material próprio: os botões também ficam fora de um Scaffold (no login).
    return Material(
      type: MaterialType.transparency,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: p.panel.withValues(alpha: 0.85),
          side: BorderSide(color: active ? p.gold : p.border),
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(icon, key: ValueKey(icon), color: active ? p.gold : p.textMuted),
        ),
      ),
    );
  }
}
