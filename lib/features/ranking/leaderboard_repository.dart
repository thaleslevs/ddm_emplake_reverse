import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';

/// Uma linha do ranking.
class LeaderboardEntry {
  const LeaderboardEntry({required this.uid, required this.name, required this.points});

  final String uid;
  final String name;
  final int points;
}

/// Ranking geral em `leaderboard/{uid}`: apelido e **total de pontos já
/// ganhos** (gastar na loja não tira ninguém do lugar). Qualquer jogador
/// logado lê; cada um só escreve o próprio registro (veja `firestore.rules`).
class LeaderboardRepository {
  LeaderboardRepository(this.uid, {FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _board => _db.collection('leaderboard');

  /// Grava o total e o apelido atuais (ao entrar e ao trocar de apelido).
  Future<void> sync({required int points, required String name}) =>
      _board.doc(uid).set({'name': name, 'points': points, 'updatedAt': FieldValue.serverTimestamp()});

  /// Soma pontos de um acerto.
  Future<void> addPoints(int points) => _board.doc(uid).set({
    'points': FieldValue.increment(points),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<List<LeaderboardEntry>> top({int limit = 50}) async {
    final snapshot = await _board.orderBy('points', descending: true).limit(limit).get();
    return [
      for (final doc in snapshot.docs)
        LeaderboardEntry(
          uid: doc.id,
          name: doc.data()['name']?.toString() ?? '?',
          points: (doc.data()['points'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// Posição de quem tem [points] (1 = primeiro), contando quantos têm mais.
  Future<int> positionOf(int points) async {
    final ahead = await _board.where('points', isGreaterThan: points).count().get();
    return (ahead.count ?? 0) + 1;
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository?>((ref) {
  final user = ref.watch(authUserProvider).value ?? FirebaseAuth.instance.currentUser;
  return user == null ? null : LeaderboardRepository(user.uid);
});
