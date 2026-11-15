import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Usuário logado (ou `null`), acompanhando entradas e saídas.
final authUserProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());
