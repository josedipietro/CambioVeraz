import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/ui/layouts/app/pages_layout.dart';
import 'package:cambio_veraz/ui/layouts/auth/auth_layout.dart';
import 'package:cambio_veraz/ui/layouts/splash/splash_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  Flurorouter.configureRoutes();
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(lazy: false, create: (_) => AuthProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => PagesProvider())
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elohim',
      initialRoute: '/',
      onGenerateRoute: Flurorouter.router.generator,
      // navigatorKey: NavigationService.navigatorKey,
      // scaffoldMessengerKey: NotificationsService.messengerKey,
      builder: (context, child) {
        final authProvider = context.watch<AuthProvider>();

        if (authProvider.authStatus == AuthStatus.checking) {
          return const SplashLayout(); // loading
        }

        if (authProvider.authStatus == AuthStatus.authenticated) {
          return PagesLayout(child: child!); // home
        } else {
          return AuthLayout(child: child!); // auth
        }
      },
      theme: ThemeData.light().copyWith(
          scrollbarTheme: const ScrollbarThemeData().copyWith(
              thumbColor:
                  MaterialStateProperty.all(Colors.grey.withOpacity(0.5)))),
    );
  }
}
