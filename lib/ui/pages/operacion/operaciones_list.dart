import 'dart:async';

import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/operaciones_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/operacion/widget/operacion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OperacionesListPage extends StatefulWidget {
  static String route = '/operaciones';

  const OperacionesListPage({super.key});

  @override
  State<OperacionesListPage> createState() => _OperacionesListPageState();
}

class _OperacionesListPageState extends State<OperacionesListPage> {
  final TextEditingController buscadorController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  DateTime _selectedDate = DateTime.now();
  String _text = '';
  String _idCuenta = '';
  Timer? _debounce;
  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('operacions list');
    final operacionsProvider = context.watch<OperacionesProvider>();
    final cuentasProvider = context.watch<CuentasProvider>();
    return buildBody(context, operacionsProvider, cuentasProvider);
  }

  buildBody(BuildContext context, OperacionesProvider operacionsProvider,
      CuentasProvider cuentasProvider) {
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
                  'Operaciones',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  IconButton(
                      tooltip: 'Depositos',
                      onPressed: () {
                        navigateTo(Flurorouter.depositosRoute);
                      },
                      icon: const Icon(
                        Icons.collections_bookmark,
                        size: 32,
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                      tooltip: 'Cuentas',
                      onPressed: () {
                        navigateTo(Flurorouter.cuentasRoute);
                      },
                      icon: const Icon(
                        Icons.account_balance_rounded,
                        size: 32,
                      )),
                ],
              )
            ],
          ),
          !cuentasProvider.loading
              ? buildBuscador(
                  context, operacionsProvider, cuentasProvider.cuentas)
              : const Center(child: CupertinoActivityIndicator()),
          !operacionsProvider.loading
              ? buildList(context, operacionsProvider.operaciones)
              : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  _onSearchChanged(String query, OperacionesProvider operacionsProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      operacionsProvider.getoperaciones(query, _selectedDate, _idCuenta);
    });
  }

  buildBuscador(BuildContext context, OperacionesProvider operacionsProvider,
      List<Cuenta> cuentasProvider) {
    final allOptionExists =
        cuentasProvider.any((cuenta) => cuenta.nombre == 'ALL');
    if (!allOptionExists) {
      final selectOption = Cuenta(
          nombre: 'ALL',
          preferencia: true,
          nombreTitular: '',
          moneda: Moneda(nombre: '', nombreISO: '', simbolo: ''),
          numeroCuenta: '',
          numeroIdentificacion: '',
          id: '');
      cuentasProvider.insert(0, selectOption);
    }
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.32,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: TextField(
                controller: buscadorController,
                maxLength: 30,
                enableSuggestions: true,
                onChanged: ((value) {
                  _onSearchChanged(value, operacionsProvider);
                  _text = value;
                }),
                decoration: InputDecoration(
                  labelText: 'Buscar...',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  border: const OutlineInputBorder(),
                  filled: true,
                  hoverColor: Theme.of(context).hoverColor,
                ),
              )),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.01,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 21),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.32,
            child: TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Select date',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: const OutlineInputBorder(),
                filled: true,
                hoverColor: Theme.of(context).hoverColor,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _showDatePicker(context, operacionsProvider),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.01,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 21),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.32,
            child: DropdownButtonFormField<Cuenta>(
              value: null, // Set the initial value
              decoration: InputDecoration(
                labelText: 'Select',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: const OutlineInputBorder(),
                filled: true,
                hoverColor: Theme.of(context).hoverColor,
              ),
              items: cuentasProvider.map((Cuenta cuenta) {
                return DropdownMenuItem<Cuenta>(
                  value: cuenta,
                  child: Text(cuenta
                      .nombre), // Replace 'name' with the appropriate property of the 'Cuenta' class
                );
              }).toList(),
              onChanged: (Cuenta? value) {
                _idCuenta = value!.id;
                _onSearchChanged(_text, operacionsProvider);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, OperacionesProvider operacionsProvider) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        _onSearchChanged(_text, operacionsProvider);
      });
    }
  }

  buildList(BuildContext context, List<Operacion> operaciones) {
    return Expanded(
        child: ListView.builder(
      itemCount: operaciones.length,
      itemBuilder: (context, index) => OperacionTile(
        operacion: operaciones[index],
        onRemove: (model) {
          model.delete();
        },
      ),
    ));
  }
}
