import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class CuentasProvider extends ChangeNotifier {
  CuentasProvider() {
    getCuentas();
  }

  List<Cuenta> _cuentas = [];

  bool _loading = false;

  List<Cuenta> get cuentas => _cuentas;
  bool get loading => _loading;

  set cuentas(List<Cuenta> cuentas) {
    _cuentas = cuentas;
    notifyListeners();
  }

  getCuentas() async {
    _loading = true;
    notifyListeners();

    database.cuentasStream.listen((event) async {
      _cuentas = await event;
      _loading = false;
      notifyListeners();
    });
  }

  getCuentasFiltradas(String id, String search) async {
    _loading = true;
    notifyListeners();

    database.getcuentasFiltradas(id, search).listen((event) async {
      _cuentas = await event;
      _loading = false;
      notifyListeners();
    });
  }
}
