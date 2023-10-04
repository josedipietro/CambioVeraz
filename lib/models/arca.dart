import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Deposito extends ModeloBase {
  Cuenta cuentaReceptora;
  double monto;
  double tasa;
  DateTime fecha;

  Deposito(
      {String? id,
      DateTime? ultimaModificacion,
      required this.cuentaReceptora,
      required this.monto,
      required this.tasa,
      required this.fecha})
      : super(
            id: id ?? database.arcasRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  @override
  DocumentReference get ref => database.arcasRef.doc(id);

  get referenciaComprobante {
    return storage.arcasRef.child(id);
  }

  factory Deposito.fromSnapshot(
      {required DocumentSnapshot snapshot, required Cuenta cuentaReceptora}) {
    return Deposito(
        id: snapshot.id,
        cuentaReceptora: cuentaReceptora,
        monto: snapshot.get('monto'),
        fecha: (snapshot.get('fecha') as Timestamp).toDate(),
        tasa: snapshot.get('tasa'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'monto': monto,
      'tasa': tasa,
      'cuentaReceptora': cuentaReceptora.ref,
      'fecha': fecha,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return cuentaReceptora.nombre;
  }
}
