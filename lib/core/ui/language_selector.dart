import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/game_palette.dart';

/// Bandeiras para trocar o idioma; a do idioma atual fica destacada.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    final options = [
      ('pt', 'BR', l10n.languagePortuguese),
      ('en', 'US', l10n.languageEnglish),
    ];
    // Material próprio: o seletor também é usado fora de um Scaffold (por
    // cima da tela de login).
    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (code, country, label) in options)
            _FlagButton(
              country: country,
              label: label,
              selected: current == code,
              onTap: () => ref.read(localeProvider.notifier).select(Locale(code)),
            ),
        ],
      ),
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({required this.country, required this.label, required this.selected, required this.onTap});

  final String country;
  final String label;
  final bool selected;
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
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: selected ? p.gold : Colors.transparent, width: 2),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: selected ? 1 : 0.55,
              child: CountryFlag.fromCountryCode(
                country,
                theme: const ImageTheme(width: 32, height: 22, shape: RoundedRectangle(3)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
