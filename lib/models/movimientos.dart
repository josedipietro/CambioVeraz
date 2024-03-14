import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Movimientos extends ModeloBase {
  String idOperacion;
  Cuenta? cuentaEntrante;
  Cuenta? cuentaSaliente;
  TextEditingController monto;

  Movimientos({
    required this.idOperacion,
    required this.cuentaEntrante,
    required this.cuentaSaliente,
    required this.monto,
    String? id,
    DateTime? ultimaModificacion,
  }) : super(
            id: id ??
                database.operacionesRef
                    .doc(idOperacion)
                    .collection('movimientos')
                    .doc()
                    .id,
            ultimaModificacion: ultimaModificacion);

  DocumentReference<Object?> get operacionRef =>
      database.operacionesRef.doc(idOperacion);

  @override
  Map<String, dynamic> toJson() {
    return {
      'cuentaEntrante': cuentaEntrante!.ref,
      'cuentaSaliente': cuentaSaliente!.ref,
      'monto': double.parse(monto.text),
    };
  }

  @override
  DocumentReference<Object?> get ref =>
      operacionRef.collection('movimientos').doc(id);
}
