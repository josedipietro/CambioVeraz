import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/tasa.dart';
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

class EditarTasaPage extends StatefulWidget {
  static String route = '/tasas/editarTasa/:id';

  final String tasaId;
  const EditarTasaPage({super.key, required this.tasaId});

  @override
  State<EditarTasaPage> createState() => _EditarTasaPageState();
}

class _EditarTasaPageState extends State<EditarTasaPage> {
  bool loading = false;

  TextEditingController nombreController = TextEditingController();
  TextEditingController tasaController = TextEditingController();

  Moneda? monedaEntranteSelected;
  Moneda? monedaSalienteSelected;

  double tasa = 0;

  bool tasaEntrante = true;

  @override
  void initState() {
    loading = true;
    inicializarCampos();

    super.initState();
  }

  inicializarCampos() async {
    final tasa = await database.getTasaById(widget.tasaId);

    nombreController.text = tasa.nombre;
    double montoTasa;
    if (!tasa.tasaEntrante) {
      montoTasa = 1 / tasa.tasa;
    } else {
      montoTasa = tasa.tasa;
    }
    tasaController.text = montoTasa.toString();

    setState(() {
      tasaEntrante = tasa.tasaEntrante;
      this.tasa = montoTasa;

      monedaEntranteSelected = tasa.monedaEntrante;
      monedaSalienteSelected = tasa.monedaSaliente;
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
      title: const Text('Editar Tasa'),
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
                              (element) =>
                                  element.id == monedaEntranteSelected?.id),
                          onChange: onMonedaEntranteSelected,
                          title: 'Moneda Entrante'),
                      CustomDropdown<Moneda>(
                          items: monedasProvider.monedas,
                          value: monedasProvider.monedas.firstWhereOrNull(
                              (element) =>
                                  element.id == monedaSalienteSelected?.id),
                          onChange: onMonedaSalienteSelected,
                          title: 'Moneda Saliente'),
                      if (monedaSalienteSelected != null)
                        Row(
                          children: [
                            buildField(
                              context,
                              'Tasa',
                              tasaController,
                              maxLength: 30,
                              type: TextInputType.number,
                              onlyDigits: true,
                              suffix: Text(monedaSalienteSelected!.simbolo),
                              onChange: (value) {
                                if (value != '') {
                                  setState(() {
                                    tasa = double.parse(value);
                                  });
                                }
                              },
                            ),
                            Column(
                              children: [
                                const Text('Invertir tasa'),
                                Switch(
                                    value: tasaEntrante,
                                    onChanged: (value) {
                                      setState(() {
                                        tasaEntrante = value;
                                      });
                                    }),
                              ],
                            )
                          ],
                        ),
                      if (monedaSalienteSelected != null &&
                          monedaEntranteSelected != null)
                        buildTasaPreview(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: editar, child: const Text('Editar Tasa')),
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

  buildTasaPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Tasa:'),
        if (tasaEntrante)
          Text(
              '${monedaEntranteSelected!.simbolo}1-${monedaSalienteSelected!.simbolo}$tasa')
        else
          Text(
              '${monedaSalienteSelected!.simbolo}1-${monedaEntranteSelected!.simbolo}$tasa')
      ],
    );
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      TextInputType? type,
      Widget? suffix,
      bool onlyDigits = false,
      Function(String)? onChange}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          enableSuggestions: true,
          keyboardType: TextInputType.number,
          onChanged: onChange,
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
        ),
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

    final tasaConverted = tasaEntrante ? tasa : 1 / tasa;

    final newTasa = Tasa(
        id: widget.tasaId,
        nombre: nombreController.text,
        monedaEntrante: monedaEntranteSelected!,
        monedaSaliente: monedaSalienteSelected!,
        tasaEntrante: tasaEntrante,
        tasa: tasaConverted);

    try {
      await newTasa.update();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Tasa Agregada'),
      ));

      return NavigationService.replaceTo(Flurorouter.tasasRoute);
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
    if (monedaEntranteSelected == null) return false;
    if (monedaSalienteSelected == null) return false;
    if (tasaController.text == '') return false;

    return true;
  }
}
