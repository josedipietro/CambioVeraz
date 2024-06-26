import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/services/notification_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NuevoDepositoPage extends StatefulWidget {
  static String route = '/depositos/nuevaDeposito';
  const NuevoDepositoPage({super.key});

  @override
  State<NuevoDepositoPage> createState() => _NuevoCientePageState();
}

class _NuevoCientePageState extends State<NuevoDepositoPage> {
  Moneda? monedaEntranteSelected;

  Cuenta? cuentaEntranteSelected;

  TextEditingController montoController = TextEditingController(text: '0');
  TextEditingController tasaController = TextEditingController(text: '0');

  PlatformFile? comprobanteFile;

  double monto = 0;
  double tasa = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigationService.replaceTo(Flurorouter.depositosRoute);
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
      title: const Text('Agregar Fondeo'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.depositosRoute);
        },
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final monedasProvider = context.watch<MonedasProvider>();
    final cuentasProvider = context.watch<CuentasProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
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
                if (cuentaEntranteSelected != null)
                  buildField(context, 'Monto', montoController,
                      maxLength: 30,
                      type: TextInputType.number,
                      suffix: Text(cuentaEntranteSelected!.moneda.simbolo),
                      onlyDigits: true, onChange: (value) {
                    if (value != '') {
                      setState(() {
                        monto = double.parse(value);
                      });
                    }
                  }),
                if (cuentaEntranteSelected != null)
                  buildField(context, 'Tasa', tasaController,
                      maxLength: 30,
                      type: TextInputType.number,
                      suffix: const Text('\$'),
                      onlyDigits: true, onChange: (value) {
                    if (value != '') {
                      setState(() {
                        tasa = double.parse(value);
                      });
                    }
                  }),
                buildUploadFileButton('Subir Comprobante', (file) {
                  comprobanteFile = file;
                  NotificationsService.showSnackbar(
                      'Comprobante ${file.name} cargado');
                }),
                if (tasa > 0) buildDepositoTasaPreview(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: tasa > 0 ? agregar : () {},
              child: const Text('Agregar Fondeo'),
            ),
          ),
        ],
      ),
    );
  }

  onMonedaEntranteSelected(Moneda? moneda) {
    setState(() {
      monedaEntranteSelected = moneda;

      cuentaEntranteSelected = null;
    });
  }

  onCuentaEntranteSelected(Cuenta? cuenta) {
    setState(() {
      cuentaEntranteSelected = cuenta;
    });
  }

  Widget buildDepositoTasaPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tasa'),
        Text(
            '${monedaEntranteSelected?.simbolo ?? ''}$monto - \$${formatMontoTasa(monto, tasa)}')
      ],
    );
  }

  formatMontoTasa(double monto, double tasa) {
    return (monto / tasa);
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      type,
      Widget? suffix,
      bool onlyDigits = false,
      required Function(String) onChange}) {
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
        onChanged: onChange,
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

  double calcularValor(int montoBs, double tasa) {
    return 1 / tasa;
  }

  agregar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final deposito = Deposito(
        cuentaReceptora: cuentaEntranteSelected!,
        fecha: DateTime.now(),
        monto: double.parse(montoController.text),
        tasa: calcularValor(monto.toInt(), tasa));
    try {
      deposito.referenciaComprobante.putData(
          comprobanteFile!.bytes!, SettableMetadata(contentType: 'image/png'));

      await deposito.insert();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Fondeo agregado'),
      ));

      return NavigationService.replaceTo(Flurorouter.depositosRoute);
    } catch (err) {
      print(err);
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al agregar.'),
      ));
    }
  }

  bool validate() {
    if (cuentaEntranteSelected == null) return false;
    if (tasa == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay tasa registrada para el par seleccionado')));
      return false;
    }

    if (montoController.text == '' || montoController.text == '0') return false;

    if (comprobanteFile == null) false;

    return true;
  }
}
