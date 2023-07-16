import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tasa extends ModeloBase {
  String nombre;
  Moneda monedaEntrante;
  Moneda monedaSaliente;
  double tasa;

  Tasa(
      {String? id,
      required this.nombre,
      required this.monedaEntrante,
      required this.monedaSaliente,
      required this.tasa})
      : super(id: id ?? database.tasasRef.doc().id);

  @override
  DocumentReference<Object?> get ref => database.tasasRef.doc(id);

  factory Tasa.fromJson(
      {required Map<String, dynamic> map,
      required Moneda monedaEntrante,
      required Moneda monedaSaliente}) {
    return Tasa(
        id: map['id'],
        nombre: map['nombre'],
        monedaEntrante: monedaEntrante,
        monedaSaliente: monedaSaliente,
        tasa: map["tasa"]);
  }

  factory Tasa.fromSnapshot(
      {required DocumentSnapshot snapshot,
      required Moneda monedaEntrante,
      required Moneda monedaSaliente}) {
    return Tasa(
        id: snapshot.id,
        nombre: snapshot.get('nombre'),
        monedaEntrante: monedaEntrante,
        monedaSaliente: monedaSaliente,
        tasa: snapshot.get('tasa'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'monedaEntrante': monedaEntrante.ref,
      'monedaSaliente': monedaSaliente.ref,
      'tasa': tasa
    };
  }
}
