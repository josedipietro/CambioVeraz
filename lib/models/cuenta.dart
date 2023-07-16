import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cuenta extends ModeloBase {
  String nombre;
  Moneda moneda;
  String nombreTitular;
  int numeroCuenta;
  int numeroIdentificacion;

  Cuenta(
      {String? id,
      required this.nombre,
      required this.nombreTitular,
      required this.moneda,
      required this.numeroCuenta,
      required this.numeroIdentificacion})
      : super(id: id ?? database.cuentasRef.doc().id);

  @override
  DocumentReference get ref => database.cuentasRef.doc(id);

  factory Cuenta.fromSnapshot(
      {required DocumentSnapshot snapshot, required Moneda moneda}) {
    return Cuenta(
        id: snapshot.id,
        nombre: snapshot.get('nombre'),
        nombreTitular: snapshot.get('nombreTitular'),
        moneda: moneda,
        numeroCuenta: snapshot.get('numeroCuenta'),
        numeroIdentificacion: snapshot.get('numeroIdentificacion'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'moneda': moneda.ref,
      'nombreTitular': nombreTitular,
      'numeroCuenta': numeroCuenta,
      'numeroIdentificacion': numeroIdentificacion,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return nombre;
  }
}
