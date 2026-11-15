import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/state/solved_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pontuação soma os pontos de cada nível', () {
    expect(
      scoreOf({
        Level.easy: {'1234', '5678'},
        Level.intermediate: {'1111'},
        Level.advanced: const {},
        Level.hard: {'2222', '3333'},
      }),
      2 * 1 + 1 * 2 + 2 * 5,
    );
  });

  test('pontuação acompanha os resolvidos', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(scoreProvider), 0);

    container.read(solvedProvider.notifier)
      ..add(Level.hard, '1999')
      ..add(Level.easy, '2203');
    expect(container.read(scoreProvider), 5 + 1);
    expect(container.read(solvedCountProvider), 2);
  });
}
