import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Widget signOutButton() {
      return IconButton(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.exit_to_app_rounded));
    }

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            child: Image.asset('assets/images/CV_ISO_BLANCO.png',
                fit: BoxFit.scaleDown),
          ),
          const Text('Cambio Veraz',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
      centerTitle: true,
      actions: [signOutButton()],
    );
  }
}
