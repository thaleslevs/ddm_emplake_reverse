import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'account.dart';
import 'shop_catalog.dart';

/// Compras, itens equipados e apelido do jogador, em `users/{uid}` (o mesmo
/// documento da pontuação).
class AccountRepository {
  AccountRepository(this.user, {FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final User user;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('users').doc(user.uid);

  /// Apelido inicial: o primeiro nome da conta Google, ou "Jogador" com um
  /// pedaço do id (nunca o e-mail, que ficaria público no ranking).
  String get defaultNickname {
    final first = (user.displayName ?? '').trim().split(RegExp(r'\s+')).first;
    final name = first.isNotEmpty ? first : 'Jogador ${user.uid.substring(0, 4).toUpperCase()}';
    return name.length > 20 ? name.substring(0, 20) : name;
  }

  Future<Account> load() async {
    final data = (await _doc.get()).data() ?? const {};
    final equipped = (data['equipped'] as Map?) ?? const {};
    final nickname = data['nickname'];
    return Account(
      spent: (data['spent'] as num?)?.toInt() ?? 0,
      owned: {for (final id in (data['owned'] as List?) ?? const []) id.toString()},
      skinId: equipped['skin']?.toString() ?? 'classic',
      effect: WinEffect.values.asNameMap()[equipped['effect']] ?? WinEffect.clowns,
      nickname: nickname is String && nickname.trim().isNotEmpty ? nickname.trim() : defaultNickname,
    );
  }

  Future<void> buy(ShopItem item) => _doc.set({
    'spent': FieldValue.increment(item.price),
    'owned': FieldValue.arrayUnion([item.id]),
  }, SetOptions(merge: true));

  Future<void> equip(ShopItem item) => _doc.set({
    'equipped': {item.kind == ShopKind.skin ? 'skin' : 'effect': item.key},
  }, SetOptions(merge: true));

  Future<void> rename(String nickname) => _doc.set({'nickname': nickname}, SetOptions(merge: true));
}

final accountRepositoryProvider = Provider<AccountRepository?>((ref) {
  final user = ref.watch(authUserProvider).value ?? FirebaseAuth.instance.currentUser;
  return user == null ? null : AccountRepository(user);
});
