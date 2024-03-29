import 'dart:async';

import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/providers/clientes_provider.dart';
import 'package:cambio_veraz/ui/pages/cliente/widget/cliente_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientesListPage extends StatefulWidget {
  static String route = '/clientes';

  const ClientesListPage({super.key});

  @override
  State<ClientesListPage> createState() => _ClientesListPageState();
}

class _ClientesListPageState extends State<ClientesListPage> {
  final TextEditingController buscadorController = TextEditingController();
  Timer? _debounce;
  @override
  Widget build(BuildContext context) {
    print('clientes list');
    final clientesProvider = context.watch<ClientesProvider>();

    return buildBody(context, clientesProvider);
  }

  _onSearchChanged(String query, ClientesProvider clientesProvider) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      clientesProvider.getclientes(query);
    });
  }

  buildBody(BuildContext context, ClientesProvider clientesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Clientes',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
          buildBuscador(context, clientesProvider),
          !clientesProvider.loading
              ? buildList(context, clientesProvider.clientes)
              : const Center(child: CupertinoActivityIndicator()),
        ],
      ),
    );
  }

  buildBuscador(BuildContext context, ClientesProvider clientesProvider) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TextField(
          controller: buscadorController,
          maxLength: 30,
          enableSuggestions: true,
          onChanged: (value) => {_onSearchChanged(value, clientesProvider)},
          decoration: InputDecoration(
            labelText: 'Buscar...',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: const OutlineInputBorder(),
            filled: true,
            hoverColor: Theme.of(context).hoverColor,
          ),
        ));
  }

  buildList(BuildContext context, List<Cliente> clientes) {
    return Expanded(
        child: ListView.builder(
      itemCount: clientes.length,
      itemBuilder: (context, index) => ClienteTile(
        cliente: clientes[index],
        onRemove: (model) {
          model.delete();
        },
      ),
    ));
  }
}
