import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/providers/depositos_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/deposito/widget/deposito_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepositosListPage extends StatefulWidget {
  static String route = '/depositos';

  const DepositosListPage({super.key});

  @override
  State<DepositosListPage> createState() => _DepositosListPageState();
}

class _DepositosListPageState extends State<DepositosListPage> {
  final TextEditingController buscadorController = TextEditingController();

  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('depositos list');
    final depositosProvider = context.watch<DepositosProvider>();

    return buildBody(context, depositosProvider);
  }

  buildBody(BuildContext context, DepositosProvider depositosProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  'Depositos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
          buildBuscador(context),
          !depositosProvider.loading
              ? buildList(context, depositosProvider.depositos)
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

  buildList(BuildContext context, List<Deposito> depositos) {
    return Expanded(
        child: ListView.builder(
      itemCount: depositos.length,
      itemBuilder: (context, index) => DepositoTile(
        deposito: depositos[index],
        onRemove: (deposito) {},
      ),
    ));
  }
}
