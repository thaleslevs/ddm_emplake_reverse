import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pixel_clown.dart';

/// Palhaço neutro ao lado do título: parado, com uma respiração leve (o corpo
/// sobe 1 pixel e volta; os pés ficam no chão). [skin] e [colors] vêm da skin
/// em uso (lado esquerdo ou direito).
class TitleClown extends StatefulWidget {
  const TitleClown({
    super.key,
    required this.colors,
    required this.unit,
    this.skin = ClownSkins.classic,
    this.phase = 0,
  });

  final ClownColors colors;
  final ClownSkin skin;

  /// Tamanho de um pixel do desenho, em pixels lógicos.
  final double unit;

  /// Defasagem da respiração (0..1), para os dois não respirarem juntos.
  final double phase;

  @override
  State<TitleClown> createState() => _TitleClownState();
}

class _TitleClownState extends State<TitleClown> {
  /// Meio ciclo da respiração: o corpo fica parado ou erguido por esse tempo.
  static const _half = Duration(milliseconds: 900);

  /// 1 com o corpo erguido. Só muda a cada [_half], então o palhaço só é
  /// redesenhado nessas trocas (e não a cada quadro da tela).
  final _lift = ValueNotifier<int>(0);
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel();
      _timer = null;
      _lift.value = 0;
    } else {
      _timer ??= Timer(_half * (widget.phase * 2), () {
        _toggle();
        _timer = Timer.periodic(_half, (_) => _toggle());
      });
    }
  }

  void _toggle() => _lift.value = 1 - _lift.value;

  @override
  void dispose() {
    _timer?.cancel();
    _lift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.unit;
    return SizedBox(
      width: PixelClown.columns(ClownLook.neutral) * u,
      // Uma linha a mais em cima para caber a subida da respiração.
      height: (PixelClown.rows(ClownLook.neutral) + 1) * u,
      child: RepaintBoundary(
        child: CustomPaint(painter: _BreathingClownPainter(widget.skin, widget.colors, _lift)),
      ),
    );
  }
}

class _BreathingClownPainter extends CustomPainter {
  _BreathingClownPainter(this.skin, this.colors, this.liftListenable) : super(repaint: liftListenable);

  final ClownSkin skin;
  final ClownColors colors;
  final ValueListenable<int> liftListenable;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = PixelClown.shape(ClownLook.neutral, skin);
    final u = size.width / rows.first.length;
    // Parado ou "inspirando" (corpo 1 pixel acima).
    final lift = liftListenable.value;
    final paints = <String, Paint>{};
    for (var y = 0; y < rows.length; y++) {
      final top = y < PixelClown.legsFrom ? y + 1 - lift : y + 1;
      PixelClown.paintRow(canvas, rows[y], top, colors, u, paints);
    }
    // Com o corpo erguido, repete a última linha do macacão para não abrir
    // fresta entre ele e as pernas.
    if (lift == 1) {
      PixelClown.paintRow(canvas, rows[PixelClown.legsFrom - 1], PixelClown.legsFrom, colors, u, paints);
    }
  }

  @override
  bool shouldRepaint(_BreathingClownPainter old) => old.colors != colors || old.skin != skin;
}
