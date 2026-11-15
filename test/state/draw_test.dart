import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:emplake/features/game/state/game_controller.dart';
import 'package:emplake/features/game/state/solved_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('não sorteia números já resolvidos no nível', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Metade dos números (0000-4999) já resolvida no Fácil.
    final solved = {for (var i = 0; i < 5000; i++) i.toString().padLeft(4, '0')};
    container.read(solvedProvider.notifier).seed({Level.easy: solved});

    final provider = gameControllerProvider(Level.easy);
    for (var i = 0; i < 200; i++) {
      final number = container.read(provider).number;
      expect(solved.contains(number), isFalse, reason: number);
      container.read(provider.notifier).skip();
    }
  });

  test('todo número sorteado tem solução no nível', () {
    for (final level in Level.values) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final solver = Solver(level);
      final provider = gameControllerProvider(level);
      for (var i = 0; i < 100; i++) {
        final digits = container.read(provider).digits;
        expect(solver.isSolvable(digits), isTrue, reason: '${level.name} ${digits.join()}');
        container.read(provider.notifier).skip();
      }
    }
  });
}
