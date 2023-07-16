import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class ClientesProvider extends ChangeNotifier {
  ClientesProvider() {
    getclientes();
  }

  List<Cliente> _clientes = [];

  bool _loading = false;

  List<Cliente> get clientes => _clientes;
  bool get loading => _loading;

  set clientes(List<Cliente> clientes) {
    _clientes = clientes;
    notifyListeners();
  }

  getclientes() async {
    _loading = true;
    notifyListeners();

    database.clientesStream.listen((event) {
      _clientes = event;
      _loading = false;
      notifyListeners();
    });
  }
}
