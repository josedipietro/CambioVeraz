import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/tasa.dart';

class IngresoEgresos {
  Cuenta cuenta;
  double monto;
  String comision;
  bool operacion;
  Tasa tasa;

  IngresoEgresos(
      {required this.cuenta,
      required this.monto,
      required this.comision,
      required this.operacion,
      required this.tasa});

  @override
  String toString() {
    return cuenta.nombreTitular;
  }
}
