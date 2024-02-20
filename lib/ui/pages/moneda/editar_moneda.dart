import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditarMonedaPage extends StatefulWidget {
  static String route = '/tasas/editarMoneda/:id';

  final String monedaId;
  const EditarMonedaPage({super.key, required this.monedaId});

  @override
  State<EditarMonedaPage> createState() => _EditarMonedaPageState();
}

class _EditarMonedaPageState extends State<EditarMonedaPage> {
  bool loading = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController isoController = TextEditingController();
  TextEditingController simboloController = TextEditingController();

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  inicializarCampos() async {
    final moneda = await database.getMonedaById(widget.monedaId);

    nombreController.text = moneda.nombre;
    isoController.text = moneda.nombreISO;
    simboloController.text = moneda.simbolo;

    setState(() {
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
        body: buildBody(context),
      ),
    );
  }

  buildAppBar() {
    return AppBar(
      title: const Text('Editar Moneda'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.operacionesRoute);
        },
      ),
    );
  }

  buildBody(BuildContext context) {
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
                      buildField(context, 'Nombre', nombreController,
                          maxLength: 30),
                      buildField(context, 'Nombre ISO', isoController,
                          maxLength: 4),
                      buildField(context, 'Simbolo', simboloController,
                          maxLength: 3),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: editarMoneda,
                      child: const Text('Editar Moneda')),
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

  editarMoneda() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final moneda = Moneda(
        id: widget.monedaId,
        nombre: nombreController.text,
        nombreISO: isoController.text,
        simbolo: simboloController.text);

    try {
      await moneda.update();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Moneda Agregada'),
      ));

      return NavigationService.replaceTo(Flurorouter.monedasRoute);
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
    if (isoController.text == '') return false;
    if (simboloController.text == '') return false;

    return true;
  }
}
