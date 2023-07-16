import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/ui/pages/cuenta/widget/cuenta_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    print('cuentas list');
    final cuentasProvider = context.watch<CuentasProvider>();

    return buildBody(context, cuentasProvider);
  }

  buildBody(BuildContext context, CuentasProvider cuentasProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Cuentas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
          buildBuscador(context),
          !cuentasProvider.loading
              ? buildList(context, cuentasProvider.cuentas)
              : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  buildBuscador(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TextField(
          controller: buscadorController,
          maxLength: 30,
          enableSuggestions: true,
          decoration: InputDecoration(
            labelText: 'Buscar...',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: const OutlineInputBorder(),
            filled: true,
            hoverColor: Theme.of(context).hoverColor,
          ),
        ));
  }

  buildList(BuildContext context, List<Cuenta> cuentas) {
    return Expanded(
        child: ListView.builder(
      itemCount: cuentas.length,
      itemBuilder: (context, index) => CuentaTile(
        cuenta: cuentas[index],
        onRemove: (moneda) {},
      ),
    ));
  }
}
