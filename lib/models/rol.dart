import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rol extends ModeloBase {
  String nombre;
  bool admin;
  List permisos;

  Rol(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.admin,
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
      admin: snapshot.get('admin'),
      permisos: snapshot.get('permisos'),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'permisos': permisos,
      'admin': admin,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }
}
