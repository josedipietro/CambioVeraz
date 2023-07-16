import 'package:cambio_veraz/router/no_page_found_handlers.dart';
import 'package:cambio_veraz/router/pages_handlers.dart';
import 'package:fluro/fluro.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static String rootRoute = '/';

  // Auth Router
  static String loginRoute = '/auth/login';

  // Pages
  static String dashboardRoute = '/dashboard';
  static String clientesRoute = '/clientes';
  static String cuentasRoute = '/cuentas';
  static String tasasRoute = '/tasas';
  static String operacionesRoute = '/operaciones';
  static String rolesRoute = '/roles';
  static String monedasRoute = '/monedas';
  static String usuariosRoute = '/usuarios';

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

    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
