import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key, required this.onSignOut});

  final Function() onSignOut;

  @override
  Widget? get title => Row(
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
      );

  @override
  bool? get centerTitle => true;

  @override
  // TODO: implement actions
  List<Widget>? get actions => [signOutButton()];

  Widget signOutButton() {
    return IconButton(
        onPressed: onSignOut, icon: const Icon(Icons.exit_to_app_rounded));
  }
}
