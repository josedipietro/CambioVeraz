import 'package:cambio_veraz/providers/auth_provider.dart';
import 'package:cambio_veraz/ui/buttons/CustomButton.dart';
import 'package:cambio_veraz/ui/widgets/WavesHeader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    iniciarSesion() async {
      await authProvider.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 200, child: WavesHeader(200)),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: Image.asset(
                    'assets/images/CV_SEC_ORI.png',
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                height: 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: emailController,
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Correo',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {},
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: 'Contraseña',
                          border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Iniciar Sesión',
                press: iniciarSesion,
                disabled: authProvider.authStatus == AuthStatus.checking,
                color: Theme.of(context).colorScheme.secondary,
                colorText: Theme.of(context).colorScheme.onSecondary,
                width: MediaQuery.of(context).size.width,
              )
            ],
          ),
        ),
      ],
    );
  }
}
