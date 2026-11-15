// Teste local do Solver.
//
//   dart run tool/solvability.dart            -> varre 0000..9999 em todos os níveis
//   dart run tool/solvability.dart 2203 1999  -> mostra uma solução para cada número
// ignore_for_file: avoid_print
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solver.dart';

void main(List<String> args) {
  final numbers = args.where((a) => RegExp(r'^\d{4}$').hasMatch(a)).toList();
  if (numbers.isNotEmpty) {
    _explain(numbers);
  } else {
    _sweep();
  }
}

List<int> _digits(String n) => n.split('').map(int.parse).toList();

void _explain(List<String> numbers) {
  final solvers = {for (final l in Level.values) l: Solver(l)};
  for (final n in numbers) {
    print('== $n ==');
    for (final level in Level.values) {
      final s = solvers[level]!.solve(_digits(n));
      print('  ${level.name.padRight(12)} ${s?.text ?? '(sem solução encontrada)'}');
    }
  }
}

void _sweep() {
  for (final level in Level.values) {
    final solver = Solver(level);
    final watch = Stopwatch()..start();
    final unsolved = <String>[];
    for (var i = 0; i < 10000; i++) {
      final n = i.toString().padLeft(4, '0');
      if (!solver.isSolvable(_digits(n))) unsolved.add(n);
    }
    watch.stop();
    final solved = 10000 - unsolved.length;
    print('${level.name.padRight(12)} $solved/10000 com solução '
        '(${(solved / 100).toStringAsFixed(1)}%) em ${watch.elapsedMilliseconds} ms');
    if (unsolved.isNotEmpty) {
      final preview = unsolved.take(40).join(' ');
      print('  sem solução (${unsolved.length}): $preview${unsolved.length > 40 ? ' ...' : ''}');
    }
  }
}
