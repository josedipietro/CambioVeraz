import 'dart:async';

import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/providers/comisiones_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComisionesListPage extends StatefulWidget {
  static String route = '/operaciones';

  const ComisionesListPage({super.key});

  @override
  State<ComisionesListPage> createState() => _ComisionesListPageState();
}

class _ComisionesListPageState extends State<ComisionesListPage> {
  final TextEditingController buscadorController = TextEditingController();
  Timer? _debounce;
  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('operacions list');
    final ingresosEgresosProvider = context.watch<CuentasAgrupadasProvider>();

    return buildBody(context, ingresosEgresosProvider);
  }

  buildBody(BuildContext context, CuentasAgrupadasProvider operacionsProvider) {
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
                  'Comisiones',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          buildBuscador(context, operacionsProvider),
          if (operacionsProvider.operaciones.isNotEmpty)
            !operacionsProvider.loading
                ? buildList(context, operacionsProvider.listTotal)
                : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  _onSearchChanged(String query, CuentasAgrupadasProvider operacionsProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      //operacionsProvider.getoperacionesIE(query);
    });
  }

  buildBuscador(
      BuildContext context, CuentasAgrupadasProvider operacionsProvider) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TextField(
          controller: buscadorController,
          maxLength: 30,
          enableSuggestions: true,
          onChanged: ((value) => {_onSearchChanged(value, operacionsProvider)}),
          decoration: InputDecoration(
            labelText: 'Buscar...',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: const OutlineInputBorder(),
            filled: true,
            hoverColor: Theme.of(context).hoverColor,
          ),
        ));
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
                              (cuenta.monto *
                                      cuenta.cuentaEntrante.comision /
                                      100)
                                  .toString(),
                              style: const TextStyle(color: Colors.green),
                            ),
                          if (!cuenta.operacion)
                            Text(
                              ((int.parse(cuenta.comision) / 100) *
                                          cuenta.monto +
                                      int.parse(cuenta.comisionFija))
                                  .toString(),
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
