import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class CuentasAgrupadasProvider extends ChangeNotifier {
  CuentasAgrupadasProvider() {
    getCuentas();
  }

  List<Operacion> _operaciones = [];
  Map<String, List<IngresoEgresos>> _listTotal = {};
  bool _loading = false;

  List<Operacion> get operaciones => _operaciones;
  bool get loading => _loading;
  Map<String, List<IngresoEgresos>> get listTotal => _listTotal;

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
          cuentaEntrante: operacion.cuentaSaliente,
          cuentaSaliente: operacion.cuentaSaliente,
          monto: (operacion.monto * operacion.tasa.tasa),
          comision: '0',
          tasa: operacion.tasa,
          operacion: true,
          comisionFija: '0',
          bono: '0'));
      for (var movimiento in operacion.movimimentos) {
        resultado.add(IngresoEgresos(
          bono: movimiento.bono.text,
          tasa: operacion.tasa,
          cuentaSaliente: movimiento.cuentaSaliente!,
          cuentaEntrante: movimiento.cuentaEntrante!,
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

  void totalList() {
    List<IngresoEgresos> ingresosEgresos =
        combinarOperacionesMovimientos(_operaciones);

    final filteredIngresosEgresos = ingresosEgresos
        .where((ie) => ie.cuentaEntrante.comision != 0 || !ie.operacion)
        .toList();

    final groupedIngresosEgresos = groupBy(filteredIngresosEgresos,
        (IngresoEgresos ie) => ie.cuentaSaliente.nombreTitular);

    _listTotal = groupedIngresosEgresos;
  }

  Map<K, List<T>> groupBy<T, K>(List<T> list, K Function(T) key) {
    final map = <K, List<T>>{};
    for (final element in list) {
      final k = key(element);
      if (map.containsKey(k)) {
        map[k]!.add(element);
      } else {
        map[k] = [element];
      }
    }
    return map;
  }

  List<IngresoEgresos> getIngresosEgresos() {
    return combinarOperacionesMovimientos(_operaciones);
  }

  getCuentas() async {
    _loading = true;
    notifyListeners();

    // Asumiendo que cuentasAgrupadasPorIdTwo ya devuelve un Map<String, List<Cuenta>>
    database.getoperacionesIEStream('').listen((event) async {
      _operaciones = await event;
      _loading = false;
      notifyListeners();
      totalList();
    });
  }

  // getCuentasFiltradas(String id, String search) async {
  //   _loading = true;
  //   notifyListeners();

  //   // Asumiendo que getcuentasFiltradasGrupBy ya devuelve un Map<String, List<Cuenta>>
  //   database.getcuentasFiltradasGrupBy(id, search).listen((event) async {
  //     _cuentasAgrupadas = await event;
  //     _loading = false;
  //     notifyListeners();
  //   });
  // }
}
