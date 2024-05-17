import 'dart:async';
import 'dart:io';

import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/providers/movimientos_cuentas.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class MovimientosCuentasListPage extends StatefulWidget {
  static String route = '/movimientos';

  const MovimientosCuentasListPage({super.key});

  @override
  State<MovimientosCuentasListPage> createState() =>
      _MovimientosCuentasListPageState();
}

class _MovimientosCuentasListPageState
    extends State<MovimientosCuentasListPage> {
  final TextEditingController buscadorController = TextEditingController();
  Timer? _debounce;
  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('operacions list');
    final ingresosEgresosProvider = context.watch<MovimientosCuentasProvider>();

    return buildBody(context, ingresosEgresosProvider);
  }

  buildBody(
      BuildContext context, MovimientosCuentasProvider operacionsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Reporte de movimientos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Row(
            children: [
              buildBuscador(context, operacionsProvider),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.08,
                child: !operacionsProvider.loading
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: IconButton(
                          onPressed: () {
                            generarReporteExcel(operacionsProvider.listTotal);
                          },
                          icon: const Icon(Icons.download),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
              )
            ],
          ),
          if (operacionsProvider.operaciones.isNotEmpty)
            !operacionsProvider.loading
                ? buildList(context, operacionsProvider.listTotal)
                : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  _onSearchChanged(
      String query, MovimientosCuentasProvider operacionsProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      //operacionsProvider.getoperacionesIE(query);
    });
  }

  buildBuscador(
      BuildContext context, MovimientosCuentasProvider operacionsProvider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: TextField(
            controller: buscadorController,
            maxLength: 30,
            enableSuggestions: true,
            onChanged: ((value) =>
                {_onSearchChanged(value, operacionsProvider)}),
            decoration: InputDecoration(
              labelText: 'Buscar...',
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              border: const OutlineInputBorder(),
              filled: true,
              hoverColor: Theme.of(context).hoverColor,
            ),
          )),
    );
  }

  double calcularDinero(
      double monto, String comision, String bono, String comisionFija) {
    return (monto * (double.parse(comision) ?? 0.0) / 100 +
        monto +
        double.parse(comisionFija) -
        double.parse(bono));
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

  Widget buildList(BuildContext context,
      Map<String, List<IngresoEgresos>> cuentasAgrupadas) {
    return Expanded(
      child: ListView.builder(
        itemCount: cuentasAgrupadas.keys.length, // Número de claves en el mapa
        itemBuilder: (context, index) {
          String key = cuentasAgrupadas.keys.elementAt(index);
          List<IngresoEgresos> cuentas = cuentasAgrupadas[key]!;

          return ExpansionTile(
            title: Text('Cuenta: $key'),
            subtitle: Text('Numero de transacciones: ${cuentas.length}'),
            children: cuentas
                .map((cuenta) => ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cuenta.operacion)
                            Text(
                              '${cuenta.cuentaEntrante.moneda.simbolo}${calcularDinero(cuenta.monto, cuenta.comision, cuenta.bono, cuenta.comisionFija).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          if (!cuenta.operacion)
                            Text(
                              '${cuenta.cuentaEntrante.moneda.simbolo}${(cuenta.monto + (int.parse(cuenta.comision) / 100) * cuenta.monto + int.parse(cuenta.comisionFija)).toString()}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ), // Asumiendo que 'nombre' es un campo de 'Cuenta'
                      subtitle: const Text(
                          'Detalles adicionales aquí'), // Puedes añadir más información de cada cuenta
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
