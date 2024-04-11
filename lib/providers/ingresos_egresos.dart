import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class IngresosEgresosProvider extends ChangeNotifier {
  IngresosEgresosProvider() {
    getoperacionesIE('');
  }

  List<Operacion> _operaciones = [];

  bool _loading = false;

  List<Operacion> get operaciones => _operaciones;
  bool get loading => _loading;

  set operaciones(List<Operacion> operaciones) {
    _operaciones = operaciones;
    notifyListeners();
  }

  List<IngresoEgresos> combinarOperacionesMovimientos(
      List<Operacion> operaciones) {
    List<IngresoEgresos> resultado = [];

    // Combinar operaciones y movimientos en una sola lista
    for (var operacion in operaciones) {
      resultado.add(IngresoEgresos(
          cuenta: operacion.cuentaEntrante,
          monto: operacion.monto,
          comision: '0',
          tasa: operacion.tasa,
          operacion: true,
          comisionFija: '0',
          bono: '0'));
      for (var movimiento in operacion.movimimentos) {
        resultado.add(IngresoEgresos(
          bono: movimiento.bono.text,
          tasa: operacion.tasa,
          cuenta: movimiento.cuentaSaliente!,
          monto: double.parse(movimiento.monto.text),
          comisionFija: movimiento.comisionFija.text,
          comision: movimiento
              .comision.text, // Asumiendo que no hay tasa en movimientos
          operacion: false,
        ));
      }
    }

    return resultado;
  }

  List<IngresoEgresos> getIngresosEgresos() {
    return combinarOperacionesMovimientos(_operaciones);
  }

  getoperacionesIE(String search) async {
    _loading = true;
    notifyListeners();

    database.getoperacionesIEStream(search).listen((event) async {
      _operaciones = await event;
      _loading = false;
      notifyListeners();
    });
  }
}
