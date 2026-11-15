import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/pixel_clown.dart';
import '../../shop/account.dart';
import '../../shop/shop_catalog.dart';

enum ClownMood { sad, happy }

/// Reação na tela inteira depois de verificar:
/// - [ClownMood.sad]: chuva de palhaços chorando, na skin em uso;
/// - [ClownMood.happy]: o efeito de acerto em uso (palhaços fazendo joinha,
///   confete, estrelas, moedas ou fogos de artifício).
///
/// Cada vez que [trigger] muda, uma nova leva aparece e some sozinha em ~2,6 s.
/// Fica sob [IgnorePointer], então nunca bloqueia toques ou arrastos.
/// [effect] força um efeito (prévia na loja).
class ClownBurst extends ConsumerStatefulWidget {
  const ClownBurst({super.key, required this.mood, required this.trigger, this.effect});

  final ClownMood mood;
  final int trigger;
  final WinEffect? effect;

  @override
  ConsumerState<ClownBurst> createState() => _ClownBurstState();
}

class _ClownBurstState extends ConsumerState<ClownBurst> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2600);

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duration);
  final _random = Random();
  List<_Particle> _particles = const [];

  @override
  void didUpdateWidget(ClownBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) {
      _particles = List.generate(70, (_) => _Particle.random(_random));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final skin = ref.watch(equippedSkinProvider);
    final WinEffect effect =
        widget.mood == ClownMood.sad ? WinEffect.clowns : (widget.effect ?? ref.watch(equippedEffectProvider));
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isAnimating) return const SizedBox.expand();
          final t = _controller.value;
          // Some junto no final.
          final fade = t < 0.82 ? 1.0 : 1 - (t - 0.82) / 0.18;
          return Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: _BurstPainter(
                particles: _particles,
                mood: widget.mood,
                effect: effect,
                skin: skin,
                seconds: t * _duration.inMilliseconds / 1000,
                still: still,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Parâmetros aleatórios de uma partícula (em frações da tela).
class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.unit,
    required this.delay,
    required this.travel,
    required this.peakTime,
    required this.drift,
    required this.spin,
    required this.sway,
    required this.flip,
    required this.hue,
  });

  factory _Particle.random(Random r) => _Particle(
    x: r.nextDouble(),
    y: r.nextDouble(),
    unit: 2.2 + r.nextDouble() * 2.2,
    delay: r.nextDouble() * 0.6,
    travel: 0.45 + r.nextDouble() * 0.45,
    peakTime: 0.75 + r.nextDouble() * 0.35,
    drift: (r.nextDouble() - 0.5) * 0.25,
    spin: (r.nextDouble() - 0.5) * 4,
    sway: r.nextDouble() * pi * 2,
    flip: r.nextBool(),
    hue: r.nextInt(1 << 16),
  );

  final double x;
  final double y;
  final double unit;
  final double delay;
  final double travel;
  final double peakTime;
  final double drift;
  final double spin;
  final double sway;
  final bool flip;
  final int hue;
}

const _confettiColors = [
  Color(0xFFF7C12E),
  Color(0xFFE0483C),
  Color(0xFF3E9BF0),
  Color(0xFF3DBF7F),
  Color(0xFFE5609E),
  Color(0xFFF4F1E8),
];

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.particles,
    required this.mood,
    required this.effect,
    required this.skin,
    required this.seconds,
    required this.still,
  });

  final List<_Particle> particles;
  final ClownMood mood;
  final WinEffect effect;
  final ClownSkin skin;
  final double seconds;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    // Palhaços um pouco maiores em telas grandes.
    final scale = (size.shortestSide / 420).clamp(0.8, 1.6);
    switch (effect) {
      case WinEffect.clowns:
        _clowns(canvas, size, scale);
      case WinEffect.confetti:
        _confetti(canvas, size, scale);
      case WinEffect.stars:
        _stars(canvas, size, scale);
      case WinEffect.coins:
        _coins(canvas, size, scale);
      case WinEffect.fireworks:
        _fireworks(canvas, size, scale);
    }
  }

  /// Sobe de baixo até um pico e volta a cair (posição vertical no tempo [t]).
  double _jumpY(_Particle p, Size size, double t, double extra) {
    final peak = size.height * p.travel;
    final g = 2 * peak / (p.peakTime * p.peakTime);
    return size.height + extra - g * p.peakTime * t + g * t * t / 2;
  }

  void _clowns(Canvas canvas, Size size, double scale) {
    final look = mood == ClownMood.sad ? ClownLook.crying : ClownLook.thumbsUp;
    final colors = mood == ClownMood.sad ? skin.sad : skin.happy;
    final picture = PixelClown.picture(look, skin, colors);
    final cols = PixelClown.columns(look).toDouble();
    final rows = PixelClown.rows(look).toDouble();

    for (final p in particles.take(18)) {
      final t = seconds - p.delay;
      if (t <= 0) continue;
      final u = p.unit * scale;
      final h = rows * u;
      double cx;
      double cy;
      double angle;
      if (still) {
        // "Reduzir movimento": aparecem parados, espalhados.
        cx = p.x * size.width;
        cy = (0.15 + p.travel * 0.7) * size.height;
        angle = 0;
      } else if (mood == ClownMood.sad) {
        // Caem de cima, devagar, balançando de um lado para o outro.
        final fall = size.height * (0.55 + p.travel * 0.5);
        cx = p.x * size.width + sin(t * 3 + p.sway) * u * 4;
        cy = -h + t * fall;
        angle = sin(t * 2.5 + p.sway) * 0.18;
      } else {
        // Pulam de baixo, sobem até um pico e voltam a cair, girando.
        cx = p.x * size.width + p.drift * size.width * t;
        cy = _jumpY(p, size, t, h / 2);
        angle = p.spin * t * 0.5;
      }
      // Entram crescendo rapidinho.
      final pop = Curves.easeOutBack.transform((t / 0.25).clamp(0.0, 1.0));
      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(angle)
        ..scale(u * pop * (p.flip ? -1 : 1), u * pop)
        ..translate(-cols / 2, -rows / 2)
        ..drawPicture(picture)
        ..restore();
    }
  }

  /// Papéis coloridos lançados de baixo, girando e "virando" no ar.
  void _confetti(Canvas canvas, Size size, double scale) {
    final paint = Paint();
    for (final p in particles) {
      final t = seconds - p.delay * 0.5;
      if (t <= 0) continue;
      final cx = still ? p.x * size.width : p.x * size.width + p.drift * size.width * t * 1.5;
      final cy = still ? p.y * size.height : _jumpY(p, size, t, 10);
      final w = 5.0 * scale;
      final h = 10.0 * scale;
      paint.color = _confettiColors[p.hue % _confettiColors.length];
      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(still ? 0 : p.spin * t * 1.6)
        ..scale(still ? 1 : cos(t * 9 + p.sway), 1)
        ..drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint)
        ..restore();
    }
  }

  /// Estrelas de pixel que acendem, crescem e apagam pela tela.
  void _stars(Canvas canvas, Size size, double scale) {
    final picture = _PixelArt.star;
    for (final p in particles.take(32)) {
      final t = seconds - p.delay * 2.4;
      const life = 1.1;
      if (t <= 0 || t > life) continue;
      final pulse = sin(pi * t / life);
      final u = (1.6 + p.unit * 0.5) * scale * (still ? 1 : pulse);
      canvas
        ..save()
        ..translate(p.x * size.width, (0.05 + p.y * 0.8) * size.height)
        ..rotate(still ? 0 : (t - life / 2) * p.spin * 0.3)
        ..scale(u)
        ..translate(-3.5, -3.5)
        ..drawPicture(picture)
        ..restore();
    }
  }

  /// Moedas de pixel caindo de cima e girando.
  void _coins(Canvas canvas, Size size, double scale) {
    final picture = _PixelArt.coin;
    for (final p in particles.take(36)) {
      final t = seconds - p.delay * 1.2;
      if (t <= 0) continue;
      final u = (1.8 + p.unit * 0.35) * scale;
      final fall = size.height * (0.5 + p.travel * 0.6);
      final cy = still ? p.y * size.height : -12 * u + t * fall + 90 * t * t;
      canvas
        ..save()
        ..translate(p.x * size.width, cy)
        ..scale(u * (still ? 1 : cos(t * 7 + p.sway)), u)
        ..translate(-4, -4)
        ..drawPicture(picture)
        ..restore();
    }
  }

  /// Foguetes que sobem e explodem em faíscas que caem e apagam.
  void _fireworks(Canvas canvas, Size size, double scale) {
    final paint = Paint();
    const launch = 0.45;
    for (var i = 0; i < 6; i++) {
      final p = particles[i];
      final start = i * 0.28;
      final t = seconds - start;
      if (t <= 0) continue;
      final center = Offset((0.15 + p.x * 0.7) * size.width, (0.12 + p.y * 0.4) * size.height);
      final color = _confettiColors[p.hue % (_confettiColors.length - 1)];
      final px = 5.0 * scale;
      if (!still && t < launch) {
        // Rastro subindo.
        final k = Curves.easeOut.transform(t / launch);
        final y = size.height + (center.dy - size.height) * k;
        paint.color = const Color(0xFFF4F1E8);
        canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, y), width: px, height: px * 3), paint);
        continue;
      }
      final te = still ? 0.5 : t - launch;
      const life = 1.3;
      if (te > life) continue;
      final alpha = (1 - te / life).clamp(0.0, 1.0);
      const sparks = 28;
      for (var s = 0; s < sparks; s++) {
        final a = s / sparks * pi * 2 + p.sway;
        final speed = (110 + (s % 3) * 35) * scale;
        final pos = center + Offset(cos(a), sin(a)) * speed * te + Offset(0, 60 * te * te);
        paint.color = (s % 3 == 0 ? const Color(0xFFF4F1E8) : color).withValues(alpha: alpha);
        canvas.drawRect(Rect.fromCenter(center: pos, width: px, height: px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}

/// Pequenos desenhos em pixel dos efeitos, gravados uma vez.
abstract final class _PixelArt {
  static final star = _record(const [
    '...y...',
    '...y...',
    '..yYy..',
    'yyYwYyy',
    '..yYy..',
    '...y...',
    '...y...',
  ], const {'y': Color(0xFFFFD54A), 'Y': Color(0xFFFFEC99), 'w': Color(0xFFFFFFFF)});

  static final coin = _record(const [
    '..oooo..',
    '.oyyyyo.',
    'oyyYyyyo',
    'oyYyyyyo',
    'oyYyyyyo',
    'oyyyyyyo',
    '.oyyyyo.',
    '..oooo..',
  ], const {'o': Color(0xFF8A5A00), 'y': Color(0xFFF2C744), 'Y': Color(0xFFFFF1A8)});

  static ui.Picture _record(List<String> rows, Map<String, Color> colors) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        final color = colors[rows[y][x]];
        if (color != null) canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.06, 1.06), Paint()..color = color);
      }
    }
    return recorder.endRecording();
  }
}
