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
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class NuevaOperacionPage extends StatefulWidget {
  static String route = '/operacions/nuevaOperacion';
  const NuevaOperacionPage({super.key});

  @override
  State<NuevaOperacionPage> createState() => _NuevaCientePageState();
}

class _NuevaCientePageState extends State<NuevaOperacionPage> {
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

  double monto = 0;

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
      title: const Text('Agregar Operacion'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.operacionesRoute);
        },
      ),
    );
  }

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
                    value: clienteSelected,
                    onChange: onClienteSelected,
                    title: 'Cliente'),
                CustomDropdown<Moneda>(
                    items: monedasProvider.monedas,
                    value: monedaEntranteSelected,
                    onChange: onMonedaEntranteSelected,
                    title: 'Moneda Entrante'),
                if (monedaEntranteSelected != null)
                  CustomDropdown<Cuenta>(
                      items: cuentasProvider.cuentas
                          .where((element) =>
                              element.moneda.nombreISO ==
                              monedaEntranteSelected!.nombreISO)
                          .toList(),
                      value: cuentaEntranteSelected,
                      onChange: onCuentaEntranteSelected,
                      title: 'Cuenta Entrante'),
                if (monedaEntranteSelected != null)
                  CustomDropdown<Moneda>(
                      items: monedasProvider.monedas
                          .where((element) =>
                              element.nombreISO !=
                              monedaEntranteSelected!.nombreISO)
                          .toList(),
                      value: monedaSalienteSelected,
                      onChange: onMonedaSalienteSelected,
                      title: 'Moneda Saliente'),
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
                              value: movimiento.cuentaSaliente,
                              onChange: (Cuenta? cuenta) {
                                setState(() {
                                  onChangeMovimiento(index, cuenta);
                                });
                              },
                              title: 'Cuenta Saliente',
                            ),
                            buildField(context, 'Monto', movimiento.monto,
                                maxLength: 30,
                                type: TextInputType.number,
                                suffix: Text(
                                    cuentaEntranteSelected!.moneda.simbolo),
                                onlyDigits: true),
                          ],
                        );
                      },
                    );
                  },
                ),
                buildUploadFileButton('Subir Comprobante', (file) {
                  comprobanteFile = file;
                  NotificationsService.showSnackbar(
                      'Comprobante ${file.name} cargado');
                }),
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
              child: const Text('Agregar Operacion'),
            ),
          ),
        ],
      ),
    );
  }

  void agregarOperacion(cuentasProvider, cuentaEntranteSelected) {
    setState(() {
      movimientos.add(Movimientos(
          idOperacion: '1',
          cuentaEntrante: cuentaEntranteSelected,
          cuentaSaliente: null,
          monto: TextEditingController(text: '0')));
    });
  }

  double sumarMontos(List<Movimientos> movimientos) {
    double total = 0.0;
    for (var movimiento in movimientos) {
      double monto = double.tryParse(movimiento.monto.text) ?? 0.0;
      total += monto;
    }
    return total;
  }

  onChangeMovimiento(index, cuenta) {
    setState(() {
      movimientos[index].cuentaSaliente = cuenta;
    });
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
    final tasa = tasas.firstWhereOrNull((element) =>
        element.monedaEntrante.nombreISO == monedaEntranteSelected!.nombreISO &&
        element.monedaSaliente.nombreISO == moneda!.nombreISO);

    setState(() {
      monedaSalienteSelected = moneda;
      tasaSelected = tasa;
      cuentasSalientesSelected = [];
      movimientos = [];
    });
  }

  onCuentaEntranteSelected(Cuenta? cuenta) {
    setState(() {
      cuentaEntranteSelected = cuenta;
    });
  }

  Function(Cuenta?) onCuentaSalienteSelected(List<Cuenta> cuentas) {
    return (Cuenta? cuenta) {
      setState(() {
        cuentasSalientesSelected = cuentas;
      });
    };
  }

  Widget buildOperacionTasaPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tasa'),
        Text(
            '${monedaEntranteSelected?.simbolo ?? ''}$monto - ${monedaSalienteSelected?.simbolo ?? ''}${formatMontoTasa()}')
      ],
    );
  }

  formatMontoTasa() {
    double conversion = tasaSelected!.tasa * monto;
    String fixed = conversion.toStringAsFixed(2);
    return double.parse(fixed);
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255, type, Widget? suffix, bool onlyDigits = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
          if (value != '') {
            setState(() {
              monto = double.parse(value);
            });
          }
        },
      ),
    );
  }

  Widget buildUploadFileButton(
      String title, Function(PlatformFile) onFileSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      width: double.infinity,
      height: 80,
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

    final operacion = Operacion(
        cuentaSaliente: movimientos[0].cuentaSaliente!,
        cliente: clienteSelected!,
        cuentaEntrante: cuentaEntranteSelected!,
        movimimentos: movimientos,
        fecha: DateTime.now(),
        monto: sumarMontos(movimientos),
        tasa: tasaSelected!);

    try {
      operacion.referenciaComprobante.putData(
          comprobanteFile!.bytes!, SettableMetadata(contentType: 'image/png'));

      await operacion.insert();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Operacion Agregada'),
      ));

      return NavigationService.replaceTo(Flurorouter.operacionesRoute);
    } catch (err) {
      print(err);
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al agregar.'),
      ));
    }
  }

  bool validate() {
    if (clienteSelected == null) return false;
    if (cuentaEntranteSelected == null) return false;
    if (tasaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay tasa registrada para el par seleccionado')));
      return false;
    }

    if (cuentasSalientesSelected == null) return false;
    for (var movimiento in movimientos) {
      if (movimiento.monto.text == '0') return false;
    }

    if (comprobanteFile == null) false;

    return true;
  }
}
