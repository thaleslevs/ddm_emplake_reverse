import 'dart:math';

import 'package:web/web.dart' as web;

import 'game_sound.dart';

/// Toca os efeitos com osciladores da Web Audio API, sem arquivos de áudio.
class SoundPlayer {
  web.AudioContext? _context;

  /// Criado só no primeiro som: os navegadores só liberam áudio depois de um
  /// toque ou clique, e todo som do jogo vem de um.
  web.AudioContext get _ctx => _context ??= web.AudioContext();

  /// [volume] de 0 a 1 multiplica o volume de cada nota.
  void play(GameSound sound, {double volume = 1}) {
    if (volume <= 0) return;
    try {
      final ctx = _ctx;
      if (ctx.state == 'suspended') ctx.resume();
      final now = ctx.currentTime;
      for (final note in sound.notes) {
        _tone(ctx, note, now + note.start, volume);
      }
    } catch (_) {
      // Sem Web Audio (navegador antigo ou bloqueado): segue em silêncio.
    }
  }

  void _tone(web.AudioContext ctx, Note note, double at, double volume) {
    final end = at + note.duration;
    final osc = ctx.createOscillator()
      ..type = note.wave.name;
    osc.frequency.setValueAtTime(note.frequency, at);
    if (note.slideTo != null) osc.frequency.exponentialRampToValueAtTime(note.slideTo!, end);

    // Envelope curto (ataque de 10 ms e decaimento) para não estalar.
    final envelope = ctx.createGain();
    envelope.gain
      ..setValueAtTime(0.0001, at)
      ..linearRampToValueAtTime(max(0.0001, note.gain * volume), at + 0.01)
      ..exponentialRampToValueAtTime(0.0001, end);

    osc
      ..connect(envelope)
      ..start(at)
      ..stop(end + 0.02);
    envelope.connect(ctx.destination);
  }
}
