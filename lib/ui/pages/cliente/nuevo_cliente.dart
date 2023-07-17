import 'package:cambio_veraz/models/cliente.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class NuevoClientePage extends StatefulWidget {
  static String route = '/clientes/nuevoCliente';
  const NuevoClientePage({super.key});

  @override
  State<NuevoClientePage> createState() => _NuevoCientePageState();
}

class _NuevoCientePageState extends State<NuevoClientePage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  PlatformFile? cedulaFile;
  PlatformFile? fotoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Agregar Cliente'),
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildField(context, 'Nombre(s)', nombreController,
                    maxLength: 30),
                buildField(context, 'Apellidos', apellidoController,
                    maxLength: 30),
                buildField(context, 'Cedula (DNI)', cedulaController,
                    maxLength: 30, type: TextInputType.number),
                buildField(context, 'Telefono', telefonoController,
                    maxLength: 30),
                buildUploadFileButton('Subir Cedula', (file) {
                  cedulaFile = file;
                }),
                buildUploadFileButton('Subir Foto', (file) {
                  fotoFile = file;
                })
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
                onPressed: agregar, child: const Text('Agregar Cliente')),
          ),
        ],
      ),
    );
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        enableSuggestions: true,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(),
          filled: true,
          hoverColor: Theme.of(context).hoverColor,
        ),
      ),
    );
  }

  Widget buildUploadFileButton(
      String title, Function(PlatformFile) onFileSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0),
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
          onPressed: () async {
            var picked = await FilePicker.platform
                .pickFiles(type: FileType.image, withData: true);

            if (picked != null) {
              onFileSelected(picked.files.first);
              print(picked.files.first.name);
              print(picked.files.first.bytes);
            }
          },
          child: Text(title)),
    );
  }

  agregar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final cliente = Cliente(
        nombre: nombreController.text,
        activo: true,
        apellido: apellidoController.text,
        cedula: cedulaController.text,
        telefono: telefonoController.text);

    try {
      cliente.referenciaFotoCedula.putData(cedulaFile!.bytes!);
      cliente.referenciaFoto.putData(fotoFile!.bytes!);

      await cliente.insert();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Cuenta Agregada'),
      ));

      return Navigator.of(context).pop();
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
    if (apellidoController.text == '') return false;
    if (cedulaController.text == '') return false;
    if (telefonoController.text == '') return false;

    if (fotoFile == null) false;
    if (cedulaFile == null) false;

    return true;
  }
}
