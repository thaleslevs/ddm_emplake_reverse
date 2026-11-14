import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/game_palette.dart';

class FeltBackground extends StatelessWidget {
  const FeltBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = GamePalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.35),
          radius: 1.25,
          colors: [p.background, p.backgroundDeep],
          stops: const [0.45, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: _GrainPainter())),
          ),
          child,
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final count = (size.width * size.height / 180).round() * 2;
    final light = Float32List(count);
    final dark = Float32List(count);
    for (var i = 0; i < count; i += 2) {
      light[i] = random.nextDouble() * size.width;
      light[i + 1] = random.nextDouble() * size.height;
      dark[i] = random.nextDouble() * size.width;
      dark[i + 1] = random.nextDouble() * size.height;
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      light,
      Paint()
        ..color = const Color(0x0DFFFFFF)
        ..strokeWidth = 1,
    );
    canvas.drawRawPoints(
      ui.PointMode.points,
      dark,
      Paint()
        ..color = const Color(0x14000000)
        ..strokeWidth = 1,
    );

    final scan = Paint()..color = const Color(0x08000000);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), scan);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
