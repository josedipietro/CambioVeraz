import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/ui/pages/cliente/clientes_list.dart';
import 'package:cambio_veraz/ui/pages/cuenta/cuentas_list.dart';
import 'package:cambio_veraz/ui/pages/login/login_page.dart';
import 'package:cambio_veraz/ui/pages/moneda/monedas_list.dart';
import 'package:cambio_veraz/ui/pages/operacion/operaciones_list.dart';
import 'package:cambio_veraz/ui/pages/tasa/tasas_list.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagesHandlers {
  static Handler login = Handler(handlerFunc: (context, params) {
    final authProvider = Provider.of<AuthProvider>(context!);
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.loginRoute);

    if (authProvider.authStatus == AuthStatus.notAuthenticated) {
      return const LoginPage();
    } else {
      return Container();
    }
  });

  static Handler dashboard = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.dashboardRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return Container();
    } else {
      return const LoginPage();
    }
  });

  static Handler monedas = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.monedasRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return const MonedasListPage();
    } else {
      return const LoginPage();
    }
  });

  static Handler clientes = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.clientesRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return const ClientesListPage();
    } else {
      return const LoginPage();
    }
  });

  static Handler tasas = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.tasasRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return const TasasListPage();
    } else {
      return const LoginPage();
    }
  });

  static Handler operaciones = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context
        .read<PagesProvider>()
        .setCurrentPageUrl(Flurorouter.operacionesRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return const OperacionesListPage();
    } else {
      return const LoginPage();
    }
  });

  static Handler cuentas = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.cuentasRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return const CuentasListPage();
    } else {
      return const LoginPage();
    }
  });

  static Handler usuarios = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.usuariosRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return Container();
    } else {
      return const LoginPage();
    }
  });

  static Handler roles = Handler(handlerFunc: (context, params) {
    final authProvider = context!.watch<AuthProvider>();
    context.read<PagesProvider>().setCurrentPageUrl(Flurorouter.rolesRoute);

    if (authProvider.authStatus == AuthStatus.authenticated) {
      return Container();
    } else {
      return const LoginPage();
    }
  });
}
