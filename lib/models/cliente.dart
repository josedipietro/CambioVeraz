import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cambio_veraz/services/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Cliente extends ModeloBase {
  String nombre;
  String apellido;
  String telefono;
  String cedula;
  bool activo;

  Cliente(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.apellido,
      required this.cedula,
      required this.activo,
      required this.telefono})
      : super(
            id: id ?? database.clientesRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  Reference get referenciaFoto {
    return storage.fotosRef.child('$id.png');
  }

  Reference get referenciaFotoCedula {
    return storage.cedulasRef.child('$id.png');
  }

  @override
  DocumentReference get ref => database.clientesRef.doc(id);

  factory Cliente.fromSnapshot(DocumentSnapshot snapshot) {
    return Cliente(
      id: snapshot.id,
      nombre:  snapshot.get('nombre'),
      apellido: snapshot.get('apellido'),
      cedula: snapshot.get('cedula'),
      activo: snapshot.get('activo'),
      telefono: snapshot.get('telefono'),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'cedula': cedula,
      'activo': activo,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }

  @override
  String toString() {
    return '$nombre $apellido';
  }
}
