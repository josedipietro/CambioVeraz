import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/router/router.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/navigation_service.dart';
import 'package:cambio_veraz/ui/pages/operacion/model/info_class.dart';
import 'package:cambio_veraz/ui/shared/confirm_dialog.dart';
import 'package:cambio_veraz/ui/shared/view_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OperacionTile extends StatefulWidget {
  final Operacion operacion;
  final void Function(Operacion) onRemove;

  const OperacionTile({
    super.key,
    required this.operacion,
    required this.onRemove,
  });

  @override
  State<OperacionTile> createState() => _OperacionTileState();
}

class _OperacionTileState extends State<OperacionTile> {
  final DateFormat format = DateFormat.yMd('es');
  Reference? referenceComprobante;
  bool loading = false;
  Operacion? operacion;
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
          loading
              ? const Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : _buildDetailsArea(context),
          _buildAddPhotoArea(),
          _buildEditArea(),
          _buildRemovableArea(context),
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
              widget.operacion.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              format.format(widget.operacion.fecha),
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
            '${widget.operacion.cuentaEntrante.moneda.simbolo}${widget.operacion.monto}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          Text(
            '${widget.operacion.cuentaEntrante.moneda.simbolo}1 - ${widget.operacion.tasa.monedaSaliente.simbolo}${widget.operacion.tasa.tasa}',
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    ));
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

  Widget _buildDetailsArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _onView(context),
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

  void _onView(BuildContext context) async {
    setState(() {
      loading = true;
    });
    inicializarCampo().then((_) async {
      referenceComprobante = operacion?.referenciaComprobante;
      final confirm = await showViewDialog(
        context,
        content: !loading
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Cuenta entrante',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InfoWidget(
                        one: InfoInputDesing(
                            title: 'Nombre del titular',
                            subtitle: operacion!.cuentaEntrante.nombreTitular),
                        two: InfoInputDesing(
                            title: 'Numero de la cuenta',
                            subtitle: operacion!.cuentaEntrante.numeroCuenta),
                        three: InfoInputDesing(
                            title: 'Tipo de moenda',
                            subtitle:
                                operacion!.cuentaEntrante.moneda.nombreISO),
                        four: InfoInputDesing(title: '', subtitle: ''),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'Cuentas salientes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: List.generate(
                          operacion!.movimimentos.length,
                          (index) {
                            final movimiento = operacion!.movimimentos[index];
                            return Column(
                              children: [
                                InfoWidget(
                                  one: InfoInputDesing(
                                      title: 'Nombre del titular',
                                      subtitle: movimiento
                                          .cuentaEntrante!.nombreTitular),
                                  two: InfoInputDesing(
                                      title: 'Numero de la cuenta',
                                      subtitle: movimiento
                                          .cuentaEntrante!.numeroCuenta),
                                  three: InfoInputDesing(
                                      title: 'Tipo de moenda',
                                      subtitle: movimiento
                                          .cuentaEntrante!.moneda.nombreISO),
                                  four: InfoInputDesing(
                                      title: 'Monto',
                                      subtitle:
                                          movimiento.monto.text.toString()),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Text(
                        'Comprobantes anexados',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      FutureBuilder<String?>(
                        future: referenceComprobante?.getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Image.network(snapshot.data!);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              operacion!.monto.toString(),
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Tasa:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${operacion!.cuentaEntrante.moneda.simbolo}1 - ${operacion!.tasa.monedaSaliente.simbolo}${operacion!.tasa.tasa}',
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : const Text('data'),
        title: 'Eliminar Operación',
      );
      if (confirm == true) {}
    });
  }

  inicializarCampo() async {
    final operacionRequest =
        await database.getOperacionById(widget.operacion.id);
    // referenceComprobante =
    //     widget.operacion.getreferenciaComprobante(widget.operacion.id);
    setState(() {
      operacion = operacionRequest;
      loading = false;
    });
  }

  void _onRemove(BuildContext context) async {
    final confirm = await showAlertDialog(context,
        message: '¿Deseas eliminar esta Operación?',
        title: 'Eliminar Operación');
    if (confirm == true) {
      widget.onRemove(widget.operacion);
    }
  }

  void _onEdit() async {
    NavigationService.navigateTo(Flurorouter.editarOperacionRoute
        .replaceFirst(':id', widget.operacion.id));
  }

  @override
  void initState() {
    super.initState();
  }
}

class InfoWidget extends StatelessWidget {
  InfoInputDesing one;
  InfoInputDesing two;
  InfoInputDesing three;
  InfoInputDesing? four;
  InfoWidget(
      {super.key,
      required this.one,
      required this.two,
      required this.three,
      this.four});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  (four != null ? 0.225 : 0.30),
              child: Center(
                child: InputDesing(
                  title: one.title,
                  content: one.subtitle,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  (four != null ? 0.225 : 0.30),
              child: Center(
                child: InputDesing(
                  title: two.title,
                  content: two.subtitle,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  (four != null ? 0.225 : 0.30),
              child: Center(
                child: InputDesing(
                  title: three.title,
                  content: three.subtitle,
                ),
              ),
            ),
            if (four != null)
              SizedBox(
                width: MediaQuery.of(context).size.width *
                    (four != null ? 0.225 : 0.30),
                child: Center(
                  child: InputDesing(
                    title: four!.title,
                    content: four!.subtitle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class InputDesing extends StatelessWidget {
  String title;
  String content;
  InputDesing({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14,
          ),
        ),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
