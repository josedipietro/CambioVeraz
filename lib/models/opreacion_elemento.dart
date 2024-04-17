import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/tasa.dart';

class IngresoEgresos {
  Cuenta cuentaEntrante;
  Cuenta cuentaSaliente;
  double monto;
  String comision;
  String bono;
  bool operacion;
  Tasa tasa;
  String comisionFija;

  IngresoEgresos(
      {required this.cuentaEntrante,
      required this.monto,
      required this.cuentaSaliente,
      required this.bono,
      required this.comision,
      required this.operacion,
      required this.comisionFija,
      required this.tasa});

  @override
  String toString() {
    return cuentaSaliente.nombreTitular;
  }
}
