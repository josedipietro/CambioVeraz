import 'package:cambio_veraz/models/usuario.dart';
import 'package:cambio_veraz/providers/usuarios_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/usuario/widgets/usuario_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsuariosListPage extends StatefulWidget {
  static String route = '/usuarios';

  const UsuariosListPage({super.key});

  @override
  State<UsuariosListPage> createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListPage> {
  final TextEditingController buscadorController = TextEditingController();

  navigateTo(String route) {
    NavigationService.navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    print('usuarios list');
    final usuariosProvider = context.watch<UsuariosProvider>();

    return buildBody(context, usuariosProvider);
  }

  buildBody(BuildContext context, UsuariosProvider usuariosProvider) {
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
                  'Usuarios',
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
          !usuariosProvider.loading
              ? buildList(context, usuariosProvider.usuarios)
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

  buildList(BuildContext context, List<Usuario> usuarios) {
    return Expanded(
        child: ListView.builder(
      itemCount: usuarios.length,
      itemBuilder: (context, index) => UsuarioTile(
        usuario: usuarios[index],
        onRemove: (usuario) {},
      ),
    ));
  }
}
