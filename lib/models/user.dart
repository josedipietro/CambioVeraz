import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends ModeloBase {
  String? email;
  String? nombre;

  User({required id, this.email, this.nombre}) : super(id: id);

  @override
  DocumentReference<Object?> get ref => database.usuariosRef.doc(id);

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    return User(
        id: snapshot.id,
        email: snapshot.get('email'),
        nombre: snapshot.get('nombre'));
  }

  @override
  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'email': email};
  }
}
