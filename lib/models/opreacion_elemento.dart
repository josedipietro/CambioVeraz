import 'dart:io';

import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> generarReporteExcel(
      Map<String, List<IngresoEgresos>> cuentasAgrupadas) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Reporte'];

    // Añadir encabezados
    List<CellValue> headers = [
      const TextCellValue('Cuenta Entrante'),
      const TextCellValue('Cuenta Saliente'),
      const TextCellValue('Monto'),
      const TextCellValue('Comision'),
      const TextCellValue('Bono'),
      const TextCellValue('Operacion'),
      const TextCellValue('Tasa'),
      const TextCellValue('Comision Fija')
    ];
    sheetObject.appendRow(headers);

    // Añadir los datos
    cuentasAgrupadas.forEach((cuenta, ingresosEgresosList) {
      for (var ingresoEgreso in ingresosEgresosList) {
        List<CellValue> row = [
          TextCellValue(ingresoEgreso.cuentaEntrante.nombreTitular),
          TextCellValue(ingresoEgreso.cuentaSaliente.nombreTitular),
          DoubleCellValue(ingresoEgreso.monto),
          TextCellValue(ingresoEgreso.comision),
          TextCellValue(ingresoEgreso.bono),
          TextCellValue(ingresoEgreso.operacion ? 'Sí' : 'No'),
          TextCellValue(ingresoEgreso.comisionFija)
        ];
        sheetObject.appendRow(row);
      }
    });

    // Obtener directorio de documentos

    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();

    File('$directory/output_file_name.xlsx')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  }
}
