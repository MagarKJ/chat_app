import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;

  User? get user => _user;

  AuthServices() {
    _firebaseAuth.authStateChanges().listen(authStateChangesSTreamListner);
  }

  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        _user = userCredential.user;
        return true;
      }
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
    }
    return false;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  void authStateChangesSTreamListner(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}
