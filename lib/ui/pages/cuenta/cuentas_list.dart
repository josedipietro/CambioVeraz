import 'dart:async';

import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/cuenta/widget/cuenta_tile.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CuentasListPage extends StatefulWidget {
  static String route = '/operaciones/cuentas';

  const CuentasListPage({super.key});

  @override
  State<CuentasListPage> createState() => _CuentasListPageState();
}

class _CuentasListPageState extends State<CuentasListPage> {
  final TextEditingController buscadorController = TextEditingController();
  Moneda? monedaSelected;
  Timer? _debounce;
  List<Cuenta> filteredCuentas = [];
  @override
  Widget build(BuildContext context) {
    print('cuentas list');
    final cuentasProvider = context.watch<CuentasProvider>();
    return buildBody(context, cuentasProvider);
  }

  buildBody(BuildContext context, CuentasProvider cuentasProvider) {
    final cuentasTotales = cuentasProvider;
    final monedasProvider = context.watch<MonedasProvider>();

// Find the Moneda objects with id 0
    final monedasWithId0 = monedasProvider.monedas.where(
      (moneda) => moneda.id == '0',
    );

// If there isn't a Moneda object with id 0, add a new one
    if (monedasWithId0.isEmpty) {
      monedasProvider.monedas.insert(
        0,
        Moneda(
          nombre: 'ALL',
          nombreISO: 'ALL',
          simbolo: 'TODAS LAS MONEDAS',
          id: '0',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => NavigationService.navigateTo(
                      Flurorouter.operacionesRoute),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Cuentas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Row(
            children: [
              buildBuscador(context, cuentasProvider),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 55),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: CustomDropdown<Moneda>(
                    items: monedasProvider.monedas,
                    value: monedasProvider.monedas.firstWhereOrNull(
                        (element) => element.id == monedaSelected?.id),
                    onChange: (value) =>
                        onMonedaSelected(value, cuentasProvider),
                    title: 'Moneda',
                  ),
                ),
              ),
            ],
          ),
          !cuentasProvider.loading
              ? buildList(context, cuentasTotales.cuentas)
              : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  _onSearchChanged(String query, CuentasProvider operacionsProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      operacionsProvider.getCuentasFiltradas(
          monedaSelected != null ? monedaSelected!.id : '', query);
    });
  }

  onMonedaSelected(Moneda? moneda, CuentasProvider cuentas) {
    setState(() {
      if (moneda != null) {
        monedaSelected = moneda;
        cuentas.getCuentasFiltradas(moneda.id, '');
      }
    });
  }

  buildBuscador(BuildContext context, CuentasProvider cuentas) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.47,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: TextField(
            controller: buscadorController,
            maxLength: 30,
            onChanged: ((value) {
              _onSearchChanged(value, cuentas);
            }),
            enableSuggestions: true,
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

  buildList(BuildContext context, List<Cuenta> cuentas) {
    return Expanded(
        child: ListView.builder(
      itemCount: cuentas.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: database.getBalanceCuenta(cuentas[index]),
            initialData: 0.0,
            builder: (context, snapshot) {
              if (cuentas[index].id != '0') {
                return CuentaTile(
                    cuenta: cuentas[index],
                    onRemove: (model) {
                      model.delete();
                    },
                    balance: snapshot.data ?? 0);
              } else {
                return const SizedBox();
              }
            });
      },
    ));
  }
}
