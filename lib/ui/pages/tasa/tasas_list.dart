import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/providers/tasas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/tasa/widgets/tasa_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasasListPage extends StatefulWidget {
  static String route = '/tasas';

  const TasasListPage({super.key});

  @override
  State<TasasListPage> createState() => _TasasListPageState();
}

class _TasasListPageState extends State<TasasListPage> {
  final TextEditingController buscadorController = TextEditingController();

  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('tasas list');
    final tasasProvider = context.watch<TasasProvider>();

    return buildBody(context, tasasProvider);
  }

  buildBody(BuildContext context, TasasProvider tasasProvider) {
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
                  'Tasas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                  onPressed: () {
                    navigateTo(Flurorouter.monedasRoute);
                  },
                  icon: const Icon(
                    Icons.payments_rounded,
                    size: 32,
                  ))
            ],
          ),
          buildBuscador(context),
          !tasasProvider.loading
              ? buildList(context, tasasProvider.tasas)
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

  buildList(BuildContext context, List<Tasa> tasas) {
    return Expanded(
        child: ListView.builder(
      itemCount: tasas.length,
      itemBuilder: (context, index) => TasaTile(
        tasa: tasas[index],
        onRemove: (model) {
          model.delete();
        },
      ),
    ));
  }
}
