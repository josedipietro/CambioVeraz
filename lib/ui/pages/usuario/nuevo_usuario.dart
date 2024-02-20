import 'package:cambio_veraz/models/rol.dart';
import 'package:cambio_veraz/models/usuario.dart';
import 'package:cambio_veraz/providers/roles_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:cambio_veraz/util/createNewUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NuevoUsuarioPage extends StatefulWidget {
  static String route = '/usuarios/nuevoUsuario';
  const NuevoUsuarioPage({super.key});

  @override
  State<NuevoUsuarioPage> createState() => _NuevoUsuarioPageState();
}

class _NuevoUsuarioPageState extends State<NuevoUsuarioPage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  bool obscurePassword = true;

  Rol? rolSelected;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigationService.replaceTo(Flurorouter.operacionesRoute);
        return true;
      },
      child: Scaffold(
        appBar: buildAppBar(),
        body: buildBody(context),
      ),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Agregar Usuario'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.operacionesRoute);
        },
      ),
    );
  }

  buildBody(BuildContext context) {
    final rolesProvider = context.watch<RolesProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildField(context, 'Correo', emailController,
                    maxLength: 30, type: TextInputType.emailAddress),
                buildField(context, 'Nombre', nombreController, maxLength: 30),
                CustomDropdown<Rol>(
                    items: rolesProvider.roles,
                    value: rolSelected,
                    onChange: onRolSelected,
                    title: 'Rol'),
                buildField(context, 'Contraseña', passwordController,
                    maxLength: 30,
                    obscureText: obscurePassword,
                    suffix: buildEyeSuffix()),
                buildField(
                    context, 'Confirmar contraseña', passwordConfirmController,
                    maxLength: 30, obscureText: obscurePassword),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
                onPressed: agregar, child: const Text('Agregar Usuario')),
          ),
        ],
      ),
    );
  }

  onRolSelected(Rol? rol) {
    setState(() {
      rolSelected = rol;
    });
  }

  Widget buildEyeSuffix() {
    return IconButton(
        onPressed: () {
          setState(() {
            obscurePassword = false;
          });
        },
        icon: const Icon(Icons.remove_red_eye_rounded));
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      TextInputType? type,
      Widget? suffix,
      bool onlyDigits = false,
      bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          enableSuggestions: true,
          keyboardType: TextInputType.number,
          obscureText: obscureText,
          decoration: InputDecoration(
              labelText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              border: const OutlineInputBorder(),
              filled: true,
              hoverColor: Theme.of(context).hoverColor,
              suffix: suffix),
          inputFormatters: <TextInputFormatter>[
            if (onlyDigits) FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
          ],
        ),
      ),
    );
  }

  agregar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final newUsuario = Usuario(
        nombre: nombreController.text,
        email: emailController.text,
        rol: rolSelected!);

    try {
      await createNewUser(newUsuario, passwordController.text);

      await newUsuario.insert();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Usuario Agregada'),
      ));

      return NavigationService.replaceTo(Flurorouter.usuariosRoute);
    } catch (err) {
      print(err);
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al agregar.'),
      ));
    }
  }

  bool validate() {
    if (nombreController.text == '') return false;
    if (emailController.text == '') return false;
    if (passwordController.text == '') return false;
    if (passwordConfirmController.text == '') return false;
    if (rolSelected == null) return false;

    return true;
  }
}
