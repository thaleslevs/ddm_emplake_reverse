import 'package:flutter/material.dart';

import '../domain/token.dart';
import 'drag_support.dart';
import 'piece_tile.dart';

class Flight {
  const Flight({
    required this.kind,
    required this.from,
    required this.to,
    required this.toKey,
    required this.order,
  });
  final TokenKind kind;
  final Rect from;
  final Rect to;
  final GlobalKey toKey;

  final int order;
}

class FlightLayer extends StatelessWidget {
  const FlightLayer({super.key, required this.flights, required this.stackKey});

  final List<Flight> flights;
  final GlobalKey stackKey;

  static const flightDuration = Duration(milliseconds: 520);
  static const stagger = Duration(milliseconds: 45);

  static Duration totalFor(int count) => flightDuration + stagger * (count > 0 ? count - 1 : 0);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final f in flights)
            _FlyingPiece(flight: f, total: totalFor(flights.length), stackKey: stackKey),
        ],
      ),
    );
  }
}

class _FlyingPiece extends StatelessWidget {
  const _FlyingPiece({required this.flight, required this.total, required this.stackKey});

  final Flight flight;
  final Duration total;
  final GlobalKey stackKey;

  Rect _target() {
    final stack = stackKey.currentContext?.findRenderObject();
    if (stack is! RenderBox) return flight.to;
    return PieceKeys.rectOf(flight.toKey, stack) ?? flight.to;
  }

  @override
  Widget build(BuildContext context) {
    final start = (FlightLayer.stagger * flight.order).inMicroseconds / total.inMicroseconds;
    final end = start + FlightLayer.flightDuration.inMicroseconds / total.inMicroseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, end.clamp(0, 1), curve: Curves.easeInOutCubic),
      builder: (context, t, child) {
        final rect = Rect.lerp(flight.from, _target(), t)!;
        final lift = -40 * (1 - (2 * t - 1) * (2 * t - 1));
        return Positioned.fromRect(
          rect: rect.shift(Offset(0, lift)),
          child: FittedBox(
            child: PieceTile(kind: flight.kind, size: flight.from.height, lifted: t > 0 && t < 1),
          ),
        );
      },
    );
  }
}
