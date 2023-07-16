import 'package:cambio_veraz/models/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  String? _token;
  AuthStatus authStatus = AuthStatus.checking;

  AuthProvider() {
    isAuthenticated();
  }

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  User? get currentUser => _userFromFirebase(_firebaseAuth.currentUser);

  User? _userFromFirebase(auth.User? user) {
    if (user == null) {
      authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
      return null;
    }

    authStatus = AuthStatus.authenticated;
    notifyListeners();
    return User(id: user.uid, email: user.email, nombre: user.displayName);
  }

  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_userFromFirebase);

  Future<User?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(credential.user);
  }

  Future<User?> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(credential.user);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    authStatus = AuthStatus.notAuthenticated;
    notifyListeners();

    // NotificationsService.showSnackbar('Debes iniciar sesión');
    // NavigationService.replaceTo(Flurorouter.registerPacientRoute);
  }

  Future<bool> isAuthenticated() async {
    if (currentUser == null) {
      authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
      return false;
    }

    authStatus = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }
}
