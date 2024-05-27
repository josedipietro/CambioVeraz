import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  TextEditingController observacionesController = TextEditingController();
  bool especial = false;
  PlatformFile? cedulaFile;
  PlatformFile? fotoFile;

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

  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Agregar Cliente'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.operacionesRoute);
        },
      ),
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
                buildField(context, 'Observaciones', observacionesController,
                    maxLength: 400),
                Row(
                  children: [
                    Checkbox(
                      value: especial,
                      onChanged: (value) {
                        setState(() {
                          especial = value!;
                        });
                      },
                    ),
                    const Text('Cliente preferencial?'),
                  ],
                ),
                buildUploadFileButton('Subir Cedula', (file) {
                  cedulaFile = file;
                  NotificationsService.showSnackbar(
                      'Imagen ${file.name} cargada');
                }),
                buildUploadFileButton('Subir Foto', (file) {
                  fotoFile = file;
                  NotificationsService.showSnackbar(
                      'Imagen ${file.name} cargada');
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

  Future<bool> validatorImage(operacionRequest) async {
    bool test = true;
    try {
      var result = await operacionRequest.getMetadata();
    } catch (error) {
      test = false;
    }
    return test;
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
        telefono: telefonoController.text,
        especial: false,
        observaciones: observacionesController.text);

    try {
      if (cedulaFile != null) {
        cliente.referenciaFotoCedula.putData(
            cedulaFile!.bytes!, SettableMetadata(contentType: 'image/png'));
      }
      if (fotoFile != null) {
        cliente.referenciaFoto.putData(
            fotoFile!.bytes!, SettableMetadata(contentType: 'image/png'));
      }

      await cliente.insert();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Cliente Agregado'),
      ));

      return NavigationService.replaceTo(Flurorouter.clientesRoute);
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

    // if (fotoFile == null) false;
    // if (cedulaFile == null) false;

    return true;
  }
}
