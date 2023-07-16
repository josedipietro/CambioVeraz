import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class MonedasProvider with ChangeNotifier {
  MonedasProvider() {
    getMonedas();
  }

  List<Moneda> _monedas = [];

  bool _loading = false;

  List<Moneda> get monedas => _monedas;
  bool get loading => _loading;

  set monedas(List<Moneda> monedas) {
    _monedas = monedas;
    notifyListeners();
  }

  getMonedas() {
    _loading = true;
    notifyListeners();

    database.monedasStream.listen((event) {
      _monedas = event;
      _loading = false;
      notifyListeners();
    });
  }
}
