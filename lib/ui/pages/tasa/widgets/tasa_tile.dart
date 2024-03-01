import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasaTile extends StatelessWidget {
  final Tasa tasa;
  final void Function(Tasa) onRemove;

  const TasaTile({
    super.key,
    required this.tasa,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat.yMd('es');

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
          Expanded(
              child: Column(
            children: [
              tasa.tasaEntrante
                  ? Text(
                      '${tasa.monedaEntrante.simbolo}1 - ${tasa.monedaSaliente.simbolo}${tasa.tasa}')
                  : Text(
                      '${tasa.monedaSaliente.simbolo}1 - ${tasa.monedaEntrante.simbolo}${(1 / tasa.tasa).toStringAsFixed(2)}'),
              Text(format.format(tasa.ultimaModificacion ?? DateTime.now()))
            ],
          )),
          _buildEditArea(),
          _buildRemovableArea(context),
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
              tasa.nombre,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              '${tasa.monedaEntrante.toString()} - ${tasa.monedaSaliente.toString()}',
              style: const TextStyle(
                fontSize: 12,
              ),
            )
          ],
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

  Widget _buildEditArea() {
    return GestureDetector(
      onTap: () => _onEdit(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.edit, color: Colors.blue),
      ),
    );
  }

  Widget _buildDetailsArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _onRemove(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.remove_circle_outline, color: Colors.red),
      ),
    );
  }

  void _onEdit() async {
    NavigationService.navigateTo(
        Flurorouter.editarTasaRoute.replaceFirst(':id', tasa.id));
  }

  void _onRemove(BuildContext context) async {
    final confirm = await showAlertDialog(context,
        message: '¿Deseas eliminar esta tasa?', title: 'Eliminar Tasa');
    if (confirm == true) {
      onRemove(tasa);
    }
  }
}
