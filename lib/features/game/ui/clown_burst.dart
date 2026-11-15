import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/ui/pixel_clown.dart';

enum ClownMood { sad, happy }

/// Muitos palhaços pela tela como reação à verificação:
/// - [ClownMood.sad]: chuva de palhaços azuis chorando, caindo de cima;
/// - [ClownMood.happy]: palhaços vermelhos fazendo joinha, pulando de baixo
///   para cima como confete.
///
/// Cada vez que [trigger] muda, uma nova leva aparece e some sozinha em ~2,6 s.
/// Fica sob [IgnorePointer], então nunca bloqueia toques ou arrastos.
class ClownBurst extends StatefulWidget {
  const ClownBurst({super.key, required this.mood, required this.trigger});

  final ClownMood mood;
  final int trigger;

  @override
  State<ClownBurst> createState() => _ClownBurstState();
}

class _ClownBurstState extends State<ClownBurst> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2600);

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duration);
  final _random = Random();
  List<_Clown> _clowns = const [];

  @override
  void didUpdateWidget(ClownBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) {
      _clowns = List.generate(18, (_) => _Clown.random(_random));
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
                clowns: _clowns,
                mood: widget.mood,
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

/// Parâmetros aleatórios de um palhaço da leva (em frações da tela).
class _Clown {
  const _Clown({
    required this.x,
    required this.unit,
    required this.delay,
    required this.travel,
    required this.peakTime,
    required this.drift,
    required this.spin,
    required this.sway,
    required this.flip,
  });

  factory _Clown.random(Random r) => _Clown(
    x: r.nextDouble(),
    unit: 2.2 + r.nextDouble() * 2.2,
    delay: r.nextDouble() * 0.6,
    travel: 0.45 + r.nextDouble() * 0.45,
    peakTime: 0.75 + r.nextDouble() * 0.35,
    drift: (r.nextDouble() - 0.5) * 0.25,
    spin: (r.nextDouble() - 0.5) * 4,
    sway: r.nextDouble() * pi * 2,
    flip: r.nextBool(),
  );

  final double x;
  final double unit;
  final double delay;
  final double travel;
  final double peakTime;
  final double drift;
  final double spin;
  final double sway;
  final bool flip;
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.clowns, required this.mood, required this.seconds, required this.still});

  final List<_Clown> clowns;
  final ClownMood mood;
  final double seconds;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final look = mood == ClownMood.sad ? ClownLook.crying : ClownLook.thumbsUp;
    final colors = mood == ClownMood.sad ? ClownColors.blue : ClownColors.redYellow;
    final picture = PixelClown.picture(look, colors);
    final cols = PixelClown.columns(look).toDouble();
    final rows = PixelClown.rows(look).toDouble();
    // Palhaços um pouco maiores em telas grandes.
    final scale = (size.shortestSide / 420).clamp(0.8, 1.6);

    for (final c in clowns) {
      final t = seconds - c.delay;
      if (t <= 0) continue;
      final u = c.unit * scale;
      final h = rows * u;

      double cx;
      double cy;
      double angle;
      if (still) {
        // "Reduzir movimento": aparecem parados, espalhados.
        cx = c.x * size.width;
        cy = (0.15 + c.travel * 0.7) * size.height;
        angle = 0;
      } else if (mood == ClownMood.sad) {
        // Caem de cima, devagar, balançando de um lado para o outro.
        final fall = size.height * (0.55 + c.travel * 0.5);
        cx = c.x * size.width + sin(t * 3 + c.sway) * u * 4;
        cy = -h + t * fall;
        angle = sin(t * 2.5 + c.sway) * 0.18;
      } else {
        // Pulam de baixo, sobem até um pico e voltam a cair, girando.
        final peak = size.height * c.travel;
        final g = 2 * peak / (c.peakTime * c.peakTime);
        final v0 = g * c.peakTime;
        cx = c.x * size.width + c.drift * size.width * t;
        cy = size.height + h / 2 - v0 * t + g * t * t / 2;
        angle = c.spin * t * 0.5;
      }

      // Entram crescendo rapidinho.
      final pop = Curves.easeOutBack.transform((t / 0.25).clamp(0.0, 1.0));

      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(angle)
        ..scale(u * pop * (c.flip ? -1 : 1), u * pop)
        ..translate(-cols / 2, -rows / 2)
        ..drawPicture(picture)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}
