import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/providers/code_verification.dart';
import 'package:cambio_veraz/ui/pages/operacion/model/info_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GananciaPerdidaTile extends StatefulWidget {
  final Operacion operacion;
  final void Function(Operacion) onRemove;

  const GananciaPerdidaTile({
    super.key,
    required this.operacion,
    required this.onRemove,
  });

  @override
  State<GananciaPerdidaTile> createState() => _GananciaPerdidaTileState();
}

class _GananciaPerdidaTileState extends State<GananciaPerdidaTile> {
  final DateFormat format = DateFormat.yMd('es');

  Future<String>? referenceComprobanteOne;
  Future<String>? referenceComprobanteTwo;
  Future<String>? referenceComprobanteThree;
  bool loading = false;
  Operacion? operacion;
  @override
  Widget build(BuildContext context) {
    final codeProvider = context.watch<CodeVerificationProvider>();
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
