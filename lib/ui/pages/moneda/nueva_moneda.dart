import 'package:cambio_veraz/models/moneda.dart';
import 'package:flutter/material.dart';

class NuevaMonedaPage extends StatefulWidget {
  static String route = '/tasas/nuevaMoneda';
  const NuevaMonedaPage({super.key});

  @override
  State<NuevaMonedaPage> createState() => _NuevaMonedaPageState();
}

class _NuevaMonedaPageState extends State<NuevaMonedaPage> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController isoController = TextEditingController();
  TextEditingController simboloController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Agregar Moneda'),
    );
  }

  buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildField(context, 'Nombre', nombreController, maxLength: 30),
                buildField(context, 'Nombre ISO', isoController, maxLength: 4),
                buildField(context, 'Simbolo', simboloController, maxLength: 3),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12.0),
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
                onPressed: agregarMoneda, child: const Text('Agregar Moneda')),
          ),
        ],
      ),
    );
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

  agregarMoneda() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final moneda = Moneda(
        nombre: nombreController.text,
        nombreISO: isoController.text,
        simbolo: simboloController.text);

    try {
      await moneda.insert();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Moneda Agregada'),
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
    if (isoController.text == '') return false;
    if (simboloController.text == '') return false;

    return true;
  }
}
