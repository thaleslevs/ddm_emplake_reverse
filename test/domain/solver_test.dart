import 'package:emplake/features/game/domain/judge.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:emplake/features/game/domain/token.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _d(String n) => n.split('').map(int.parse).toList();

void main() {
  test('acha solução simples em todos os níveis', () {
    for (final level in Level.values) {
      final s = Solver(level).solve(_d('2203'));
      expect(s, isNotNull, reason: level.name);
    }
  });

  test('toda solução encontrada é aceita pelo judge e usa os dígitos na ordem', () {
    for (final level in Level.values) {
      final solver = Solver(level);
      for (var i = 0; i < 10000; i += 37) {
        final digits = _d(i.toString().padLeft(4, '0'));
        final s = solver.solve(digits);
        if (s == null) continue;
        expect(judge(s.tokens, digits: digits, level: level), isA<Correct>(), reason: '${level.name} $digits ${s.text}');
        expect(
          [for (final t in s.tokens) if (t.kind == TokenKind.digit) t.value],
          digits,
        );
        expect(s.tokens.every((t) => level.allows(t.kind)), isTrue);
      }
    }
  });

  test('1999 não tem solução no difícil, mas tem no avançado', () {
    expect(Solver(Level.hard).isSolvable(_d('1999')), isFalse);
    expect(Solver(Level.advanced).isSolvable(_d('1999')), isTrue);
  });
}
