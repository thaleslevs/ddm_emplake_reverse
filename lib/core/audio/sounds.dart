import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import 'game_sound.dart';
import 'sound_player.dart';

/// Toca efeitos sonoros só se o jogador ligou o som nas configurações.
final soundsProvider = Provider<Sounds>(Sounds.new);

class Sounds {
  Sounds(this._ref);

  final Ref _ref;
  final _player = SoundPlayer();

  void play(GameSound sound) {
    if (_ref.read(settingsProvider).soundEnabled) _player.play(sound);
  }

  /// Toca mesmo com o som desligado (amostra ao ligar a opção).
  void preview(GameSound sound) => _player.play(sound);
}
