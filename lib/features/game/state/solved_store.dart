import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/level.dart';

/// Números já resolvidos por nível, consultados pelo sorteio.
///
/// Carregado do Firestore ao entrar (veja `GameScreen`) e atualizado a cada
/// acerto, para não precisar ler o banco de novo a cada rodada.
final solvedProvider = NotifierProvider<SolvedStore, Map<Level, Set<String>>>(SolvedStore.new);

class SolvedStore extends Notifier<Map<Level, Set<String>>> {
  @override
  Map<Level, Set<String>> build() => {for (final level in Level.values) level: const <String>{}};

  void seed(Map<Level, Set<String>> solved) => state = {
    for (final level in Level.values) level: Set.unmodifiable(solved[level] ?? const <String>{}),
  };

  void add(Level level, String number) => state = {
    ...state,
    level: Set.unmodifiable({...state[level]!, number}),
  };
}

/// Pontuação do jogador, derivada dos resolvidos ([Level.points] por número).
/// Assim nunca desencontra dos números guardados no Firestore.
final scoreProvider = Provider<int>((ref) => scoreOf(ref.watch(solvedProvider)));

final solvedCountProvider = Provider<int>(
  (ref) => ref.watch(solvedProvider).values.fold(0, (total, numbers) => total + numbers.length),
);

int scoreOf(Map<Level, Set<String>> solved) =>
    solved.entries.fold(0, (total, e) => total + e.key.points * e.value.length);
