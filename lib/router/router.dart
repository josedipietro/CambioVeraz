import 'package:cambio_veraz/router/no_page_found_handlers.dart';
import 'package:cambio_veraz/router/pages_handlers.dart';
import 'package:fluro/fluro.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static const String rootRoute = '/';

  // Auth Router
  static const String loginRoute = '/auth/login';

  // Pages
  static const String dashboardRoute = '/dashboard';
  static const String clientesRoute = '/clientes';
  static const String agregarClienteRoute = '/clientes/agregar';
  static const String cuentasRoute = '/cuentas';
  static const String agregarCuentaRoute = '/cuentas/agregar';
  static const String tasasRoute = '/tasas';
  static const String agregarTasaRoute = '/tasas/agregar';
  static const String operacionesRoute = '/operaciones';
  static const String agregarOperacioneRoute = '/operaciones/agregar';
  static const String rolesRoute = '/roles';
  static const String agregarRolRoute = '/roles/agregar';
  static const String monedasRoute = '/monedas';
  static const String agregarMonedaRoute = '/monedas/agregar';
  static const String usuariosRoute = '/usuarios';
  static const String agregarUsuarioRoute = '/usuarios/agregar';

  static void configureRoutes() {
    // Auth Routes
    router.define(rootRoute,
        handler: PagesHandlers.login, transitionType: TransitionType.none);
    router.define(loginRoute,
        handler: PagesHandlers.login, transitionType: TransitionType.none);

    // Pages
    router.define(dashboardRoute,
        handler: PagesHandlers.dashboard,
        transitionType: TransitionType.fadeIn);

    router.define(clientesRoute,
        handler: PagesHandlers.clientes, transitionType: TransitionType.fadeIn);

    router.define(cuentasRoute,
        handler: PagesHandlers.cuentas, transitionType: TransitionType.fadeIn);

    router.define(tasasRoute,
        handler: PagesHandlers.tasas, transitionType: TransitionType.fadeIn);

    router.define(operacionesRoute,
        handler: PagesHandlers.operaciones,
        transitionType: TransitionType.fadeIn);

    router.define(monedasRoute,
        handler: PagesHandlers.monedas, transitionType: TransitionType.fadeIn);

    router.define(usuariosRoute,
        handler: PagesHandlers.usuarios, transitionType: TransitionType.fadeIn);

    router.define(rolesRoute,
        handler: PagesHandlers.roles, transitionType: TransitionType.fadeIn);

    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
