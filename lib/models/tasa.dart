import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tasa extends ModeloBase {
  String nombre;
  Moneda monedaEntrante;
  Moneda monedaSaliente;
  double tasa;
  bool tasaEntrante;
  DateTime? ultimaActualizacion;

  Tasa(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.monedaEntrante,
      required this.monedaSaliente,
      required this.tasa,
      required this.tasaEntrante})
      : super(
            id: id ?? database.tasasRef.doc().id,
            ultimaModificacion: ultimaModificacion);

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
        tasa: map["tasa"],
        tasaEntrante: map['tasaEntrante'],
        ultimaModificacion: map['ultimaModificacion']);
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
      tasaEntrante: snapshot.get('tasaEntrante'),
      tasa: snapshot.get('tasa'),
      ultimaModificacion: snapshot.get('ultimaModificacion').toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'monedaEntrante': monedaEntrante.ref,
      'monedaSaliente': monedaSaliente.ref,
      'tasa': tasa,
      'tasaEntrante': tasaEntrante,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }
}
