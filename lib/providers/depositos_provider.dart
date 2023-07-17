import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class DepositosProvider extends ChangeNotifier {
  DepositosProvider() {
    getDepositos();
  }

  List<Deposito> _depositos = [];

  bool _loading = false;

  List<Deposito> get depositos => _depositos;
  bool get loading => _loading;

  set depositos(List<Deposito> depositos) {
    _depositos = depositos;
    notifyListeners();
  }

  getDepositos() async {
    _loading = true;
    notifyListeners();

    database.arcasStream.listen((event) async {
      _depositos = await event;
      _loading = false;
      notifyListeners();
    });
  }
}
