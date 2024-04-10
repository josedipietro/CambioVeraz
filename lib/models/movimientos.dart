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
  TextEditingController comision;
  TextEditingController bono;

  Movimientos({
    required this.idOperacion,
    required this.cuentaEntrante,
    required this.cuentaSaliente,
    required this.monto,
    required this.bono,
    required this.comision,
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

  factory Movimientos.fromSnapshot(
      {required QueryDocumentSnapshot snapshot,
      required Cuenta cuentaEntrante,
      required Cuenta cuentaSaliente}) {
    return Movimientos(
        id: snapshot.id,
        idOperacion: '1',
        cuentaEntrante: cuentaEntrante,
        cuentaSaliente: cuentaSaliente,
        monto: TextEditingController(text: snapshot.get('monto').toString()),
        bono: TextEditingController(text: snapshot.get('bono').toString()),
        comision:
            TextEditingController(text: snapshot.get('comision').toString()));
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'cuentaEntrante': cuentaEntrante!.ref,
      'cuentaSaliente': cuentaSaliente!.ref,
      'monto': double.parse(monto.text),
      'comision': double.parse(comision.text),
      'bono': double.parse(bono.text)
    };
  }

  @override
  DocumentReference<Object?> get ref =>
      operacionRef.collection('movimientos').doc(id);
}
