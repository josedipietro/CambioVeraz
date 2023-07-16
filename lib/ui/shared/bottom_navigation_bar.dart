import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/cliente/clientes_list.dart';
import 'package:cambio_veraz/ui/pages/operacion/operaciones_list.dart';
import 'package:cambio_veraz/ui/pages/tasa/tasas_list.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedPageIndex = 2;

  void navigateTo(String routeName) {
    NavigationService.navigateTo(routeName);
  }

  currentPageToIndex(String currentPage) {
    switch (currentPage) {
      case Flurorouter.tasasRoute:
        return 0;
      case Flurorouter.operacionesRoute:
        return 1;
      case Flurorouter.dashboardRoute:
        return 2;
      case Flurorouter.clientesRoute:
        return 3;
      case Flurorouter.usuariosRoute:
        return 4;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagesProvider = context.watch<PagesProvider>();

    return CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.secondary,
        animationDuration: const Duration(milliseconds: 400),
        index: currentPageToIndex(pagesProvider.currentPage),
        onTap: (value) {
          selectedPageIndex = value;
          var routeName = '';
          switch (value) {
            case 0:
              routeName = TasasListPage.route;
              break;
            case 1:
              routeName = OperacionesListPage.route;
              break;
            case 2:
              routeName = Flurorouter.dashboardRoute;
              break;
            case 3:
              routeName = ClientesListPage.route;
              break;
            case 4:
              routeName = Flurorouter.usuariosRoute;
              break;
            default:
          }
          navigateTo(routeName);
        },
        items: const [
          Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.assignment,
            color: Colors.white,
          ),
          Icon(
            Icons.home_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.person_pin_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
          ),
        ]);
  }
}
