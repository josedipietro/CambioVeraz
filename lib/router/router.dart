import 'package:cambio_veraz/router/no_page_found_handlers.dart';
import 'package:cambio_veraz/router/pages_handlers.dart';
import 'package:fluro/fluro.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static String rootRoute = '/';

  // Auth Router
  static String loginRoute = '/auth/login';
  static String registerRoute = '/auth/register';

  // Pages
  static String dashboardRoute = '/dashboard';

  static void configureRoutes() {
    // Auth Routes
    router.define(rootRoute,
        handler: PagesHandlers.login, transitionType: TransitionType.none);
    router.define(loginRoute,
        handler: PagesHandlers.login, transitionType: TransitionType.none);
    router.define(registerRoute,
        handler: PagesHandlers.register, transitionType: TransitionType.none);

    // Pages
    router.define(dashboardRoute,
        handler: PagesHandlers.dashboard,
        transitionType: TransitionType.fadeIn);

    // 404
    router.notFoundHandler = NoPageFoundHandlers.noPageFound;
  }
}
