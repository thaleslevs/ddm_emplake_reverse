import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;

import 'package:web/web.dart' as web;

import 'music_score.dart';

/// Toca a [MusicScore] em loop com a Web Audio API.
///
/// As notas são agendadas um pouco à frente do relógio de áudio (a cada
/// 25 ms, até 150 ms adiante): o timer do Dart pode atrasar, o relógio de
/// áudio não, então o ritmo fica estável mesmo com o jogo ocupado.
class MusicPlayer {
  static const _lookAhead = 0.15;
  static const _volume = 0.55;

  web.AudioContext? _ctx;
  web.GainNode? _master;
  web.GainNode? _wobble;
  web.GainNode? _vibrato;
  web.AudioBuffer? _noise;

  Timer? _timer;
  double _nextStepTime = 0;
  int _step = 0;
  int _loop = 0;

  bool get isPlaying => _timer != null;

  /// Os navegadores só liberam áudio depois de um toque: chamado a cada
  /// toque na tela, retoma o contexto se a música estiver ligada e travada.
  void unlock() {
    final ctx = _ctx;
    if (isPlaying && ctx != null && ctx.state == 'suspended') ctx.resume();
  }

  void start() {
    if (isPlaying) return;
    try {
      final ctx = _ctx ??= _build();
      if (ctx.state == 'suspended') ctx.resume();
      final now = ctx.currentTime;
      _master!.gain
        ..cancelScheduledValues(now)
        ..setValueAtTime(0.0001, now)
        ..exponentialRampToValueAtTime(_volume, now + 1.2);
      _nextStepTime = now + 0.1;
      _step = 0;
      _loop = 0;
      _timer = Timer.periodic(const Duration(milliseconds: 25), (_) => _schedule());
    } catch (_) {
      // Sem Web Audio: segue em silêncio.
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    final ctx = _ctx;
    if (ctx == null) return;
    final now = ctx.currentTime;
    // Desce o volume em vez de cortar, para as notas já agendadas sumirem
    // sem estalo.
    _master!.gain
      ..cancelScheduledValues(now)
      ..setValueAtTime(_volume, now)
      ..exponentialRampToValueAtTime(0.0001, now + 0.5);
  }

  web.AudioContext _build() {
    final ctx = web.AudioContext();

    // Saída: volume geral e um passa-baixa para o som ficar quente e "lo-fi".
    final tone = ctx.createBiquadFilter()..type = 'lowpass';
    tone.frequency.setValueAtTime(2400, 0);
    tone.connect(ctx.destination);
    _master = ctx.createGain()..connect(tone);
    _master!.gain.setValueAtTime(0.0001, 0);

    // Ondulação lenta da afinação (fita velha), em centésimos de semitom, e
    // um vibrato mais rápido e raso para a melodia.
    _wobble = _lfo(ctx, rate: 0.33, depthCents: 14);
    _vibrato = _lfo(ctx, rate: 5.2, depthCents: 9);

    // Ruído branco curto, reaproveitado no chimbal.
    final length = (ctx.sampleRate * 0.08).round();
    final noise = ctx.createBuffer(1, length, ctx.sampleRate);
    final data = noise.getChannelData(0).toDart;
    final random = math.Random(3);
    for (var i = 0; i < length; i++) {
      data[i] = random.nextDouble() * 2 - 1;
    }
    _noise = noise;
    return ctx;
  }

  web.GainNode _lfo(web.AudioContext ctx, {required double rate, required double depthCents}) {
    final osc = ctx.createOscillator()..type = 'sine';
    osc.frequency.setValueAtTime(rate, 0);
    final depth = ctx.createGain();
    depth.gain.setValueAtTime(depthCents, 0);
    osc
      ..connect(depth)
      ..start();
    return depth;
  }

  void _schedule() {
    final ctx = _ctx;
    if (ctx == null) return;
    while (_nextStepTime < ctx.currentTime + _lookAhead) {
      _playStep(ctx, _step, _nextStepTime);
      _nextStepTime += MusicScore.stepSeconds;
      _step++;
      if (_step == MusicScore.bars.length * MusicScore.stepsPerBar) {
        _step = 0;
        _loop++;
      }
    }
  }

  void _playStep(web.AudioContext ctx, int step, double at) {
    final bar = MusicScore.bars[step ~/ MusicScore.stepsPerBar];
    final pos = step % MusicScore.stepsPerBar;
    final stepLen = MusicScore.stepSeconds;

    if (pos == 0) {
      final barLen = stepLen * MusicScore.stepsPerBar;
      for (final note in bar.chord) {
        _pad(ctx, MusicScore.frequency(note), at, barLen * 1.08);
      }
    }
    if (pos == 0 || pos == 4) _kick(ctx, at, pos == 0 ? 0.32 : 0.2);
    if (pos.isOdd) _hat(ctx, at, pos == 3 || pos == 7 ? 0.05 : 0.03);

    for (final (start, semitones, length) in MusicScore.bassPattern) {
      if (start == pos) _bass(ctx, MusicScore.frequency(bar.bassRoot + semitones), at, stepLen * length);
    }

    // Uma volta a cada três fica sem melodia.
    if (_loop % 3 != 2) {
      for (final (start, note, length) in bar.melody) {
        if (start == pos) _lead(ctx, MusicScore.frequency(note), at, stepLen * length);
      }
    }
  }

  /// Teclado do acorde: duas ondas dente-de-serra levemente desafinadas,
  /// abafadas por um filtro e ondulando com o LFO lento.
  void _pad(web.AudioContext ctx, double freq, double at, double length) {
    final filter = ctx.createBiquadFilter()..type = 'lowpass';
    filter.frequency.setValueAtTime(900, at);
    final env = ctx.createGain();
    env.gain
      ..setValueAtTime(0.0001, at)
      ..linearRampToValueAtTime(0.022, at + 0.35)
      ..setValueAtTime(0.022, at + length - 0.5)
      ..linearRampToValueAtTime(0.0001, at + length);
    filter.connect(env);
    env.connect(_master!);
    for (final detune in [-7.0, 7.0]) {
      final osc = ctx.createOscillator()..type = 'sawtooth';
      osc.frequency.setValueAtTime(freq, at);
      osc.detune.setValueAtTime(detune, at);
      _wobble!.connect(osc.detune);
      osc
        ..connect(filter)
        ..start(at)
        ..stop(at + length + 0.05);
    }
  }

  void _bass(web.AudioContext ctx, double freq, double at, double length) {
    final env = ctx.createGain();
    env.gain
      ..setValueAtTime(0.0001, at)
      ..linearRampToValueAtTime(0.16, at + 0.02)
      ..exponentialRampToValueAtTime(0.0001, at + length * 0.95);
    env.connect(_master!);
    final osc = ctx.createOscillator()..type = 'triangle';
    osc.frequency.setValueAtTime(freq, at);
    _wobble!.connect(osc.detune);
    osc
      ..connect(env)
      ..start(at)
      ..stop(at + length);
  }

  /// Melodia: onda quadrada suave com vibrato e um leve deslize ao entrar.
  void _lead(web.AudioContext ctx, double freq, double at, double length) {
    final filter = ctx.createBiquadFilter()..type = 'lowpass';
    filter.frequency.setValueAtTime(1800, at);
    final env = ctx.createGain();
    env.gain
      ..setValueAtTime(0.0001, at)
      ..linearRampToValueAtTime(0.045, at + 0.03)
      ..setValueAtTime(0.045, at + length * 0.7)
      ..exponentialRampToValueAtTime(0.0001, at + length);
    filter.connect(env);
    env.connect(_master!);
    final osc = ctx.createOscillator()..type = 'square';
    osc.frequency
      ..setValueAtTime(freq * 0.985, at)
      ..exponentialRampToValueAtTime(freq, at + 0.06);
    _vibrato!.connect(osc.detune);
    osc
      ..connect(filter)
      ..start(at)
      ..stop(at + length + 0.02);
  }

  /// Bumbo suave: seno que cai de 110 para 45 Hz.
  void _kick(web.AudioContext ctx, double at, double gain) {
    final env = ctx.createGain();
    env.gain
      ..setValueAtTime(gain, at)
      ..exponentialRampToValueAtTime(0.0001, at + 0.28);
    env.connect(_master!);
    final osc = ctx.createOscillator()..type = 'sine';
    osc.frequency
      ..setValueAtTime(110, at)
      ..exponentialRampToValueAtTime(45, at + 0.18);
    osc
      ..connect(env)
      ..start(at)
      ..stop(at + 0.3);
  }

  /// Chimbal: ruído branco curto num passa-alta.
  void _hat(web.AudioContext ctx, double at, double gain) {
    final src = ctx.createBufferSource()..buffer = _noise;
    final filter = ctx.createBiquadFilter()..type = 'highpass';
    filter.frequency.setValueAtTime(6500, at);
    final env = ctx.createGain();
    env.gain
      ..setValueAtTime(gain, at)
      ..exponentialRampToValueAtTime(0.0001, at + 0.05);
    src
      ..connect(filter)
      ..start(at);
    filter.connect(env);
    env.connect(_master!);
  }
}
