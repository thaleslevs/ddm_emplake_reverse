import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/game_palette.dart';

class ContourPattern extends StatefulWidget {
  const ContourPattern({super.key, required this.style, required this.color});

  final PatternStyle style;
  final Color color;

  @override
  State<ContourPattern> createState() => _ContourPatternState();
}

class _ContourPatternState extends State<ContourPattern> {
  static final _cache = <(PatternStyle, int), Future<ui.Image>>{};
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ContourPattern old) {
    super.didUpdateWidget(old);
    if (old.style != widget.style || old.color != widget.color) _load();
  }

  void _load() {
    if (widget.style == PatternStyle.none) {
      setState(() => _image = null);
      return;
    }
    final key = (widget.style, widget.color.toARGB32());
    final future = _cache.putIfAbsent(key, () => _render(widget.style, widget.color));
    future.then((image) {
      if (mounted && widget.style == key.$1 && widget.color.toARGB32() == key.$2) {
        setState(() => _image = image);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: image == null
          ? const SizedBox.expand()
          : SizedBox.expand(
              key: ValueKey(image),
              child: CustomPaint(painter: _ImageCoverPainter(image)),
            ),
    );
  }
}

class _ImageCoverPainter extends CustomPainter {
  const _ImageCoverPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.cover, src, size);
    final srcRect = Alignment.center.inscribe(fitted.source, Offset.zero & src);
    canvas.drawImageRect(image, srcRect, Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(_ImageCoverPainter old) => old.image != image;
}

const _width = 480;
const _height = 300;

double _field(double x, double y) {
  final wx = x + 0.9 * sin(y * 1.3 + 0.5) + 0.4 * sin(y * 2.7 + x * 0.6);
  final wy = y + 0.9 * sin(x * 1.1 - 0.8) + 0.4 * sin(x * 2.3 - y * 0.7);
  return sin(wx * 1.2) + sin(wy * 1.4) + 0.5 * sin((wx + wy) * 0.9);
}

double _smoothstep(double a, double b, double x) {
  final t = ((x - a) / (b - a)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

double _alpha(PatternStyle style, double f) {
  switch (style) {
    case PatternStyle.lines:
      final t = f * 2.2;
      final frac = t - t.floorToDouble();
      final d = min(frac, 1 - frac);
      return d < 0.04 ? (1 - d / 0.04) * 0.16 : 0;
    case PatternStyle.flames:
      final v = 0.5 + 0.5 * sin(f * 1.15 * pi);
      return _smoothstep(0.55, 0.6, v) * 0.16 + _smoothstep(0.86, 0.9, v) * 0.12;
    case PatternStyle.none:
      return 0;
  }
}

Future<ui.Image> _render(PatternStyle style, Color color) {
  final pixels = Uint8List(_width * _height * 4);
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  for (var j = 0; j < _height; j++) {
    for (var i = 0; i < _width; i++) {
      final a = _alpha(style, _field(i / _width * 7, j / _height * 4.4));
      final o = (j * _width + i) * 4;
      pixels[o] = (r * a).round();
      pixels[o + 1] = (g * a).round();
      pixels[o + 2] = (b * a).round();
      pixels[o + 3] = (a * 255).round();
    }
  }
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(pixels, _width, _height, ui.PixelFormat.rgba8888, completer.complete);
  return completer.future;
}
