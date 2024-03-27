import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cuenta extends ModeloBase {
  String nombre;
  Moneda moneda;
  String nombreTitular;
  String numeroCuenta;
  String numeroIdentificacion;
  double comision;
  bool preferencia;

  Cuenta(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.preferencia,
      required this.nombreTitular,
      required this.moneda,
      required this.numeroCuenta,
      required this.numeroIdentificacion,
      this.comision = 0})
      : super(
            id: id ?? database.cuentasRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  @override
  DocumentReference get ref => database.cuentasRef.doc(id);

  factory Cuenta.fromSnapshot(
      {required DocumentSnapshot snapshot, required Moneda moneda}) {
    return Cuenta(
      preferencia: snapshot.get('preferencia'),
      id: snapshot.id,
      nombre: snapshot.get('nombre'),
      nombreTitular: snapshot.get('nombreTitular'),
      moneda: moneda,
      comision: snapshot.get('comision') ?? 0,
      numeroCuenta: snapshot.get('numeroCuenta').toString(),
      numeroIdentificacion: snapshot.get('numeroIdentificacion').toString(),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'preferencia': preferencia ?? false,
      'nombre': nombre,
      'moneda': moneda.ref,
      'nombreTitular': nombreTitular,
      'numeroCuenta': numeroCuenta,
      'numeroIdentificacion': numeroIdentificacion,
      'comision': comision,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return nombre;
  }
}
