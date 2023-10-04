import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rol extends ModeloBase {
  String nombre;
  List permisos;

  Rol(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.permisos})
      : super(
            id: id ?? database.rolesRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  @override
  get ref => database.rolesRef.doc(id);

  factory Rol.fromSnapshot(DocumentSnapshot snapshot) {
    return Rol(
        id: snapshot.id,
        nombre: snapshot.get('nombre'),
        permisos: snapshot.get('permisos'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'permisos': permisos,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }
}
