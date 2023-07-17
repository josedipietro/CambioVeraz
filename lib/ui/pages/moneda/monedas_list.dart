import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/moneda/widget/moneda_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonedasListPage extends StatefulWidget {
  static String route = '/tasas/monedas';

  const MonedasListPage({super.key});

  @override
  State<MonedasListPage> createState() => _MonedasListPageState();
}

class _MonedasListPageState extends State<MonedasListPage> {
  final TextEditingController buscadorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('monedas list');
    final monedasProvider = context.watch<MonedasProvider>();

    return buildBody(context, monedasProvider);
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Monedas'),
    );
  }

  buildBody(BuildContext context, MonedasProvider monedasProvider) {
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
                  onPressed: () =>
                      NavigationService.navigateTo(Flurorouter.tasasRoute),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Monedas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          buildBuscador(context),
          !monedasProvider.loading
              ? buildList(context, monedasProvider.monedas)
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

  buildList(BuildContext context, List<Moneda> monedas) {
    return Expanded(
        child: ListView.builder(
      itemCount: monedas.length,
      itemBuilder: (context, index) => MonedaTile(
        moneda: monedas[index],
        onRemove: (moneda) {},
      ),
    ));
  }
}
