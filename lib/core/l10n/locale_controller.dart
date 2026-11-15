import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preenchido em `main()` com a instância já carregada.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider precisa ser sobrescrito no ProviderScope'),
);

/// Idioma escolhido pelo jogador. `null` segue o idioma do dispositivo.
final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends Notifier<Locale?> {
  static const _key = 'locale';

  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  void select(Locale locale) {
    state = locale;
    ref.read(sharedPreferencesProvider).setString(_key, locale.languageCode);
  }
}
