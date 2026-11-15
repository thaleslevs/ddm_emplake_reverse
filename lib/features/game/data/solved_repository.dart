import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_providers.dart';
import '../domain/level.dart';
import '../state/solved_store.dart';

/// Números resolvidos de um jogador no Firestore, separados por nível:
/// `users/{uid}/solved/{nivel}_{numero}`.
///
/// O mesmo número resolvido no Fácil não conta como resolvido no Difícil,
/// porque com menos operadores é outro desafio.
class SolvedRepository {
  SolvedRepository(this.uid, {FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _solved => _db.collection('users').doc(uid).collection('solved');

  Future<Map<Level, Set<String>>> loadAll() async {
    final snapshot = await _solved.get();
    final byLevel = {for (final level in Level.values) level: <String>{}};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final level = Level.values.asNameMap()[data['level']];
      final number = data['number'];
      if (level != null && number is String) byLevel[level]!.add(number);
    }
    return byLevel;
  }

  /// Os resolvidos mais recentes primeiro.
  Future<List<SolvedEntry>> history({int limit = 100}) async {
    final snapshot = await _solved.orderBy('solvedAt', descending: true).limit(limit).get();
    return [for (final doc in snapshot.docs) ?SolvedEntry.fromData(doc.data())];
  }

  DocumentReference<Map<String, dynamic>> get _profile => _db.collection('users').doc(uid);

  /// Guarda o número resolvido e soma os pontos do nível na pontuação do
  /// jogador (`users/{uid}`: `score` e `solvedCount`), juntos num lote só.
  Future<void> markSolved(Level level, String number, {required String latex}) {
    return (_db.batch()
          ..set(_solved.doc('${level.name}_$number'), {
            'level': level.name,
            'number': number,
            'latex': latex,
            'solvedAt': FieldValue.serverTimestamp(),
          })
          ..set(_profile, {
            'score': FieldValue.increment(level.points),
            'solvedCount': FieldValue.increment(1),
          }, SetOptions(merge: true)))
        .commit();
  }

  /// Regrava a pontuação a partir dos resolvidos (a fonte da verdade). Feito ao
  /// entrar, corrige contas antigas ou uma gravação que tenha falhado.
  Future<void> syncScore(Map<Level, Set<String>> solved) => _profile.set({
    'score': scoreOf(solved),
    'solvedCount': solved.values.fold(0, (total, numbers) => total + numbers.length),
  }, SetOptions(merge: true));
}

/// Um número resolvido, como aparece no histórico.
class SolvedEntry {
  const SolvedEntry({required this.level, required this.number, required this.latex, this.solvedAt});

  final Level level;
  final String number;
  final String latex;
  final DateTime? solvedAt;

  static SolvedEntry? fromData(Map<String, dynamic> data) {
    final level = Level.values.asNameMap()[data['level']];
    final number = data['number'];
    final latex = data['latex'];
    if (level == null || number is! String || latex is! String) return null;
    final at = data['solvedAt'];
    return SolvedEntry(level: level, number: number, latex: latex, solvedAt: at is Timestamp ? at.toDate() : null);
  }
}

/// Repositório do jogador logado, ou `null` sem login.
final solvedRepositoryProvider = Provider<SolvedRepository?>((ref) {
  // `currentUser` cobre o começo, antes do stream emitir o primeiro valor.
  final user = ref.watch(authUserProvider).value ?? FirebaseAuth.instance.currentUser;
  return user == null ? null : SolvedRepository(user.uid);
});
