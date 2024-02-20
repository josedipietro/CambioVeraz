import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/models/rol.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario extends ModeloBase {
  String email;
  String nombre;
  Rol rol;

  Usuario(
      {String? id,
      DateTime? ultimaModificacion,
      required this.email,
      required this.nombre,
      required this.rol})
      : super(
            id: id ?? database.tasasRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  @override
  DocumentReference<Object?> get ref => database.usuariosRef.doc(id);

  factory Usuario.fromSnapshot(DocumentSnapshot snapshot, Rol rol) {
    return Usuario(
      id: snapshot.id,
      email: snapshot.get('email'),
      nombre: snapshot.get('nombre'),
      rol: rol,
      ultimaModificacion: snapshot.get('ultimaModificacion').toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol.ref,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }
}
