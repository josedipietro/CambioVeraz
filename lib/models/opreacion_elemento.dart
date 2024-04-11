import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/tasa.dart';

class IngresoEgresos {
  Cuenta cuenta;
  double monto;
  String comision;
  String bono;
  bool operacion;
  Tasa tasa;
  String comisionFija;

  IngresoEgresos(
      {required this.cuenta,
      required this.monto,
      required this.bono,
      required this.comision,
      required this.operacion,
      required this.comisionFija,
      required this.tasa});

  @override
  String toString() {
    return cuenta.nombreTitular;
  }
}
