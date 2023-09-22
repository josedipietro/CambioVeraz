import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/providers/operaciones_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/operacion/widget/operacion_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OperacionesListPage extends StatefulWidget {
  static String route = '/operaciones';

  const OperacionesListPage({super.key});

  @override
  State<OperacionesListPage> createState() => _OperacionesListPageState();
}

class _OperacionesListPageState extends State<OperacionesListPage> {
  final TextEditingController buscadorController = TextEditingController();

  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

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
        onRemove: (model) {
          model.delete();
        },
      ),
    ));
  }
}
