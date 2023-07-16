import 'package:cambio_veraz/ui/pages/login/login_page.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      physics: const ClampingScrollPhysics(),
      children: const [LoginPage()],
    ));
  }
}
