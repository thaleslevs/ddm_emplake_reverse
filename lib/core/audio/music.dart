import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings.dart';
import 'music_player.dart';

/// Liga e desliga a música de fundo conforme a opção das configurações.
/// Precisa ser observado uma vez no topo do app para existir.
final musicProvider = Provider<Music>((ref) {
  final music = Music();
  ref
    ..listen(
      settingsProvider.select((s) => s.musicEnabled),
      (_, enabled) => enabled ? music.player.start() : music.player.stop(),
      fireImmediately: true,
    )
    ..onDispose(music.player.stop);
  return music;
});

class Music {
  final player = MusicPlayer();

  /// Retoma o áudio depois de um toque, se o navegador o travou (por
  /// exemplo, música ligada ao reabrir o app, antes de qualquer clique).
  void unlock() => player.unlock();
}
