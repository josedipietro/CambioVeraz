import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/providers/monedas_provider.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditarCuentaPage extends StatefulWidget {
  static String route = '/operaciones/editarCuenta/:id';
  final String cuentaId;
  const EditarCuentaPage({super.key, required this.cuentaId});

  @override
  State<EditarCuentaPage> createState() => _EditarCuentaPageState();
}

class _EditarCuentaPageState extends State<EditarCuentaPage> {
  bool loading = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController nombreTitularController = TextEditingController();
  TextEditingController numeroCuentaController = TextEditingController();
  TextEditingController numeroIdController = TextEditingController();
  TextEditingController comisionController = TextEditingController();
  bool preferencia = false;
  Moneda? monedaSelected;

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  inicializarCampos() async {
    final cliente = await database.getCuentaById(widget.cuentaId);

    setState(() {
      monedaSelected = cliente.moneda;
      nombreController.text = cliente.nombre;
      nombreTitularController.text = cliente.nombreTitular;
      numeroCuentaController.text = cliente.numeroCuenta;
      numeroIdController.text = cliente.numeroIdentificacion;
      comisionController.text = cliente.comision.toString();
      preferencia = cliente.preferencia ?? false;
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
      title: const Text('Editar Cuenta'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          NavigationService.replaceTo(Flurorouter.operacionesRoute);
        },
      ),
    );
  }

  buildBody(BuildContext context) {
    final monedasProvider = context.watch<MonedasProvider>();

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
                      CustomDropdown<Moneda>(
                        items: monedasProvider.monedas,
                        value: monedasProvider.monedas.firstWhereOrNull(
                            (element) => element.id == monedaSelected?.id),
                        onChange: onMonedaSelected,
                        title: 'Moneda',
                      ),
                      buildField(
                          context, 'Nombre Titular', nombreTitularController,
                          maxLength: 30),
                      buildField(
                          context, 'Numero de Cuenta', numeroCuentaController,
                          maxLength: 30),
                      buildField(context, 'Numero de Identificacion',
                          numeroIdController,
                          maxLength: 30),
                      buildField(
                        context,
                        'Porcentaje de Comisión',
                        comisionController,
                        maxLength: 30,
                        onlyDigits: true,
                        suffix: const Text('%'),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: preferencia,
                            onChanged: (value) {
                              setState(() {
                                preferencia = value!;
                              });
                            },
                          ),
                          const Text('Cuenta preferencial?'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: editar, child: const Text('Editar Cuenta')),
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

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      Widget? suffix,
      bool onlyDigits = false,
      Function(String)? onChange}) {
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

  editar() async {
    if (!validate()) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Datos erroneos'),
      ));
    }

    final cuenta = Cuenta(
        preferencia: preferencia,
        id: widget.cuentaId,
        nombre: nombreController.text,
        moneda: monedaSelected!,
        nombreTitular: nombreTitularController.text,
        numeroCuenta: numeroCuentaController.text,
        numeroIdentificacion: numeroIdController.text,
        comision: double.parse(comisionController.text));

    try {
      await cuenta.update();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Cuenta Editada'),
      ));

      return NavigationService.replaceTo(Flurorouter.cuentasRoute);
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
    if (monedaSelected == null) return false;
    if (nombreTitularController.text == '') return false;
    if (numeroCuentaController.text == '') return false;
    if (numeroIdController.text == '') return false;

    return true;
  }
}
