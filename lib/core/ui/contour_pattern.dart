import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/game_palette.dart';

/// Fundo animado com curvas de nível.
///
/// - [PatternStyle.lines]: linhas finas que ondulam e escorregam (tema verde).
/// - [PatternStyle.flames]: faixas preenchidas que sobem como chamas (tema roxo).
///
/// Tudo é desenhado em vetor a cada quadro (marching squares numa grade), sem
/// imagens nem shaders, para a entrega continuar sendo só `.dart`.
class ContourPattern extends StatefulWidget {
  const ContourPattern({super.key, required this.style, required this.color});

  final PatternStyle style;
  final Color color;

  @override
  State<ContourPattern> createState() => _ContourPatternState();
}

class _ContourPatternState extends State<ContourPattern> {
  /// Quadros por segundo do fundo. O movimento é lento, então 20 basta.
  ///
  /// Usa um [Timer] e não um Ticker de propósito: um Ticker faz o Flutter gerar
  /// um quadro a cada atualização da tela (até 144 por segundo), e no web cada
  /// quadro redesenha a cena inteira, inclusive este fundo pesado, mesmo
  /// quando ele não mudou. Com o timer, sem outras animações, a tela só é
  /// redesenhada 20 vezes por segundo.
  static const _fps = 20;

  final _time = ValueNotifier<double>(0);
  final _clock = Stopwatch();
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(ContourPattern old) {
    super.didUpdateWidget(old);
    _sync();
  }

  /// Só anima quando há padrão e o sistema não pede para reduzir movimento.
  void _sync() {
    final run = widget.style != PatternStyle.none && !MediaQuery.disableAnimationsOf(context);
    if (!run) {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
    } else if (_timer == null) {
      _clock.start();
      _timer = Timer.periodic(const Duration(microseconds: 1000000 ~/ _fps), (_) {
        _time.value = _clock.elapsedMicroseconds / 1e6;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == PatternStyle.none) return const SizedBox.expand();
    return SizedBox.expand(
      child: CustomPaint(painter: _ContourPainter(_time, widget.style, widget.color)),
    );
  }
}

/// Proporção do enquadramento original (a antiga imagem era 480x300).
const _frameWidth = 480.0;
const _frameHeight = 300.0;

class _ContourPainter extends CustomPainter {
  _ContourPainter(this.time, this.style, this.color) : super(repaint: time);

  final ValueListenable<double> time;
  final PatternStyle style;
  final Color color;

  /// Tamanho da célula da grade, em pixels lógicos.
  static const _cell = 12.0;

  /// Velocidade da deformação do campo (os dois estilos).
  static const _warpSpeed = 0.35;

  /// Deslizamento das linhas, em "níveis" por segundo.
  static const _lineFlow = 0.12;

  /// Subida das chamas, em radianos por segundo.
  static const _flameFlow = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final grid = _Grid(size, _cell);
    final seconds = time.value;
    final warp = seconds * _warpSpeed;

    // Desenha tudo em uma chamada por camada (uma lista de segmentos ou de
    // triângulos). No web, montar um Path faz uma chamada ao motor gráfico por
    // moveTo/lineTo, milhares por quadro; era isso que pesava.
    switch (style) {
      case PatternStyle.lines:
        final flow = seconds * _lineFlow;
        grid.sampleField(warp, flames: false, flow: flow);
        canvas.drawRawPoints(
          ui.PointMode.lines,
          grid.isolineSegments(),
          Paint()
            ..strokeWidth = 1.4
            // Pontas retas: com 1,4 px não se nota diferença, e cada segmento
            // deixa de ganhar duas pontas arredondadas para desenhar.
            ..strokeCap = StrokeCap.butt
            ..color = color.withValues(alpha: 0.18),
        );
      case PatternStyle.flames:
        final flow = seconds * _flameFlow;
        grid.sampleField(warp, flames: true, flow: flow);
        for (final (threshold, alpha) in [(0.575, 0.16), (0.88, 0.14)]) {
          canvas.drawVertices(
            ui.Vertices.raw(ui.VertexMode.triangles, grid.regionTriangles(threshold)),
            BlendMode.srcOver,
            Paint()..color = color.withValues(alpha: alpha),
          );
        }
      case PatternStyle.none:
        return;
    }
  }

  @override
  bool shouldRepaint(_ContourPainter old) => old.time != time || old.style != style || old.color != color;
}

/// Grade de amostras cobrindo a tela, com o mesmo enquadramento (cover) da
/// antiga imagem, e as operações de marching squares sobre ela.
class _Grid {
  _Grid(Size size, double cell)
    : cols = (size.width / cell).ceil() + 1,
      rows = (size.height / cell).ceil() + 1,
      _size = size {
    stepX = size.width / (cols - 1);
    stepY = size.height / (rows - 1);
    values = Float64List(cols * rows);
  }

  final int cols;
  final int rows;
  final Size _size;
  late final double stepX;
  late final double stepY;
  late final Float64List values;

  /// Amostra o campo das curvas de nível no instante [t]:
  ///
  ///   wx = x + 0,9·sen(1,3y + 0,5 + 0,6t) + 0,4·sen(2,7y + 0,6x − 0,45t)
  ///   wy = y + 0,9·sen(1,1x − 0,8 − 0,5t) + 0,4·sen(2,3x − 0,7y + 0,35t)
  ///   f  = sen(1,2wx) + sen(1,4wy) + 0,5·sen(0,9(wx + wy))
  ///
  /// Para ficar barato, o que só depende da coluna ou da linha é calculado uma
  /// vez por coluna/linha, e os senos que misturam x e y viram produtos pela
  /// fórmula sen(a + b) = sen a·cos b + cos a·sen b. Sobram 3 senos por ponto
  /// (eram 7).
  ///
  /// Linhas: guarda 2,2f − [flow] (cada inteiro é uma curva).
  /// Chamas: guarda 0,5 + 0,5·sen(1,15πf − [flow]).
  void sampleField(double t, {required bool flames, required double flow}) {
    final scale = max(_size.width / _frameWidth, _size.height / _frameHeight);
    final imgW = _frameWidth * scale;
    final imgH = _frameHeight * scale;
    final ox = (_size.width - imgW) / 2;
    final oy = (_size.height - imgH) / 2;

    final xs = Float64List(cols);
    final colWarp = Float64List(cols); // 0,9·sen(1,1x − 0,8 − 0,5t)
    final sinA = Float64List(cols); // sen(0,6x)
    final cosA = Float64List(cols); // cos(0,6x)
    final sinB = Float64List(cols); // sen(2,3x + 0,35t)
    final cosB = Float64List(cols); // cos(2,3x + 0,35t)
    for (var i = 0; i < cols; i++) {
      final x = (i * stepX - ox) / imgW * 7;
      xs[i] = x;
      colWarp[i] = 0.9 * sin(x * 1.1 - 0.8 - t * 0.5);
      sinA[i] = sin(x * 0.6);
      cosA[i] = cos(x * 0.6);
      final b = x * 2.3 + t * 0.35;
      sinB[i] = sin(b);
      cosB[i] = cos(b);
    }

    for (var j = 0; j < rows; j++) {
      final y = (j * stepY - oy) / imgH * 4.4;
      final rowWarp = 0.9 * sin(y * 1.3 + 0.5 + t * 0.6);
      final c = y * 2.7 - t * 0.45;
      final sinC = sin(c);
      final cosC = cos(c);
      final sinD = sin(y * 0.7);
      final cosD = cos(y * 0.7);
      final base = j * cols;
      for (var i = 0; i < cols; i++) {
        // sen(c + 0,6x) e sen((2,3x + 0,35t) − 0,7y) pela fórmula da soma.
        final wx = xs[i] + rowWarp + 0.4 * (sinC * cosA[i] + cosC * sinA[i]);
        final wy = y + colWarp[i] + 0.4 * (sinB[i] * cosD - cosB[i] * sinD);
        final f = sin(wx * 1.2) + sin(wy * 1.4) + 0.5 * sin((wx + wy) * 0.9);
        values[base + i] = flames ? 0.5 + 0.5 * sin(f * 1.15 * pi - flow) : f * 2.2 - flow;
      }
    }
  }

  /// Linhas em todos os níveis inteiros do campo, como pares de pontos
  /// (x0, y0, x1, y1, ...) para `drawRawPoints(PointMode.lines)`.
  Float32List isolineSegments() {
    final out = _Floats();
    final pts = List<Offset>.filled(4, Offset.zero);
    for (var j = 0; j < rows - 1; j++) {
      final y0 = j * stepY;
      final y1 = y0 + stepY;
      for (var i = 0; i < cols - 1; i++) {
        final x0 = i * stepX;
        final x1 = x0 + stepX;
        final a = values[j * cols + i]; // topo-esquerda
        final b = values[j * cols + i + 1]; // topo-direita
        final c = values[(j + 1) * cols + i + 1]; // baixo-direita
        final d = values[(j + 1) * cols + i]; // baixo-esquerda
        final lo = min(min(a, b), min(c, d));
        final hi = max(max(a, b), max(c, d));
        for (var k = lo.ceilToDouble(); k <= hi; k++) {
          final ia = a >= k, ib = b >= k, ic = c >= k, id = d >= k;
          var n = 0;
          // Ordem fixa: topo, direita, baixo, esquerda.
          if (ia != ib) pts[n++] = Offset(x0 + (k - a) / (b - a) * stepX, y0);
          if (ib != ic) pts[n++] = Offset(x1, y0 + (k - b) / (c - b) * stepY);
          if (id != ic) pts[n++] = Offset(x0 + (k - d) / (c - d) * stepX, y1);
          if (ia != id) pts[n++] = Offset(x0, y0 + (k - a) / (d - a) * stepY);
          if (n == 2) {
            out.segment(pts[0], pts[1]);
          } else if (n == 4) {
            // Ponto de sela: o centro decide como ligar os quatro cruzamentos.
            final centerInside = (a + b + c + d) / 4 >= k;
            final (p, q, r, s) = centerInside == ia ? (0, 1, 2, 3) : (0, 3, 1, 2);
            out
              ..segment(pts[p], pts[q])
              ..segment(pts[r], pts[s]);
          }
        }
      }
    }
    return out.toList();
  }

  /// Região onde o campo é >= [k], como triângulos (x, y por vértice) para
  /// `drawVertices`. Células inteiramente dentro viram retângulos (juntados
  /// por linha, dois triângulos cada); células cortadas viram o polígono
  /// recortado, em leque.
  Float32List regionTriangles(double k) {
    final out = _Floats();
    final xs = List<double>.filled(4, 0);
    final ys = List<double>.filled(4, 0);
    final vs = List<double>.filled(4, 0);
    final poly = <Offset>[];
    for (var j = 0; j < rows - 1; j++) {
      final y0 = j * stepY;
      final y1 = y0 + stepY;
      int? runStart;
      void flush(int end) {
        if (runStart == null) return;
        out.rect(runStart! * stepX, y0, end * stepX, y1);
        runStart = null;
      }

      for (var i = 0; i < cols - 1; i++) {
        final x0 = i * stepX;
        final x1 = x0 + stepX;
        vs[0] = values[j * cols + i];
        vs[1] = values[j * cols + i + 1];
        vs[2] = values[(j + 1) * cols + i + 1];
        vs[3] = values[(j + 1) * cols + i];
        final inside = (vs[0] >= k ? 1 : 0) + (vs[1] >= k ? 1 : 0) + (vs[2] >= k ? 1 : 0) + (vs[3] >= k ? 1 : 0);
        if (inside == 4) {
          runStart ??= i;
          continue;
        }
        flush(i);
        if (inside == 0) continue;

        xs[0] = x0; ys[0] = y0; // topo-esquerda
        xs[1] = x1; ys[1] = y0; // topo-direita
        xs[2] = x1; ys[2] = y1; // baixo-direita
        xs[3] = x0; ys[3] = y1; // baixo-esquerda
        poly.clear();
        for (var e = 0; e < 4; e++) {
          final f = (e + 1) % 4;
          final inE = vs[e] >= k;
          if (inE) poly.add(Offset(xs[e], ys[e]));
          if (inE != (vs[f] >= k)) {
            final t = (k - vs[e]) / (vs[f] - vs[e]);
            poly.add(Offset(xs[e] + (xs[f] - xs[e]) * t, ys[e] + (ys[f] - ys[e]) * t));
          }
        }
        out.fan(poly);
      }
      flush(cols - 1);
    }
    return out.toList();
  }
}

/// Lista de floats que cresce sozinha, para montar a geometria sem criar um
/// objeto por ponto.
class _Floats {
  Float32List _data = Float32List(4096);
  int _length = 0;

  void _add(double v) {
    if (_length == _data.length) {
      final bigger = Float32List(_data.length * 2)..setAll(0, _data);
      _data = bigger;
    }
    _data[_length++] = v;
  }

  void _point(double x, double y) {
    _add(x);
    _add(y);
  }

  void segment(Offset a, Offset b) {
    _point(a.dx, a.dy);
    _point(b.dx, b.dy);
  }

  void rect(double left, double top, double right, double bottom) {
    _point(left, top);
    _point(right, top);
    _point(right, bottom);
    _point(left, top);
    _point(right, bottom);
    _point(left, bottom);
  }

  /// Polígono convexo em leque a partir do primeiro vértice.
  void fan(List<Offset> poly) {
    for (var i = 1; i < poly.length - 1; i++) {
      _point(poly[0].dx, poly[0].dy);
      _point(poly[i].dx, poly[i].dy);
      _point(poly[i + 1].dx, poly[i + 1].dy);
    }
  }

  Float32List toList() => Float32List.sublistView(_data, 0, _length);
}
