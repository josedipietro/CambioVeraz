import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/ui/pages/login/login_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagesHandlers {
  static Handler login = Handler(handlerFunc: (context, params) {
    final authProvider = Provider.of<AuthProvider>(context!);

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
      return const LoginPage();
    } else {
      return Container();
    }
  });
}
