import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Arca extends ModeloBase {
  Cuenta cuentaReceptora;
  double monto;
  double tasa;
  DateTime fecha;

  Arca(
      {String? id,
      required this.cuentaReceptora,
      required this.monto,
      required this.tasa,
      required this.fecha})
      : super(id: id ?? database.arcasRef.doc().id);

  @override
  DocumentReference get ref => database.arcasRef.doc(id);

  factory Arca.fromSnapshot(
      {required DocumentSnapshot snapshot, required Cuenta cuentaReceptora}) {
    return Arca(
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
      'cuentaReceptora': cuentaReceptora.ref
    };
  }
}
