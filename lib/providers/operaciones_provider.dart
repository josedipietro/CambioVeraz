import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class OperacionesProvider extends ChangeNotifier {
  OperacionesProvider() {
    getoperaciones('', DateTime.now(), '');
  }

  List<Operacion> _operaciones = [];

  bool _loading = false;

  List<Operacion> get operaciones => _operaciones;
  bool get loading => _loading;

  set operaciones(List<Operacion> operaciones) {
    _operaciones = operaciones;
    notifyListeners();
  }

  getoperaciones(String search, DateTime dateNow, String id) async {
    _loading = true;
    notifyListeners();

    database.getoperacionesStream(search, dateNow, id).listen((event) async {
      _operaciones = await event;
      _loading = false;
      notifyListeners();
    });
  }
}
