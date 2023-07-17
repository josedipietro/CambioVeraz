import 'package:cambio_veraz/firebase_options.dart';
import 'package:cambio_veraz/providers/depositos_provider.dart';
import 'package:cambio_veraz/providers/operaciones_provider.dart';
import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/providers/clientes_provider.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/providers/pages_provider.dart';
import 'package:cambio_veraz/providers/tasas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:cambio_veraz/ui/layouts/app/pages_layout.dart';
import 'package:cambio_veraz/ui/layouts/auth/auth_layout.dart';
import 'package:cambio_veraz/ui/layouts/splash/splash_layout.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  Flurorouter.configureRoutes();
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(lazy: false, create: (_) => AuthProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => PagesProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => ClientesProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => TasasProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => CuentasProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => MonedasProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => CuentasProvider()),
        ChangeNotifierProvider(
            lazy: false, create: (_) => OperacionesProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => DepositosProvider()),
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
      title: 'Cambio Veraz',
      initialRoute: '/',
      onGenerateRoute: Flurorouter.router.generator,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NotificationsService.messengerKey,
      builder: (context, child) {
        return Overlay(initialEntries: [
          OverlayEntry(builder: (context) {
            final authProvider = context.watch<AuthProvider>();

            if (authProvider.authStatus == AuthStatus.checking) {
              return const SplashLayout(); // loading
            }

            if (authProvider.authStatus == AuthStatus.authenticated) {
              return PagesLayout(child: child!); // home
            } else {
              return AuthLayout(child: child!); // auth
            }
          })
        ]);
      },
      theme: ThemeData(
          primaryColor: const Color(0xff263169),
          colorScheme: ColorScheme(
              primary: const Color(0xff263169),
              secondary: const Color(0xffE95119),
              background: Colors.white.withOpacity(0.9),
              brightness: Brightness.light,
              error: Colors.red.shade700,
              onPrimary: Colors.white.withOpacity(0.9),
              onSecondary: Colors.white.withOpacity(0.9),
              onError: Colors.white.withOpacity(0.9),
              onBackground: Colors.black,
              surface: Colors.white.withOpacity(0.9),
              onSurface: Colors.black)),
    );
  }
}
