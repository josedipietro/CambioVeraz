import 'package:cambio_veraz/models/usuario.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus authStatus = AuthStatus.checking;

  Usuario? _usuario;

  AuthProvider() {
    isAuthenticated();
  }

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  Usuario? get currentUser => _userFromFirebase(_firebaseAuth.currentUser);
  Usuario? get usuario => _usuario;

  Usuario? _userFromFirebase(auth.User? user) {
    if (user == null) {
      authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
      return null;
    }

    authStatus = AuthStatus.authenticated;

    getUsuario(user.uid);

    notifyListeners();
    return Usuario(id: user.uid, email: user.email!, nombre: user.displayName);
  }

  getUsuario(String id) async {
    final user = await database.getUsuarioById(id);

    _usuario = user;
  }

  Stream<Usuario?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_userFromFirebase);

  Future<Usuario?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(credential.user);
  }

  Future<Usuario?> createUserWithEmailAndPassword(
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
