import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/shared/app_bar.dart';
import 'package:cambio_veraz/ui/shared/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagesLayout extends StatefulWidget {
  final Widget child;

  const PagesLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<PagesLayout> createState() => _PagesLayoutState();
}

class _PagesLayoutState extends State<PagesLayout> {
  floatingActionButtonHandler(currentPage) {
    print('floatingActionButtonHandler');
    switch (currentPage) {
      case Flurorouter.tasasRoute:
        return FloatingActionButton(
            onPressed: () =>
                NavigationService.navigateTo(Flurorouter.agregarTasaRoute),
            child: const Icon(Icons.add));
      case Flurorouter.operacionesRoute:
        return FloatingActionButton(
            onPressed: () => NavigationService.navigateTo(
                Flurorouter.agregarOperacioneRoute),
            child: const Icon(Icons.add));
      case Flurorouter.clientesRoute:
        return FloatingActionButton(
            onPressed: () =>
                NavigationService.navigateTo(Flurorouter.agregarClienteRoute),
            child: const Icon(Icons.add));
      /* case UsuariosListPage:
        NavigationService.navigateTo();
        break; */
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pagesProvider = context.watch<PagesProvider>();

    return Scaffold(
        backgroundColor: const Color(0xffEDF1F2),
        appBar: CustomAppBar(onSignOut: authProvider.signOut),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        floatingActionButton:
            floatingActionButtonHandler(pagesProvider.currentPage),
        body: widget.child);
  }
}
