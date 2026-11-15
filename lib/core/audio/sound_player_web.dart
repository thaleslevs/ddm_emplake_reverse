import 'package:web/web.dart' as web;

import 'game_sound.dart';

/// Toca os efeitos com osciladores da Web Audio API, sem arquivos de áudio.
class SoundPlayer {
  web.AudioContext? _context;

  /// Criado só no primeiro som: os navegadores só liberam áudio depois de um
  /// toque ou clique, e todo som do jogo vem de um.
  web.AudioContext get _ctx => _context ??= web.AudioContext();

  void play(GameSound sound) {
    try {
      final ctx = _ctx;
      if (ctx.state == 'suspended') ctx.resume();
      final now = ctx.currentTime;
      for (final note in sound.notes) {
        _tone(ctx, note, now + note.start);
      }
    } catch (_) {
      // Sem Web Audio (navegador antigo ou bloqueado): segue em silêncio.
    }
  }

  void _tone(web.AudioContext ctx, Note note, double at) {
    final end = at + note.duration;
    final osc = ctx.createOscillator()
      ..type = note.wave.name;
    osc.frequency.setValueAtTime(note.frequency, at);
    if (note.slideTo != null) osc.frequency.exponentialRampToValueAtTime(note.slideTo!, end);

    // Envelope curto (ataque de 10 ms e decaimento) para não estalar.
    final volume = ctx.createGain();
    volume.gain
      ..setValueAtTime(0.0001, at)
      ..linearRampToValueAtTime(note.gain, at + 0.01)
      ..exponentialRampToValueAtTime(0.0001, end);

    osc
      ..connect(volume)
      ..start(at)
      ..stop(end + 0.02);
    volume.connect(ctx.destination);
  }
}
