import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/providers/cuentas_provider.dart';
import 'package:cambio_veraz/providers/depositos_provider.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:cambio_veraz/ui/shared/custom_dropdown.dart';
import 'package:cambio_veraz/ui/shared/view_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
  Deposito? cuentaEntranteSelected;
  TextEditingController montoController = TextEditingController();
  TextEditingController tasaController = TextEditingController();
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
      final confirm = await showViewDialog(
        context,
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomDropdown<Cuenta>(
                      items: cuentasProvider.cuentas,
                      value: cuentasProvider.cuentas.firstWhereOrNull(
                          (element) => element.id == cuentaReceptora!.id),
                      onChange: null,
                      title: 'Cuenta a fondear',
                    ),
                    CustomDropdown<Deposito>(
                      items: depositos.depositos,
                      value: cuentaEntranteSelected,
                      onChange: (cuenta) {
                        setState(() {
                          cuentaEntranteSelected = cuenta;
                          montoCuentaDebitar = cuenta!.monto;
                        });
                      },
                      title: 'Cuenta a debitar',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    buildField(context, 'Monto', montoController,
                        maxLength: 30),
                    buildField(context, 'Tasa', tasaController, maxLength: 30),
                    if (cuentaEntranteSelected != null)
                      Text(
                          "Dinero disponible en la cuenta: ${cuentaEntranteSelected!.monto.toString()}${cuentaEntranteSelected!.cuentaReceptora.moneda.simbolo}"),
                  ],
                ),
              ),
            );
          },
        ),
        title: 'Fondeo',
      );
      if (confirm == true) {
        widget.onRemove(widget.deposito);
      }
    });
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
    });
  }

  Widget buildField(
      BuildContext context, String hintText, TextEditingController controller,
      {int maxLength = 255, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        enableSuggestions: true,
        keyboardType: type,
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
