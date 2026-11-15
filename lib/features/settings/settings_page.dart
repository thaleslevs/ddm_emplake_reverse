import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' show FirebaseUIAuth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/audio/game_sound.dart';
import '../../core/audio/sounds.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/game_palette.dart';
import '../../core/ui/language_selector.dart';
import '../../core/ui/page_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import '../game/ui/game_texts.dart';

/// Configurações: aparência (sistema/claro/escuro), tema pronto, cor de
/// destaque, fonte, tamanho do texto, idioma e conta. Tudo fica salvo.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final email = FirebaseAuth.instance.currentUser?.email;

    return PageFrame(
      title: l10n.settingsTitle,
      children: [
        _Section(
          title: l10n.settingsMode,
          child: _ChoiceRow<ThemeMode>(
            selected: settings.themeMode,
            onSelected: controller.setThemeMode,
            options: [
              (ThemeMode.system, Icons.brightness_auto_rounded, l10n.modeSystem),
              (ThemeMode.light, Icons.light_mode_rounded, l10n.modeLight),
              (ThemeMode.dark, Icons.dark_mode_rounded, l10n.modeDark),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsTheme,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final variant in ThemeVariant.values)
                _ThemeChip(
                  label: l10n.themeName(variant),
                  // Amostra no claro ou escuro que está em uso agora.
                  palette: GamePalette.forVariant(variant, brightness: brightness),
                  selected: variant == settings.variant,
                  onTap: () => controller.setVariant(variant),
                ),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsAccent,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final accent in AccentOption.values)
                _AccentSwatch(
                  label: _accentName(l10n, accent),
                  color: accent.color ?? GamePalette.forVariant(settings.variant, brightness: brightness).gold,
                  selected: accent == settings.accent,
                  isThemeDefault: accent == AccentOption.theme,
                  onTap: () => controller.setAccent(accent),
                ),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsFont,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final family in fontFamilies)
                _Choice(
                  label: Text(family, style: GoogleFonts.getFont(family, color: p.text)),
                  selected: family == settings.fontFamily,
                  onSelected: () => controller.setFontFamily(family),
                ),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsTextSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChoiceRow<TextSizeOption>(
                selected: settings.textSize,
                onSelected: controller.setTextSize,
                options: [
                  for (final size in TextSizeOption.values) (size, null, _sizeName(l10n, size)),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.settingsPreview, style: text.bodyLarge!.copyWith(color: p.textMuted)),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsSound,
          child: Column(
            children: [
              _SwitchRow(
                title: l10n.music,
                hint: l10n.musicHint,
                value: settings.musicEnabled,
                onChanged: controller.setMusicEnabled,
              ),
              const SizedBox(height: 12),
              _SwitchRow(
                title: l10n.soundEffects,
                hint: l10n.soundEffectsHint,
                value: settings.soundEnabled,
                onChanged: (on) {
                  controller.setSoundEnabled(on);
                  // Amostra ao ligar, para o jogador ouvir o volume.
                  if (on) ref.read(soundsProvider).preview(GameSound.correct);
                },
              ),
            ],
          ),
        ),
        _Section(
          title: l10n.settingsLanguage,
          child: const Align(alignment: Alignment.centerLeft, child: LanguageSelector()),
        ),
        _Section(
          title: l10n.settingsAccount,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              if (email != null) Text(l10n.settingsSignedInAs(email), style: text.bodyMedium!.copyWith(color: p.textMuted)),
              OutlinedButton.icon(
                onPressed: () => FirebaseUIAuth.signOut(context: context),
                icon: Icon(Icons.logout_rounded, color: p.red),
                label: Text(l10n.signOut, style: TextStyle(color: p.red)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: p.red.withValues(alpha: 0.6))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _accentName(AppLocalizations l10n, AccentOption accent) => switch (accent) {
    AccentOption.theme => l10n.accentTheme,
    AccentOption.coral => l10n.accentCoral,
    AccentOption.sky => l10n.accentSky,
    AccentOption.mint => l10n.accentMint,
    AccentOption.violet => l10n.accentViolet,
    AccentOption.rose => l10n.accentRose,
  };

  static String _sizeName(AppLocalizations l10n, TextSizeOption size) => switch (size) {
    TextSizeOption.small => l10n.sizeSmall,
    TextSizeOption.medium => l10n.sizeMedium,
    TextSizeOption.large => l10n.sizeLarge,
    TextSizeOption.extraLarge => l10n.sizeExtraLarge,
  };
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.hint, required this.value, required this.onChanged});

  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.bodyLarge!.copyWith(color: p.text)),
              const SizedBox(height: 2),
              Text(hint, style: text.bodySmall!.copyWith(color: p.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, activeThumbColor: p.ink, activeTrackColor: p.gold, onChanged: onChanged),
      ],
    );
  }
}

/// Opções de escolha única em chips, que quebram de linha em tela estreita.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({required this.options, required this.selected, required this.onSelected});

  final List<(T, IconData?, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (value, icon, label) in options)
          _Choice(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: value == selected ? p.gold : p.textMuted),
                  const SizedBox(width: 6),
                ],
                Text(label),
              ],
            ),
            selected: value == selected,
            onSelected: () => onSelected(value),
          ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onSelected});

  final Widget label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return ChoiceChip(
      label: label,
      selected: selected,
      showCheckmark: false,
      labelStyle: TextStyle(color: p.text),
      backgroundColor: p.panelRaised,
      selectedColor: p.gold.withValues(alpha: 0.25),
      side: BorderSide(color: selected ? p.gold : p.border),
      onSelected: (_) => onSelected(),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GamePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: GameType.display(24, p.gold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Amostra de um tema pronto: as cores dele e o nome.
class _ThemeChip extends StatelessWidget {
  const _ThemeChip({required this.label, required this.palette, required this.selected, required this.onTap});

  final String label;
  final GamePalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? p.gold : palette.border, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in [palette.gold, palette.blue, palette.red])
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                ),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: palette.text)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bolinha de cor de destaque; a do tema tem um contorno tracejado de "auto".
class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.isThemeDefault,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool isThemeDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? p.text : Colors.transparent, width: 2),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: isThemeDefault
                  ? Icon(Icons.auto_awesome_rounded, size: 16, color: GamePalette.onColor(color))
                  : selected
                  ? Icon(Icons.check_rounded, size: 18, color: GamePalette.onColor(color))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
