import 'package:cambio_veraz/models/rol.dart';
import 'package:cambio_veraz/models/usuario.dart';
import 'package:cambio_veraz/providers/roles_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditarUsuarioPage extends StatefulWidget {
  static String route = '/usuarios/editarUsuario/:id';

  final String usuarioId;
  const EditarUsuarioPage({super.key, required this.usuarioId});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  bool loading = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool obscurePassword = true;

  Rol? rolSelected;

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  inicializarCampos() async {
    final usuario = await database.getUsuarioById(widget.usuarioId);

    nombreController.text = usuario.nombre;
    emailController.text = usuario.email;

    setState(() {
      loading = false;

      rolSelected = usuario.rol;
    });
  }

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
      title: const Text('Editar Usuario'),
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
      child: loading
          ? const Center(
              child: CupertinoActivityIndicator(
                radius: 12,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      buildField(context, 'Correo', emailController,
                          maxLength: 30,
                          type: TextInputType.emailAddress,
                          enable: false),
                      buildField(context, 'Nombre', nombreController,
                          maxLength: 30),
                      CustomDropdown<Rol>(
                          items: rolesProvider.roles,
                          value: rolSelected,
                          onChange: onRolSelected,
                          title: 'Rol'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: editar, child: const Text('Editar Usuario')),
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
      bool obscureText = false,
      bool enable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          enabled: enable,
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

  editar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final newUsuario = Usuario(
        id: widget.usuarioId,
        nombre: nombreController.text,
        email: emailController.text,
        rol: rolSelected!);

    try {
      await newUsuario.update();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Usuario Editado'),
      ));

      return NavigationService.replaceTo(Flurorouter.usuariosRoute);
    } catch (err) {
      print(err);
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al editar.'),
      ));
    }
  }

  bool validate() {
    if (nombreController.text == '') return false;
    if (emailController.text == '') return false;
    if (rolSelected == null) return false;

    return true;
  }
}
