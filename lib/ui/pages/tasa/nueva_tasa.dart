import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NuevaTasaPage extends StatefulWidget {
  static String route = '/tasas/nuevaTasa';
  const NuevaTasaPage({super.key});

  @override
  State<NuevaTasaPage> createState() => _NuevaTasaPageState();
}

class _NuevaTasaPageState extends State<NuevaTasaPage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController tasaController = TextEditingController();

  Moneda? monedaEntranteSelected;
  Moneda? monedaSalienteSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Agregar Tasa'),
    );
  }

  buildBody(BuildContext context) {
    final monedasProvider = context.watch<MonedasProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildField(context, 'Nombre', nombreController, maxLength: 30),
                CustomDropdown<Moneda>(
                    items: monedasProvider.monedas,
                    value: monedaEntranteSelected,
                    onChange: onMonedaEntranteSelected,
                    title: 'Moneda Entrante'),
                CustomDropdown<Moneda>(
                    items: monedasProvider.monedas,
                    value: monedaSalienteSelected,
                    onChange: onMonedaSalienteSelected,
                    title: 'Moneda Saliente'),
                buildField(context, 'Tasa', tasaController,
                    maxLength: 30,
                    type: TextInputType.number,
                    onlyDigits: true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
                onPressed: agregar, child: const Text('Agregar Tasa')),
          ),
        ],
      ),
    );
  }

  onMonedaEntranteSelected(Moneda? moneda) {
    setState(() {
      monedaEntranteSelected = moneda;
    });
  }

  onMonedaSalienteSelected(Moneda? moneda) {
    setState(() {
      monedaSalienteSelected = moneda;
    });
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      TextInputType? type,
      Widget? suffix,
      bool onlyDigits = false}) {
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
          if (onlyDigits) FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
        ],
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

    final tasa = Tasa(
        nombre: nombreController.text,
        monedaEntrante: monedaEntranteSelected!,
        monedaSaliente: monedaSalienteSelected!,
        tasa: double.parse(tasaController.text));

    try {
      await tasa.insert();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Tasa Agregada'),
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
    if (monedaEntranteSelected == null) return false;
    if (monedaSalienteSelected == null) return false;
    if (tasaController.text == '') return false;

    return true;
  }
}