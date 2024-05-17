import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
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
    print(currentPage);
    switch (currentPage) {
      case Flurorouter.tasasRoute:
        return 0;
      case Flurorouter.monedasRoute:
        return 0;
      case Flurorouter.agregarTasaRoute:
        return 0;
      case Flurorouter.agregarMonedaRoute:
        return 0;
      case Flurorouter.operacionesRoute:
        return 1;
      case Flurorouter.agregarOperacionRoute:
        return 1;
      case Flurorouter.depositosRoute:
        return 1;
      case Flurorouter.agregarDepositoRoute:
        return 1;
      case Flurorouter.comisiones:
        return 1;
      case Flurorouter.cuentasRoute:
        return 1;
      case Flurorouter.agregarCuentaRoute:
        return 1;
      case Flurorouter.dashboardRoute:
        return 2;
      case Flurorouter.clientesRoute:
        return 3;
      case Flurorouter.agregarClienteRoute:
        return 3;
      case Flurorouter.usuariosRoute:
        return 4;
      case Flurorouter.agregarUsuarioRoute:
        return 4;
      case Flurorouter.listadoDeEgresosIngresos:
        return 5;
      case Flurorouter.reporteDeMovimientos:
        return 5;
      default:
        return 2;
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
        height: 60,
        onTap: (value) {
          selectedPageIndex = value;
          var routeName = '';
          switch (value) {
            case 0:
              routeName = Flurorouter.tasasRoute;
              break;
            case 1:
              routeName = Flurorouter.operacionesRoute;
              break;
            case 2:
              routeName = Flurorouter.dashboardRoute;
              break;
            case 3:
              routeName = Flurorouter.clientesRoute;
              break;
            case 4:
              routeName = Flurorouter.usuariosRoute;
              break;
            case 5:
              routeName = Flurorouter.listadoDeEgresosIngresos;
              break;
            default:
          }
          navigateTo(routeName);
        },
        items: const [
          Tooltip(
            message: 'Tasas',
            child: Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Operaciones',
            child: Icon(
              Icons.assignment,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Inicio',
            child: Icon(
              Icons.home_rounded,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Clientes',
            child: Icon(
              Icons.person_pin_rounded,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Usuarios',
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Tasas',
            child: Icon(
              Icons.attach_money,
              color: Colors.white,
            ),
          ),
        ]);
  }
}
