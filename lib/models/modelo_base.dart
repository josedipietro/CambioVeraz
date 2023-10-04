import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ModeloBase {
  String id;
  DateTime? ultimaModificacion;

  ModeloBase({required this.id, this.ultimaModificacion});

  DocumentReference get ref;

  Map<String, dynamic> toJson();

  Future insert() async {
    await ref.set(toJson());
    return true;
  }

  Future delete() async {
    if ((await ref.get()).exists) {
      await ref.delete();
      return true;
    } else {
      return false;
    }
  }

  Future update() async {
    await ref.update(toJson());
    return true;
  }

  @override
  String toString();
}
