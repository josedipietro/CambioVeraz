import 'package:cambio_veraz/models/modelo_base.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Moneda extends ModeloBase {
  String nombre;
  String nombreISO;
  String simbolo;

  Moneda(
      {String? id,
      DateTime? ultimaModificacion,
      required this.nombre,
      required this.nombreISO,
      required this.simbolo})
      : super(
            id: id ?? database.monedasRef.doc().id,
            ultimaModificacion: ultimaModificacion);

  @override
  get ref => database.monedasRef.doc(id);

  factory Moneda.fromSnapshot(DocumentSnapshot snapshot) {
    return Moneda(
      id: snapshot.id,
      nombre: snapshot.get('nombre'),
      nombreISO: snapshot.get('nombreISO'),
      simbolo: snapshot.get('simbolo'),
      ultimaModificacion: snapshot.toString().contains('ultimaModificacion')
          ? snapshot.get('ultimaModificacion').toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'nombreISO': nombreISO,
      'simbolo': simbolo,
      'ultimaModificacion': ultimaModificacion ?? DateTime.now()
    };
  }

  @override
  String toString() {
    return '$nombreISO ($simbolo)';
  }
}
