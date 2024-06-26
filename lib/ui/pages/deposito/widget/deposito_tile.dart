import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/depositos_provider.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:cambio_veraz/ui/shared/view_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DepositoTile extends StatefulWidget {
  final Deposito deposito;
  final void Function(Deposito) onRemove;

  const DepositoTile({
    super.key,
    required this.deposito,
    required this.onRemove,
  });

  @override
  State<DepositoTile> createState() => _DepositoTileState();
}

class _DepositoTileState extends State<DepositoTile> {
  final DateFormat format = DateFormat.yMd('es');
  Cuenta? cuentaReceptora;
  double addMount = 0;
  Deposito? cuentaEntranteSelected;
  TextEditingController montoController = TextEditingController();
  TextEditingController tasaController = TextEditingController();
  TextEditingController cuentaController = TextEditingController();
  double montoCuentaDebitar = 0;
  @override
  Widget build(BuildContext context) {
    final cuentasProvider = context.watch<CuentasProvider>();
    final depositos = context.watch<DepositosProvider>();
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).floatingActionButtonTheme.backgroundColor),
      padding: const EdgeInsetsDirectional.only(
          start: 14, end: 14, bottom: 7, top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitleAndDescription(),
          _buildMontoYTasa(),
          _buildRemovableArea(context),
          _buildAgregarFondeos(context, cuentasProvider, depositos),
        ],
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deposito.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              format.format(widget.deposito.fecha),
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMontoYTasa() {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${widget.deposito.cuentaReceptora.moneda.simbolo}${widget.deposito.monto}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          Text(
            '${widget.deposito.cuentaReceptora.moneda.simbolo}1 - \$${widget.deposito.tasa}',
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildAgregarFondeos(BuildContext context,
      CuentasProvider cuentasProvider, DepositosProvider depositos) {
    return GestureDetector(
      onTap: () => _onAdd(context, cuentasProvider, depositos),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.monetization_on_sharp, color: Colors.blue),
      ),
    );
  }

  void _onAdd(BuildContext context, CuentasProvider cuentasProvider,
      DepositosProvider depositos) async {
    inicializarCampo().then((_) async {
      bool isMontoEnabled =
          false; // Variable para controlar el estado de habilitación del campo de monto

      final confirm = await showViewDialog(
        context,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildField(context, 'Cuenta a fondear', cuentaController,
                        maxLength: 300, enabled: false),
                    CustomDropdown<Deposito>(
                      items: depositos.depositos,
                      value: cuentaEntranteSelected,
                      onChange: (cuenta) {
                        setState(() {
                          cuentaEntranteSelected = cuenta;
                          montoCuentaDebitar = cuenta!.monto;
                          if (cuentaEntranteSelected != null &&
                              tasaController.text.isNotEmpty) {
                            isMontoEnabled =
                                true; // Habilitar el campo de monto si se ha seleccionado una cuenta y una tasa
                          } else {
                            isMontoEnabled =
                                false; // Deshabilitar el campo de monto si no se ha seleccionado una cuenta o una tasa
                          }
                        });
                      },
                      title: 'Cuenta a debitar',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (cuentaEntranteSelected != null)
                      Text(
                          "Dinero disponible en la cuenta: ${cuentaEntranteSelected!.monto.toString()}${cuentaEntranteSelected!.cuentaReceptora.moneda.simbolo}"),
                    const SizedBox(
                      height: 15,
                    ),
                    buildField(
                      context,
                      'Tasa',
                      tasaController,
                      maxLength: 30,
                      suffix:
                          Text(widget.deposito.cuentaReceptora.moneda.simbolo),
                      onChanged: (value) {
                        setState(() {
                          if (cuentaEntranteSelected != null &&
                              value.isNotEmpty) {
                            isMontoEnabled =
                                true; // Habilitar el campo de monto si se ha seleccionado una cuenta y se ha escrito en el campo de tasa
                          } else {
                            isMontoEnabled =
                                false; // Deshabilitar el campo de monto si no se ha seleccionado una cuenta o no se ha escrito en el campo de tasa
                          }
                        });
                      },
                    ),
                    buildField(context, 'Monto', montoController,
                        maxLength: 30,
                        suffix: cuentaEntranteSelected == null
                            ? null
                            : Text(cuentaEntranteSelected!
                                .cuentaReceptora.moneda.simbolo),
                        maxValue: cuentaEntranteSelected != null &&
                                tasaController.text.isNotEmpty
                            ? montoCuentaDebitar
                            : 0, // Establecer el valor máximo según la cuenta y la tasa seleccionadas
                        enabled:
                            isMontoEnabled), // Habilitar o deshabilitar el campo de monto según la variable isMontoEnabled
                    ValueListenableBuilder(
                      valueListenable: montoController,
                      builder: (context, value, child) {
                        if (montoController.value.text.isNotEmpty) {
                          double monto =
                              double.parse(montoController.value.text);
                          return Column(
                            children: [
                              Text(
                                  'Dinero entrante: ${monto * double.parse(tasaController.value.text)}${widget.deposito.cuentaReceptora.moneda.simbolo}'),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  'Dinero saliente: $monto${cuentaEntranteSelected!.cuentaReceptora.moneda.simbolo}')
                            ],
                          );
                        } else {
                          return Container(); // Mostrar un contenedor vacío si el texto es vacío
                        }
                      },
                    ),

                    if (montoController.value.text != '')
                      Column(
                        children: [
                          Text(
                              'Dinero entrante: ${double.parse(montoController.value.text) * double.parse(tasaController.value.text)}${widget.deposito.cuentaReceptora.moneda.simbolo}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Dinero saliente: ${double.parse(montoController.value.text)}${cuentaEntranteSelected!.cuentaReceptora.moneda.simbolo}')
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        title: 'Fondeo',
      );
      if (confirm == true) {
        submit();
        // final confirmTwo = await showViewDialog(context,
        //     content: Column(
        //       children: [
        //         Text(
        //             'Dinero entrante: ${double.parse(montoController.value.text) * double.parse(tasaController.value.text)}${widget.deposito.cuentaReceptora.moneda.simbolo}'),
        //         const SizedBox(
        //           height: 10,
        //         ),
        //         Text(
        //             'Dinero saliente: ${double.parse(montoController.value.text)}${cuentaEntranteSelected!.cuentaReceptora.moneda.simbolo}')
        //       ],
        //     ),
        //     title: 'Informacion del fondeo');
        // if (confirmTwo == true) {}
      }
    });
  }

  submit() {
    Deposito primerDeposito = Deposito(
        id: widget.deposito.id,
        cuentaReceptora: widget.deposito.cuentaReceptora,
        monto: widget.deposito.monto +
            double.parse(montoController.value.text) *
                double.parse(tasaController.value.text),
        tasa: widget.deposito.tasa,
        fecha: widget.deposito.fecha);

    Deposito segundoDeposito = Deposito(
        id: cuentaEntranteSelected!.id,
        cuentaReceptora: cuentaEntranteSelected!.cuentaReceptora,
        monto: cuentaEntranteSelected!.monto -
            double.parse(montoController.value.text),
        tasa: cuentaEntranteSelected!.tasa,
        fecha: cuentaEntranteSelected!.fecha);

    try {
      primerDeposito.update();
      segundoDeposito.update();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: const Text('Fondeo completado'),
      ));
    } catch (error) {
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ha ocurrido un error al editar.'),
      ));
    }
  }

  onCuentaEntranteSelected(Deposito? cuenta) {
    setState(() {
      cuentaEntranteSelected = cuenta;
    });
  }

  inicializarCampo() async {
    final operacionRequest = await database.getArcaById(widget.deposito.id);
    setState(() {
      cuentaReceptora = operacionRequest.cuentaReceptora;
      cuentaController = TextEditingController(text: cuentaReceptora!.nombre);
    });
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255,
      Widget? suffix,
      TextInputType type = const TextInputType.numberWithOptions(decimal: true),
      bool enabled = true,
      double maxValue = double.infinity,
      void Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        enableSuggestions: true,
        keyboardType: type,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: const OutlineInputBorder(),
          filled: true,
          suffix: suffix,
          hoverColor: Theme.of(context).hoverColor,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d+\.?\d*)$')),
        ],
        onChanged: (value) {
          if (onChanged != null) {
            onChanged(value);
          }
          if (value.isNotEmpty) {
            double currentValue = double.parse(value);
            if (currentValue > maxValue) {
              controller.text = maxValue.toStringAsFixed(2);
            }
          }
        },
      ),
    );
  }

  Widget _buildRemovableArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _onRemove(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_circle_outline, color: Colors.red),
      ),
    );
  }

  void _onRemove(BuildContext context) async {
    final confirm = await showAlertDialog(context,
        message: '¿Deseas eliminar este Deposito?', title: 'Eliminar Deposito');
    if (confirm == true) {
      widget.onRemove(widget.deposito);
    }
  }
}
