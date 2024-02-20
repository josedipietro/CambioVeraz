import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Operacion extends ModeloBase {
  Cliente cliente;
  Cuenta cuentaEntrante;
  Cuenta cuentaSaliente;
  double monto;
  Tasa tasa;
  DateTime fecha;

  Operacion(
      {String? id,
      DateTime? ultimaModificacion,
      required this.cliente,
      required this.cuentaEntrante,
      required this.cuentaSaliente,
      required this.fecha,
      required this.tasa,
      required this.monto})
      : super(
            id: id ?? database.operacionesRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  get referenciaComprobante {
    return storage.operacionesRef.child('$id.png');
  }

  @override
  DocumentReference<Object?> get ref => database.operacionesRef.doc(id);

  factory Operacion.fromSnapshot(
      {required QueryDocumentSnapshot snapshot,
      required Cliente cliente,
      required Cuenta cuentaEntrante,
      required Cuenta cuentaSaliente}) {
    return Operacion(
      id: snapshot.id,
      cliente: cliente,
      cuentaEntrante: cuentaEntrante,
      cuentaSaliente: cuentaSaliente,
      fecha: (snapshot.get('fecha') as Timestamp).toDate(),
      tasa: Tasa.fromJson(
          map: snapshot.get('tasa'),
          monedaEntrante: cuentaEntrante.moneda,
          monedaSaliente: cuentaSaliente.moneda),
      monto: snapshot.get('monto'),
      ultimaModificacion: snapshot.get('ultimaModificacion').toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente.ref,
      'cuentaEntrante': cuentaEntrante.ref,
      'cuentaSaliente': cuentaSaliente.ref,
      'fecha': fecha,
      'tasa': tasa.toJson(),
      'monto': monto,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }

  @override
  String toString() {
    return '${cliente.nombre} ${cliente.apellido}';
  }
}
