import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/movimientos.dart';
import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/providers/clientes_provider.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/providers/tasas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditarOperacionPage extends StatefulWidget {
  static String route = '/tasas/editarTasa/:id';

  final String operacionId;
  const EditarOperacionPage({super.key, required this.operacionId});

  @override
  State<EditarOperacionPage> createState() => _EditarOperacionPageState();
}

class _EditarOperacionPageState extends State<EditarOperacionPage> {
  bool loading = false;
  Cliente? clienteSelected;
  List<Movimientos> movimientos = [];
  Moneda? monedaEntranteSelected;
  Moneda? monedaSalienteSelected;
  Tasa? tasaSelected;
  Cuenta? cuentaEntranteSelected;
  List<Cuenta> cuentasSalientesSelected = [];
  Cuenta? cuentaSalienteSelected;
  PlatformFile? comprobanteFile;
  List<Tasa> tasas = [];
  List<Tasa> tasasElegibles = [];
  double monto = 0;
  double comision = 0;
  PlatformFile? comprobanteFileOne;
  PlatformFile? comprobanteFileTwo;
  PlatformFile? comprobanteFileThree;
  String opreacionId = '';

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  Future<bool> validatorImage(operacionRequest) async {
    bool test = true;
    try {
      var result = await operacionRequest.getMetadata();
    } catch (error) {
      print('Error: $error');
      test = false;
    }
    return test;
  }

  inicializarCampos() async {
    final operacion = await database.getOperacionById(widget.operacionId);
    Future<String>? downloadURLOne =
        await validatorImage(operacion.referenciaComprobanteOne) == true
            ? operacion.referenciaComprobanteOne.getDownloadURL()
            : null;
    Future<String>? downloadURLTwo =
        await validatorImage(operacion.referenciaComprobanteTwo) == true
            ? operacion.referenciaComprobanteOne.getDownloadURL()
            : null;
    Future<String>? downloadURLThree =
        await validatorImage(operacion.referenciaComprobanteThree) == true
            ? operacion.referenciaComprobanteOne.getDownloadURL()
            : null;
    setState(() {
      if (downloadURLOne != null) {
        downloadURLOne.then((urlOne) {
          comprobanteFileOne = PlatformFile(name: urlOne, size: 20);
        }).catchError((error) {});
      }
      if (downloadURLTwo != null) {
        downloadURLTwo.then((urlTwo) {
          comprobanteFileTwo = PlatformFile(name: urlTwo, size: 20);
        }).catchError((error) {});
      }
      if (downloadURLThree != null) {
        downloadURLThree.then((urlThree) {
          comprobanteFileThree = PlatformFile(name: urlThree, size: 20);
        }).catchError((error) {});
      }

      opreacionId = operacion.id;
      monedaSalienteSelected = operacion.cuentaSaliente.moneda;
      monedaEntranteSelected = operacion.cuentaEntrante.moneda;
      cuentaEntranteSelected = operacion.cuentaEntrante;
      movimientos = operacion.movimimentos;
      tasaSelected = operacion.tasa;
      clienteSelected = operacion.cliente;
      monto = sumarMontos(operacion.movimimentos);
      comision = calcularTotalComisiones(operacion.movimimentos);
      loading = false;
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
        body: loading ? const Text('Cargando') : buildBody(context),
      ),
    );
  }

  onClienteSelected(Cliente? cliente) {
    setState(() {
      clienteSelected = cliente;
    });
  }

  onMonedaEntranteSelected(Moneda? moneda) {
    setState(() {
      monedaEntranteSelected = moneda;
      cuentaEntranteSelected = null;
      monedaSalienteSelected = null;
      cuentasSalientesSelected = [];
      movimientos = [];
    });
  }

  onMonedaSalienteSelected(Moneda? moneda) {
    final tasa = tasas.where((element) =>
        element.monedaEntrante.nombreISO == monedaEntranteSelected!.nombreISO &&
        element.monedaSaliente.nombreISO == moneda!.nombreISO);

    tasasElegibles = tasa.toList();
    setState(() {
      monedaSalienteSelected = moneda;
      cuentasSalientesSelected = [];
      movimientos = [];
    });
  }

  onCuentaEntranteSelected(Cuenta? cuenta) {
    setState(() {
      cuentaEntranteSelected = cuenta;
    });
  }

  Widget buildUploadFileButtonOne(
      String title, Function(PlatformFile) onFileSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      width: double.infinity,
      height: 100,
      child: OutlinedButton(
        onPressed: () async {
          var picked = await FilePicker.platform
              .pickFiles(type: FileType.image, withData: true);

          if (picked != null) {
            setState(() {
              onFileSelected(picked.files.first);
            });
          }
        },
        child: comprobanteFileOne != null
            ? Text(comprobanteFileOne!.name)
            : Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  Widget buildUploadFileButtonTwo(
      String title, Function(PlatformFile) onFileSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      width: double.infinity,
      height: 100,
      child: OutlinedButton(
        onPressed: () async {
          var picked = await FilePicker.platform
              .pickFiles(type: FileType.image, withData: true);

          if (picked != null) {
            setState(() {
              onFileSelected(picked.files.first);
            });
          }
        },
        child: comprobanteFileTwo != null
            ? Text(comprobanteFileTwo!.name)
            : Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  Widget buildUploadFileButtonThree(
      String title, Function(PlatformFile) onFileSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      width: double.infinity,
      height: 100,
      child: OutlinedButton(
        onPressed: () async {
          var picked = await FilePicker.platform
              .pickFiles(type: FileType.image, withData: true);

          if (picked != null) {
            setState(() {
              onFileSelected(picked.files.first);
            });
          }
        },
        child: comprobanteFileThree != null
            ? Text(comprobanteFileThree!.name)
            : Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  void agregarOperacion(cuentasProvider, cuentaEntranteSelected) {
    setState(() {
      movimientos.add(Movimientos(
          idOperacion: '1',
          cuentaEntrante: cuentaEntranteSelected,
          cuentaSaliente: null,
          comisionFija: TextEditingController(text: '0'),
          comision: TextEditingController(text: '0'),
          monto: TextEditingController(text: '0'),
          bono: TextEditingController(text: '0')));
    });
  }

  formatMontoTasa() {
    double conversion = tasaSelected!.tasa * monto;
    String fixed = conversion.toStringAsFixed(2);
    return double.parse(fixed);
  }

  Widget buildOperacionTasaPreview() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tasa'),
            Text(
                '${monedaEntranteSelected?.simbolo ?? ''}$monto - ${monedaSalienteSelected?.simbolo ?? ''}${formatMontoTasa()}')
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Comision Total'),
            Text('Comision total $comision')
          ],
        ),
      ],
    );
  }

  buildAppBar() {}
  Widget buildBody(BuildContext context) {
    final clientesProvider = context.watch<ClientesProvider>();
    final monedasProvider = context.watch<MonedasProvider>();
    final cuentasProvider = context.watch<CuentasProvider>();
    tasas = context.watch<TasasProvider>().tasas;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                CustomDropdown<Cliente>(
                    items: clientesProvider.clientes,
                    value: clientesProvider.clientes.firstWhereOrNull(
                        (element) => element.id == clienteSelected?.id),
                    onChange: null,
                    title: 'Cliente'),
                CustomDropdown<Moneda>(
                    items: monedasProvider.monedas,
                    value: monedasProvider.monedas.firstWhereOrNull(
                        (element) => element.id == monedaEntranteSelected?.id),
                    onChange: null,
                    title: 'Moneda Entrante'),
                if (monedaEntranteSelected != null)
                  CustomDropdown<Cuenta>(
                      items: cuentasProvider.cuentas
                          .where((element) =>
                              element.moneda.nombreISO ==
                              monedaEntranteSelected!.nombreISO)
                          .toList(),
                      value: cuentasProvider.cuentas.firstWhereOrNull(
                          (element) =>
                              element.id == cuentaEntranteSelected?.id),
                      onChange: null,
                      title: 'Cuenta Entrante'),
                if (monedaEntranteSelected != null)
                  CustomDropdown<Moneda>(
                      items: monedasProvider.monedas
                          .where((element) =>
                              element.nombreISO !=
                              monedaEntranteSelected!.nombreISO)
                          .toList(),
                      value: monedasProvider.monedas.firstWhereOrNull(
                          (element) =>
                              element.id == monedaSalienteSelected?.id),
                      onChange: null,
                      title: 'Moneda Saliente'),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    readOnly: true,
                    initialValue: tasaSelected!.nombre,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Correo',
                      focusColor: Colors.grey,
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: movimientos.length,
                  itemBuilder: (BuildContext context, int index) {
                    final movimiento = movimientos[index];
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          children: [
                            CustomDropdown<Cuenta>(
                              items: cuentasProvider.cuentas
                                  .where((element) =>
                                      element.moneda.nombreISO ==
                                      monedaSalienteSelected!.nombreISO)
                                  .toList(),
                              value: cuentasProvider.cuentas.firstWhereOrNull(
                                  (element) =>
                                      element.id ==
                                      movimiento.cuentaSaliente?.id),
                              onChange: (Cuenta? cuenta) {
                                setState(() {
                                  onChangeMovimiento(index, cuenta);
                                });
                              },
                              title: 'Cuenta Saliente',
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            buildField(true, context, 'Monto', movimiento.monto,
                                maxLength: 30,
                                type: TextInputType.number,
                                suffix: Text(
                                    cuentaEntranteSelected!.moneda.simbolo),
                                onlyDigits: true),
                            buildField(false, context, 'Porcentaje de comision',
                                movimiento.comision,
                                maxLength: 30,
                                type: TextInputType.number,
                                suffix: const Text('%'),
                                onlyDigits: true),
                            buildField(false, context, 'Comision fija',
                                movimiento.comisionFija,
                                maxLength: 30,
                                type: TextInputType.number,
                                suffix: const Text('%'),
                                onlyDigits: true),
                            buildField(false, context, 'Bono', movimiento.bono,
                                maxLength: 30,
                                type: TextInputType.number,
                                suffix: const Text('%'),
                                onlyDigits: true),
                          ],
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child:
                          buildUploadFileButtonOne('Subir Comprobante', (file) {
                        comprobanteFileOne = file;
                        NotificationsService.showSnackbar(
                            'Comprobante ${file.name} cargado');
                      }),
                    ),
                    Expanded(
                      flex: 1,
                      child:
                          buildUploadFileButtonTwo('Subir Comprobante', (file) {
                        comprobanteFileTwo = file;
                        NotificationsService.showSnackbar(
                            'Comprobante ${file.name} cargado');
                      }),
                    ),
                    Expanded(
                      flex: 1,
                      child: buildUploadFileButtonThree('Subir Comprobante',
                          (file) {
                        comprobanteFileThree = file;
                        NotificationsService.showSnackbar(
                            'Comprobante ${file.name} cargado');
                      }),
                    ),
                  ],
                ),
                if (monedaSalienteSelected != null)
                  ElevatedButton(
                      onPressed: () => {
                            agregarOperacion(
                                cuentasProvider, cuentaEntranteSelected)
                          },
                      child: const Text('Agregar operacion')),
                if (tasaSelected != null) buildOperacionTasaPreview(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: tasaSelected != null ? agregar : () {},
              child: const Text('Editar Operacion'),
            ),
          ),
        ],
      ),
    );
  }

  onChangeMovimiento(index, cuenta) {
    setState(() {
      movimientos[index].cuentaSaliente = cuenta;
    });
  }

  Widget buildField(bool montos, BuildContext context, String hintText,
      TextEditingController controller,
      {int maxLength = 255, type, Widget? suffix, bool onlyDigits = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        enableSuggestions: true,
        keyboardType: TextInputType.number,
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
        onChanged: (value) {
          if (value != '' && montos) {
            setState(() {
              monto = sumarMontos(movimientos);
            });
          } else if (value != '' && !montos) {
            setState(() {
              comision = calcularTotalComisiones(movimientos);
            });
          }
        },
      ),
    );
  }

  double calcularTotalComisiones(List<Movimientos> movimientos) {
    double totalComisiones = 0;

    for (var movimiento in movimientos) {
      double monto = double.parse(movimiento.monto.text);
      double comisionPorcentaje = double.parse(movimiento.comision.text) / 100;
      double comision = monto * comisionPorcentaje;
      totalComisiones += comision;
    }

    return totalComisiones;
  }

  double sumarMontos(List<Movimientos> movimientos) {
    double total = 0.0;
    for (var movimiento in movimientos) {
      double monto = double.tryParse(movimiento.monto.text) ?? 0.0;
      total += monto;
    }
    return total;
  }

  bool validate() {
    if (clienteSelected == null) return false;
    if (cuentaEntranteSelected == null) return false;
    if (tasaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay tasa registrada para el par seleccionado')));
      return false;
    }
    for (var movimiento in movimientos) {
      if (movimiento.monto.text == '0') return false;
    }

    if (comprobanteFile == null) false;

    return true;
  }

  double sumarMontosPref(List<Movimientos> movimientos) {
    double total = 0.0;
    for (var movimiento in movimientos) {
      double monto = double.tryParse(movimiento.monto.text) ?? 0.0;
      total += monto;
    }
    return total;
  }

  bool isFlutterURL(String url) {
    bool validURL = Uri.parse(url).isAbsolute;
    print(validURL);
    return validURL;
  }

  agregar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }
    final total = movimientos[0].cuentaSaliente!.preferencia
        ? sumarMontosPref(movimientos)
        : sumarMontos(movimientos);
    final comisiones = calcularTotalComisiones(movimientos);

    final operacion = Operacion(
        id: opreacionId,
        cuentaSaliente: movimientos[0].cuentaSaliente!,
        cliente: clienteSelected!,
        cuentaEntrante: cuentaEntranteSelected!,
        movimimentos: movimientos,
        fecha: DateTime.now(),
        monto: total + comisiones,
        tasa: tasaSelected!);

    try {
      if (!isFlutterURL(comprobanteFileOne!.name)) {
        operacion.referenciaComprobanteOne.putData(comprobanteFileOne!.bytes!,
            SettableMetadata(contentType: 'image/png'));
      }

      if (comprobanteFileTwo != null &&
          !isFlutterURL(comprobanteFileTwo!.name)) {
        operacion.referenciaComprobanteTwo.putData(comprobanteFileTwo!.bytes!,
            SettableMetadata(contentType: 'image/png'));
      }

      if (comprobanteFileThree != null &&
          !isFlutterURL(comprobanteFileThree!.name)) {
        operacion.referenciaComprobanteThree.putData(
            comprobanteFileThree!.bytes!,
            SettableMetadata(contentType: 'image/png'));
      }

      await operacion.update();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Operacion Editada'),
      ));

      return NavigationService.replaceTo(Flurorouter.operacionesRoute);
    } catch (err) {
      print(err);
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al editar.'),
      ));
    }
  }
}
