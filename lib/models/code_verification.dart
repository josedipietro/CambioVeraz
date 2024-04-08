import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CodeVerification extends ModeloBase {
  String code;

  CodeVerification({
    String? id,
    DateTime? ultimaModificacion,
    required this.code,
  }) : super(
          id: id ?? database.codeRef.doc().id,
        );

  @override
  get ref => database.codeRef.doc(id);

  factory CodeVerification.fromSnapshot(DocumentSnapshot snapshot) {
    return CodeVerification(
      id: snapshot.id,
      code: snapshot.get('code'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}
