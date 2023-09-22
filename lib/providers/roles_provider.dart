import 'package:cambio_veraz/models/rol.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class RolesProvider extends ChangeNotifier {
  RolesProvider() {
    getRoles();
  }

  List<Rol> _roles = [];

  bool _loading = false;

  List<Rol> get roles => _roles;
  bool get loading => _loading;

  set roles(List<Rol> roles) {
    _roles = roles;
    notifyListeners();
  }

  getRoles() async {
    _loading = true;
    notifyListeners();

    _roles = await database.roles;

    _loading = false;
    notifyListeners();
  }
}
