import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/locale_controller.dart';
import '../theme/game_palette.dart';

/// Tamanho do texto da interface (as peças do jogo têm tamanho próprio).
enum TextSizeOption {
  small(0.9),
  medium(1),
  large(1.15),
  extraLarge(1.3);

  const TextSizeOption(this.scale);
  final double scale;
}

/// Cor semente: vira o acento do jogo (aba ativa, botões, navbar, ornamentos)
/// e gera o esquema de cores dos componentes. `theme` usa o acento do tema.
enum AccentOption {
  theme(null),
  coral(Color(0xFFEF6F5E)),
  sky(Color(0xFF3F9BF0)),
  mint(Color(0xFF2FBF8F)),
  violet(Color(0xFF8E6CEB)),
  rose(Color(0xFFE5609E));

  const AccentOption(this.color);
  final Color? color;
}

/// Famílias do Google Fonts oferecidas para o texto da interface. O título e
/// as peças continuam na fonte pixel. Roboto e Garamond são os exemplos do
/// enunciado; a Helvetica não está no Google Fonts, e a Inter faz o papel dela.
const fontFamilies = ['Inter', 'Roboto', 'EB Garamond', 'Nunito', 'Atkinson Hyperlegible', 'Space Grotesk'];

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.variant = ThemeVariant.felt,
    this.accent = AccentOption.theme,
    this.fontFamily = 'Inter',
    this.textSize = TextSizeOption.medium,
    this.soundEnabled = false,
    this.musicEnabled = false,
  });

  /// Começa seguindo o tema do dispositivo.
  final ThemeMode themeMode;
  final ThemeVariant variant;
  final AccentOption accent;
  final String fontFamily;
  final TextSizeOption textSize;

  /// Efeitos sonoros; desligados por padrão.
  final bool soundEnabled;

  /// Música de fundo, separada dos efeitos; desligada por padrão.
  final bool musicEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    ThemeVariant? variant,
    AccentOption? accent,
    String? fontFamily,
    TextSizeOption? textSize,
    bool? soundEnabled,
    bool? musicEnabled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    variant: variant ?? this.variant,
    accent: accent ?? this.accent,
    fontFamily: fontFamily ?? this.fontFamily,
    textSize: textSize ?? this.textSize,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
  );
}

/// Configurações de aparência, salvas no `shared_preferences`.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _mode = 'settings.themeMode';
  static const _variant = 'settings.variant';
  static const _accent = 'settings.accent';
  static const _font = 'settings.fontFamily';
  static const _size = 'settings.textSize';
  static const _sound = 'settings.sound';
  static const _music = 'settings.music';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    T pick<T extends Enum>(List<T> values, String key, T fallback) =>
        values.asNameMap()[prefs.getString(key)] ?? fallback;
    final font = prefs.getString(_font);
    return AppSettings(
      themeMode: pick(ThemeMode.values, _mode, ThemeMode.system),
      variant: pick(ThemeVariant.values, _variant, ThemeVariant.felt),
      accent: pick(AccentOption.values, _accent, AccentOption.theme),
      fontFamily: fontFamilies.contains(font) ? font! : 'Inter',
      textSize: pick(TextSizeOption.values, _size, TextSizeOption.medium),
      soundEnabled: prefs.getBool(_sound) ?? false,
      musicEnabled: prefs.getBool(_music) ?? false,
    );
  }

  void _save(String key, String value) => ref.read(sharedPreferencesProvider).setString(key, value);

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save(_mode, mode.name);
  }

  void setVariant(ThemeVariant variant) {
    state = state.copyWith(variant: variant);
    _save(_variant, variant.name);
  }

  void setAccent(AccentOption accent) {
    state = state.copyWith(accent: accent);
    _save(_accent, accent.name);
  }

  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
    _save(_font, family);
  }

  void setTextSize(TextSizeOption size) {
    state = state.copyWith(textSize: size);
    _save(_size, size.name);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    ref.read(sharedPreferencesProvider).setBool(_sound, enabled);
  }

  void setMusicEnabled(bool enabled) {
    state = state.copyWith(musicEnabled: enabled);
    ref.read(sharedPreferencesProvider).setBool(_music, enabled);
  }

  /// Alterna entre claro e escuro a partir do que está na tela agora (se o
  /// modo for "Sistema", passa a ser o oposto do sistema).
  void toggleBrightness(Brightness current) =>
      setThemeMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
}
