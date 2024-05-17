import 'dart:async';

import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/providers/ingresos_egresos.dart';
import 'package:cambio_veraz/providers/operaciones_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/ingresos_egresos/widget/ingresos_egresos_tile.dart';
import 'package:cambio_veraz/ui/pages/operacion/widget/operacion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IngresosEgresosListPage extends StatefulWidget {
  static String route = '/operaciones';

  const IngresosEgresosListPage({super.key});

  @override
  State<IngresosEgresosListPage> createState() =>
      _IngresosEgresosListPageState();
}

class _IngresosEgresosListPageState extends State<IngresosEgresosListPage> {
  final TextEditingController buscadorController = TextEditingController();
  Timer? _debounce;
  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('operacions list');
    final ingresosEgresosProvider = context.watch<IngresosEgresosProvider>();

    return buildBody(context, ingresosEgresosProvider);
  }

  buildBody(BuildContext context, IngresosEgresosProvider operacionsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ingresos y Egresos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      tooltip: 'Movimiento de cuentas',
                      onPressed: () {
                        navigateTo(Flurorouter.reporteDeMovimientos);
                      },
                      icon: const Icon(
                        Icons.summarize,
                        size: 32,
                      )),
                ],
              )
            ],
          ),
          buildBuscador(context, operacionsProvider),
          !operacionsProvider.loading
              ? buildList(context, operacionsProvider.getIngresosEgresos())
              : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  _onSearchChanged(String query, IngresosEgresosProvider operacionsProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      operacionsProvider.getoperacionesIE(query);
    });
  }

  buildBuscador(
      BuildContext context, IngresosEgresosProvider operacionsProvider) {
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

  buildList(BuildContext context, List<IngresoEgresos> operaciones) {
    return Expanded(
        child: ListView.builder(
      itemCount: operaciones.length,
      itemBuilder: (context, index) => IngresosEgresosTile(
        operacion: operaciones[index],
        onRemove: (model) {
          model.delete();
        },
      ),
    ));
  }
}
