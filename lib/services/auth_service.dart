// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}