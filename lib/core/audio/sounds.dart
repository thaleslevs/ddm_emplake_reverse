import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import 'game_sound.dart';
import 'sound_player.dart';

/// Toca efeitos sonoros só se o jogador ligou o som, no volume escolhido.
final soundsProvider = Provider<Sounds>(Sounds.new);

class Sounds {
  Sounds(this._ref);

  final Ref _ref;
  final _player = SoundPlayer();

  void play(GameSound sound) {
    final settings = _ref.read(settingsProvider);
    if (settings.soundEnabled) _player.play(sound, volume: settings.soundVolume);
  }

  /// Toca mesmo com o som desligado (amostra ao ligar ou ao ajustar o volume).
  void preview(GameSound sound) => _player.play(sound, volume: _ref.read(settingsProvider).soundVolume);
}
