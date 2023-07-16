import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ModeloBase {
  String id;

  ModeloBase({required this.id});

  DocumentReference get ref;

  Map<String, dynamic> toJson();

  Future insert() async {
    ref.set(toJson());
  }

  @override
  String toString();
}
