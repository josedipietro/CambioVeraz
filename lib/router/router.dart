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
  static const String comisiones = '/comisiones';
  static const String clientesRoute = '/clientes';
  static const String agregarClienteRoute = '/clientes/agregar';
  static const String editarClienteRoute = '/clientes/editar/:id';
  static const String cuentasRoute = '/cuentas';
  static const String agregarCuentaRoute = '/cuentas/agregar';
  static const String editarCuentaRoute = '/cuentas/editar/:id';
  static const String tasasRoute = '/tasas';
  static const String agregarTasaRoute = '/tasas/agregar';
  static const String editarTasaRoute = '/tasas/editar/:id';
  static const String operacionesRoute = '/operaciones';
  static const String agregarOperacionRoute = '/operaciones/agregar';
  static const String editarOperacionRoute = '/operaciones/editar/:id';
  static const String depositosRoute = '/depositos';
  static const String agregarDepositoRoute = '/depositos/agregar';
  static const String editarDepositoRoute = '/depositos/editar/:id';
  static const String rolesRoute = '/roles';
  static const String agregarRolRoute = '/roles/agregar';
  static const String editarRolRoute = '/roles/editar/:id';
  static const String monedasRoute = '/monedas';
  static const String agregarMonedaRoute = '/monedas/agregar';
  static const String editarMonedaRoute = '/monedas/editar/:id';
  static const String usuariosRoute = '/usuarios';
  static const String agregarUsuarioRoute = '/usuarios/agregar';
  static const String editarUsuarioRoute = '/usuarios/editar/:id';
  static const String listadoDeEgresosIngresos = '/ingresos';
  static const String reporteDeMovimientos = '/report/movimientos';

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

    router.define(depositosRoute,
        handler: PagesHandlers.depositos,
        transitionType: TransitionType.fadeIn);

    router.define(agregarClienteRoute,
        handler: PagesHandlers.agregarCliente,
        transitionType: TransitionType.fadeIn);

    router.define(agregarCuentaRoute,
        handler: PagesHandlers.agregarCuenta,
        transitionType: TransitionType.fadeIn);

    router.define(agregarTasaRoute,
        handler: PagesHandlers.agregarTasa,
        transitionType: TransitionType.fadeIn);

    router.define(agregarOperacionRoute,
        handler: PagesHandlers.agregarOperacion,
        transitionType: TransitionType.fadeIn);

    router.define(agregarMonedaRoute,
        handler: PagesHandlers.agregarMoneda,
        transitionType: TransitionType.fadeIn);

    router.define(agregarUsuarioRoute,
        handler: PagesHandlers.agregarUsuario,
        transitionType: TransitionType.fadeIn);

    router.define(agregarRolRoute,
        handler: PagesHandlers.agregarRol,
        transitionType: TransitionType.fadeIn);

    router.define(agregarDepositoRoute,
        handler: PagesHandlers.agregarDeposito,
        transitionType: TransitionType.fadeIn);

    router.define(editarClienteRoute,
        handler: PagesHandlers.editarCliente,
        transitionType: TransitionType.fadeIn);

    router.define(editarCuentaRoute,
        handler: PagesHandlers.editarCuenta,
        transitionType: TransitionType.fadeIn);

    router.define(editarDepositoRoute,
        handler: PagesHandlers.editarDeposito,
        transitionType: TransitionType.fadeIn);

    router.define(editarMonedaRoute,
        handler: PagesHandlers.editarMoneda,
        transitionType: TransitionType.fadeIn);

    router.define(editarOperacionRoute,
        handler: PagesHandlers.editarOperacion,
        transitionType: TransitionType.fadeIn);

    router.define(editarRolRoute,
        handler: PagesHandlers.editarRol,
        transitionType: TransitionType.fadeIn);

    router.define(editarTasaRoute,
        handler: PagesHandlers.editarTasa,
        transitionType: TransitionType.fadeIn);

    router.define(editarUsuarioRoute,
        handler: PagesHandlers.editarUsuario,
        transitionType: TransitionType.fadeIn);

    router.define(listadoDeEgresosIngresos,
        handler: PagesHandlers.ingresosEgresos,
        transitionType: TransitionType.fadeIn);

    router.define(reporteDeMovimientos,
        handler: PagesHandlers.reporteMovimientos,
        transitionType: TransitionType.fadeIn);

    router.define(comisiones,
        handler: PagesHandlers.comisiones,
        transitionType: TransitionType.fadeIn);
    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
