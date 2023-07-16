import 'package:cambio_veraz/models/user.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class UsuariosProvider extends ChangeNotifier {
  UsuariosProvider() {
    getUsuarios();
  }

  List<User> _usuarios = [];

  bool _loading = false;

  List<User> get usuarios => _usuarios;
  bool get loading => _loading;

  set usuarios(List<User> usuarios) {
    _usuarios = usuarios;
    notifyListeners();
  }

  getUsuarios() async {
    _loading = true;
    notifyListeners();

    _usuarios = await database.usuarios;

    _loading = false;
    notifyListeners();
  }
}
