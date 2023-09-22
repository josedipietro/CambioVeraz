import 'package:cambio_veraz/models/usuario.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class UsuariosProvider extends ChangeNotifier {
  UsuariosProvider() {
    getUsuarios();
  }

  List<Usuario> _usuarios = [];

  bool _loading = false;

  List<Usuario> get usuarios => _usuarios;
  bool get loading => _loading;

  set usuarios(List<Usuario> usuarios) {
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
