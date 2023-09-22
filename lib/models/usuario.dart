import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario extends ModeloBase {
  String email;
  String? nombre;

  Usuario({String? id, required this.email, this.nombre})
      : super(id: id ?? database.tasasRef.doc().id);

  @override
  DocumentReference<Object?> get ref => database.usuariosRef.doc(id);

  factory Usuario.fromSnapshot(DocumentSnapshot snapshot) {
    return Usuario(
        id: snapshot.id,
        email: snapshot.get('email'),
        nombre: snapshot.get('nombre'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'email': email};
  }
}
