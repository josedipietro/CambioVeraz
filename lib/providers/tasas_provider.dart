import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class TasasProvider extends ChangeNotifier {
  TasasProvider() {
    getTasas('');
  }

  List<Tasa> _tasas = [];

  bool _loading = false;

  List<Tasa> get tasas => _tasas;
  bool get loading => _loading;

  set tasas(List<Tasa> tasas) {
    _tasas = tasas;
    notifyListeners();
  }

  getTasas(String search) async {
    _loading = true;
    notifyListeners();

    database.gettasasStream(search).listen((event) async {
      _tasas = await event;
      _loading = false;
      notifyListeners();
    });
  }
}
