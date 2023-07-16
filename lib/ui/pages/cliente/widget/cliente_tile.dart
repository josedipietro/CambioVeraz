import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:flutter/material.dart';

class ClienteTile extends StatelessWidget {
  final Cliente cliente;
  final void Function(Cliente) onRemove;

  const ClienteTile({
    super.key,
    required this.cliente,
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
              cliente.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              cliente.cedula,
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

  void _onRemove(BuildContext context) async {
    final confirm = await showAlertDialog(context,
        message: '¿Deseas eliminar esta reservación?',
        title: 'Eliminar Reservación');
    if (confirm == true) {
      onRemove(cliente);
    }
  }
}
