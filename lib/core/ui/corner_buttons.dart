import 'dart:async';

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
    return _VolumeHover(
      channel: _Channel.sound,
      child: _CornerButton(
        active: on,
        icon: on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        label: on ? l10n.soundTurnOff : l10n.soundTurnOn,
        showTooltip: false,
        onPressed: () {
          ref.read(settingsProvider.notifier).setSoundEnabled(!on);
          if (!on) ref.read(soundsProvider).preview(GameSound.correct);
        },
      ),
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
    return _VolumeHover(
      channel: _Channel.music,
      child: _CornerButton(
        active: on,
        icon: on ? Icons.music_note_rounded : Icons.music_off_rounded,
        label: on ? l10n.musicTurnOff : l10n.musicTurnOn,
        showTooltip: false,
        onPressed: () => ref.read(settingsProvider.notifier).setMusicEnabled(!on),
      ),
    );
  }
}

enum _Channel { music, sound }

/// Barra de volume que aparece embaixo do botão: ao passar o mouse (desktop)
/// ou com um toque longo (celular). Fecha ao tirar o mouse ou tocar fora.
///
/// É o mesmo volume das Configurações. Mexer na barra com o canal desligado
/// já liga o canal.
class _VolumeHover extends ConsumerStatefulWidget {
  const _VolumeHover({required this.channel, required this.child});

  final _Channel channel;
  final Widget child;

  @override
  ConsumerState<_VolumeHover> createState() => _VolumeHoverState();
}

class _VolumeHoverState extends ConsumerState<_VolumeHover> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _group = Object();
  Timer? _hideTimer;
  bool _dragging = false;

  /// Quantas áreas (botão e barra) estão com o mouse em cima.
  int _hovered = 0;

  bool get _isMusic => widget.channel == _Channel.music;

  void _enter() {
    _hovered++;
    _show();
  }

  void _exit() {
    _hovered = _hovered > 0 ? _hovered - 1 : 0;
    if (_hovered == 0) _scheduleHide();
  }

  void _show() {
    _hideTimer?.cancel();
    if (!_portal.isShowing) _portal.show();
  }

  /// Espera um pouco: dá tempo de o mouse ir do botão até a barra.
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (_dragging) return;
    _hideTimer = Timer(const Duration(milliseconds: 300), _hide);
  }

  void _hide() {
    _hideTimer?.cancel();
    _hovered = 0;
    if (_portal.isShowing) _portal.hide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _changed(double value) {
    final settings = ref.read(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    if (_isMusic) {
      controller.setMusicVolume(value);
      if (!settings.musicEnabled && value > 0) controller.setMusicEnabled(true);
    } else {
      controller.setSoundVolume(value);
      if (!settings.soundEnabled && value > 0) controller.setSoundEnabled(true);
    }
  }

  void _changeEnded(double value) {
    _dragging = false;
    if (!_isMusic) ref.read(soundsProvider).preview(GameSound.place);
    // Soltou fora da barra (ou no celular): fecha.
    if (_hovered == 0) _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            // Alinha pela direita: os botões ficam colados na borda da tela.
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 6),
            child: TapRegion(
              groupId: _group,
              onTapOutside: (_) => _hide(),
              child: MouseRegion(
                onEnter: (_) => _enter(),
                onExit: (_) => _exit(),
                child: _panel(context),
              ),
            ),
          ),
        ),
        child: TapRegion(
          groupId: _group,
          child: MouseRegion(
            onEnter: (_) => _enter(),
            onExit: (_) => _exit(),
            child: GestureDetector(onLongPress: _show, child: widget.child),
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final (volume, on) = ref.watch(
      settingsProvider.select(
        (s) => _isMusic ? (s.musicVolume, s.musicEnabled) : (s.soundVolume, s.soundEnabled),
      ),
    );
    final label = _isMusic ? l10n.musicVolume : l10n.soundVolume;
    final percent = '${(volume * 100).round()}%';
    final color = on ? p.gold : p.textMuted;

    return Material(
      color: p.panel,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: on ? p.gold.withValues(alpha: 0.7) : p.border),
      ),
      child: SizedBox(
        width: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(percent, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              RotatedBox(
                quarterTurns: 3,
                child: SizedBox(
                  width: 130,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color,
                      thumbColor: color,
                      inactiveTrackColor: p.border,
                      overlayColor: color.withValues(alpha: 0.15),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: volume,
                      divisions: 20,
                      semanticFormatterCallback: (_) => '$label: $percent',
                      onChangeStart: (_) => _dragging = true,
                      onChanged: _changed,
                      onChangeEnd: _changeEnded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                _isMusic ? Icons.music_note_rounded : Icons.volume_up_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
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
      label: dark ? l10n.themeToLight : l10n.themeToDark,
      onPressed: () => ref.read(settingsProvider.notifier).toggleBrightness(Theme.of(context).brightness),
    );
  }
}

class _CornerButton extends StatelessWidget {
  const _CornerButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.showTooltip = true,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Os botões de áudio mostram a barra de volume no lugar da dica.
  final bool showTooltip;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    // Material próprio: os botões também ficam fora de um Scaffold (no login).
    return Material(
      type: MaterialType.transparency,
      child: IconButton(
        tooltip: showTooltip ? label : null,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: p.panel.withValues(alpha: 0.85),
          side: BorderSide(color: active ? p.gold : p.border),
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            icon,
            key: ValueKey(icon),
            color: active ? p.gold : p.textMuted,
            semanticLabel: showTooltip ? null : label,
          ),
        ),
      ),
    );
  }
}
