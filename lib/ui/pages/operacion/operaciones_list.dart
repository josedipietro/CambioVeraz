import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/providers/OperacionesProvider.dart';
import 'package:cambio_veraz/ui/pages/operacion/widget/operacion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OperacionesListPage extends StatefulWidget {
  static String route = '/operacions';

  const OperacionesListPage({super.key});

  @override
  State<OperacionesListPage> createState() => _OperacionesListPageState();
}

class _OperacionesListPageState extends State<OperacionesListPage> {
  final TextEditingController buscadorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('operacions list');
    final operacionsProvider = context.watch<OperacionesProvider>();

    return buildBody(context, operacionsProvider);
  }

  buildBody(BuildContext context, OperacionesProvider operacionsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Operaciones',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
          buildBuscador(context),
          !operacionsProvider.loading
              ? buildList(context, operacionsProvider.operaciones)
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

  buildList(BuildContext context, List<Operacion> operaciones) {
    return Expanded(
        child: ListView.builder(
      itemCount: operaciones.length,
      itemBuilder: (context, index) => OperacionTile(
        operacion: operaciones[index],
        onRemove: (operacion) {},
      ),
    ));
  }
}
