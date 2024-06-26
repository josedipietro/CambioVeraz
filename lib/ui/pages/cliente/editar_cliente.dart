import 'dart:io';

import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditarClientePage extends StatefulWidget {
  static String route = '/clientes/editarCliente/:id';
  final String clienteId;
  const EditarClientePage({super.key, required this.clienteId});

  @override
  State<EditarClientePage> createState() => _EditarCientePageState();
}

class _EditarCientePageState extends State<EditarClientePage> {
  bool loading = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController observacionesController = TextEditingController();
  bool especial = false;

  Future<String>? fotoCedulaUrl;
  Future<String>? fotoUrl;

  PlatformFile? cedulaFile;
  PlatformFile? fotoFile;

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  inicializarCampos() async {
    final cliente = await database.getClienteById(widget.clienteId);
    final referencia1 =
        await validatorImage(cliente.referenciaFotoCedula) == true
            ? cliente.referenciaFotoCedula.getDownloadURL()
            : null;
    final referencia2 = await validatorImage(cliente.referenciaFoto) == true
        ? cliente.referenciaFoto.getDownloadURL()
        : null;

    nombreController.text = cliente.nombre;
    apellidoController.text = cliente.apellido;
    cedulaController.text = cliente.cedula;
    telefonoController.text = cliente.telefono;
    especial = cliente.especial == null ? false : true;
    observacionesController.text = cliente.observaciones ?? '';

    try {
      setState(() {
        if (referencia1 != null) {
          referencia1.then((urlOne) {
            cedulaFile = PlatformFile(name: urlOne, size: 20);
          }).catchError((error) {});
        }
        if (referencia2 != null) {
          referencia2.then((urlTwo) {
            fotoFile = PlatformFile(name: urlTwo, size: 20);
          }).catchError((error) {});
        }

        fotoUrl = referencia2;
        fotoCedulaUrl = referencia1;

        loading = false;
      });
    } catch (err) {
      setState(() {
        loading = false;
      });
    }
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
      title: const Text('Editar Cliente'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.clientesRoute);
        },
      ),
    );
  }

  Widget buildBody(BuildContext context) {
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
                      buildField(context, 'Nombre(s)', nombreController,
                          maxLength: 30),
                      buildField(context, 'Apellidos', apellidoController,
                          maxLength: 30),
                      buildField(context, 'Cedula (DNI)', cedulaController,
                          maxLength: 30, type: TextInputType.number),
                      buildField(context, 'Telefono', telefonoController,
                          maxLength: 30),
                      buildField(
                          context, 'Observaciones', observacionesController,
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
                      Center(
                          child: fotoCedulaUrl != null
                              ? FutureBuilder<String?>(
                                  future: fotoCedulaUrl,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Image.network(
                                        snapshot.data!,
                                        width: 200,
                                        fit: BoxFit
                                            .fitWidth, // Ajusta el ancho y mantiene el aspecto
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                )
                              : Text(
                                  cedulaFile?.name ?? '',
                                  style: const TextStyle(fontSize: 20),
                                )),
                      buildUploadFileButton('Subir Cedula', (file) {
                        setState(() {
                          cedulaFile = file;
                          fotoCedulaUrl = null;
                        });
                        NotificationsService.showSnackbar(
                            'Imagen ${file.name} cargada');
                      }),
                      Center(
                        child: fotoUrl != null
                            ? FutureBuilder<String?>(
                                future: fotoUrl,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Image.network(
                                      snapshot.data!,
                                      width: 200,
                                      fit: BoxFit.fitWidth,
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              )
                            : Text(
                                fotoFile?.name ?? '',
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                      buildUploadFileButton('Subir Foto', (file) {
                        setState(() {
                          fotoFile = file;
                          fotoUrl = null;
                        });
                        NotificationsService.showSnackbar(
                            'Imagen ${file.name} cargada');
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: editar, child: const Text('Editar Cliente')),
                ),
              ],
            ),
    );
  }

  Future<String?> _getImageUrlFromFile(File? file) async {
    if (file == null) return null;

    final imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final reference =
        FirebaseStorage.instance.ref().child('images').child(imageId);
    await reference.putFile(file);

    return await reference.getDownloadURL();
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

  bool isFlutterURL(String url) {
    bool validURL = Uri.parse(url).isAbsolute;
    print(validURL);
    return validURL;
  }

  editar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final cliente = Cliente(
        id: widget.clienteId,
        nombre: nombreController.text,
        activo: true,
        observaciones: observacionesController.text,
        especial: false,
        apellido: apellidoController.text,
        cedula: cedulaController.text,
        telefono: telefonoController.text);

    try {
      if (cedulaFile != null && !isFlutterURL(cedulaFile!.name)) {
        cliente.referenciaFotoCedula.putData(
            cedulaFile!.bytes!, SettableMetadata(contentType: 'image/png'));
      }
      if (fotoFile != null && !isFlutterURL(fotoFile!.name)) {
        cliente.referenciaFoto.putData(
            fotoFile!.bytes!, SettableMetadata(contentType: 'image/png'));
      }

      await cliente.update();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Cliente Editado'),
      ));

      return NavigationService.replaceTo(Flurorouter.clientesRoute);
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
    if (apellidoController.text == '') return false;
    if (cedulaController.text == '') return false;
    if (telefonoController.text == '') return false;

    if (fotoUrl == null) false;
    if (fotoCedulaUrl == null) false;

    return true;
  }
}
