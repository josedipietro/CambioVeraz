import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NuevaCuentaPage extends StatefulWidget {
  static String route = '/operaciones/nuevaCuenta';
  const NuevaCuentaPage({super.key});

  @override
  State<NuevaCuentaPage> createState() => _NuevaCuentaPageState();
}

class _NuevaCuentaPageState extends State<NuevaCuentaPage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController nombreTitularController = TextEditingController();
  TextEditingController numeroCuentaController = TextEditingController();
  TextEditingController numeroIdController = TextEditingController();

  Moneda? monedaSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Agregar Cuenta'),
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
                  value: monedaSelected,
                  onChange: onMonedaSelected,
                  title: 'Moneda',
                ),
                buildField(context, 'Nombre Titular', nombreTitularController,
                    maxLength: 30),
                buildField(context, 'Numero de Cuenta', numeroCuentaController,
                    maxLength: 30),
                buildField(
                    context, 'Numero de Identificacion', numeroIdController,
                    maxLength: 30),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
                onPressed: agregar, child: const Text('Agregar Cuenta')),
          ),
        ],
      ),
    );
  }

  onMonedaSelected(Moneda? moneda) {
    setState(() {
      monedaSelected = moneda;
    });
  }

  buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        enableSuggestions: true,
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

  agregar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final cuenta = Cuenta(
        nombre: nombreController.text,
        moneda: monedaSelected!,
        nombreTitular: nombreTitularController.text,
        numeroCuenta: int.parse(numeroCuentaController.text),
        numeroIdentificacion: int.parse(numeroIdController.text));

    try {
      await cuenta.insert();
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
    if (monedaSelected == null) return false;
    if (nombreTitularController.text == '') return false;
    if (numeroCuentaController.text == '') return false;
    if (numeroIdController.text == '') return false;

    return true;
  }
}
