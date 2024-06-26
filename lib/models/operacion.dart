import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/movimientos.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Operacion extends ModeloBase {
  Cliente cliente;
  Cuenta cuentaEntrante;
  Cuenta cuentaSaliente;
  double monto;
  Tasa tasa;
  DateTime fecha;
  List<Movimientos> movimimentos;

  Operacion(
      {String? id,
      DateTime? ultimaModificacion,
      required this.cliente,
      required this.cuentaEntrante,
      required this.fecha,
      required this.tasa,
      required this.cuentaSaliente,
      required this.monto,
      required this.movimimentos})
      : super(
            id: id ?? database.operacionesRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  Reference get referenciaComprobanteOne {
    return storage.operacionesRef.child('$id-1.png');
  }

  Reference get referenciaComprobanteTwo {
    return storage.operacionesRef.child('$id-2.png');
  }

  Reference get referenciaComprobanteThree {
    return storage.operacionesRef.child('$id-3.png');
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
      cuentaSaliente: cuentaSaliente,
      cliente: cliente,
      cuentaEntrante: cuentaEntrante,
      fecha: (snapshot.get('fecha') as Timestamp).toDate(),
      tasa: Tasa.fromJson(
          map: snapshot.get('tasa'),
          monedaEntrante: cuentaEntrante.moneda,
          monedaSaliente: cuentaSaliente.moneda),
      monto: snapshot.get('monto'),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
      movimimentos: [],
    );
  }

  factory Operacion.fromSnapshotById(
      {required DocumentSnapshot snapshot,
      required Cliente cliente,
      required Cuenta cuentaEntrante,
      required List<Movimientos> movimientos,
      required Cuenta cuentaSaliente}) {
    return Operacion(
      id: snapshot.id,
      cuentaSaliente: cuentaSaliente,
      cliente: cliente,
      cuentaEntrante: cuentaEntrante,
      fecha: (snapshot.get('fecha') as Timestamp).toDate(),
      tasa: Tasa.fromJson(
          map: snapshot.get('tasa'),
          monedaEntrante: cuentaEntrante.moneda,
          monedaSaliente: cuentaSaliente.moneda),
      monto: snapshot.get('monto'),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
      movimimentos: movimientos,
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
      'ultimaModificacion': ultimaModificacion ?? DateTime.now(),
    };
  }

  @override
  Future insert() async {
    await super.insert();
    for (var movimiento in movimimentos) {
      movimiento.idOperacion = id;
      await movimiento.insert();
    }
  }

  @override
  Future update() async {
    await super.update();
    for (var movimiento in movimimentos) {
      movimiento.idOperacion = id;
      await movimiento.update();
    }
  }

  @override
  String toString() {
    return '${cliente.nombre} ${cliente.apellido}';
  }
}
