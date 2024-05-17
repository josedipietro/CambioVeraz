import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/opreacion_elemento.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovimientosCuentasTile extends StatelessWidget {
  final IngresoEgresos operacion;
  final void Function(Operacion) onRemove;
  final DateFormat format = DateFormat.yMd('es');

  MovimientosCuentasTile({
    super.key,
    required this.operacion,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
          // _buildDetailsArea(),
          // _buildAddPhotoArea(),
          // _buildEditArea(),
          // _buildRemovableArea(context),
        ],
      ),
    );
  }

  Widget _buildEditArea() {
    return GestureDetector(
      onTap: () => _onEdit(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.edit, color: Colors.blue),
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
              operacion.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
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
            '${operacion.cuentaEntrante.moneda.simbolo}${calcularDinero(operacion.monto, operacion.comision, operacion.bono, operacion.comisionFija).toStringAsFixed(2)}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: operacion.operacion ? Colors.green : Colors.red,
            ),
          ),
          Text(
            '${operacion.cuentaSaliente.moneda.simbolo}1 - ${operacion.tasa.monedaEntrante.simbolo}${operacion.tasa.tasaEntrante ? operacion.tasa.tasa : 1 / operacion.tasa.tasa}',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          if (operacion.comision != '0' && operacion.comision != '')
            Text(
              'Comision: ${operacion.comision}%',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          if (operacion.bono != '0' && operacion.bono != '')
            Text(
              'Bono: ${operacion.tasa.monedaEntrante.simbolo}${operacion.bono}',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          if (operacion.comisionFija != '0' && operacion.comisionFija != '')
            Text(
              'Comision fija: ${operacion.tasa.monedaEntrante.simbolo}${operacion.comisionFija}',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
        ],
      ),
    ));
  }

  double calcularDinero(
      double monto, String comision, String bono, String comisionFija) {
    return (monto * (double.parse(comision) ?? 0.0) / 100 +
        monto +
        double.parse(comisionFija) -
        double.parse(bono));
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

  Widget _buildDetailsArea() {
    return GestureDetector(
      onTap: () {},
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_red_eye_rounded, color: Colors.blue),
      ),
    );
  }

  Widget _buildAddPhotoArea() {
    return GestureDetector(
      onTap: () {},
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.receipt, color: Colors.blue),
      ),
    );
  }

  void _onRemove(BuildContext context) async {
    final confirm = await showAlertDialog(context,
        message: '¿Deseas eliminar esta Operación?',
        title: 'Eliminar Operación');
  }

  void _onEdit() async {}
}
