import 'package:firebase_storage/firebase_storage.dart';

class _Storage {
  Reference get ref => FirebaseStorage.instance.ref();
  Reference get imagenesRef => ref.child('imagenes');
  Reference get fotosRef => imagenesRef.child('fotos');
  Reference get cedulasRef => imagenesRef.child('cedulas');
  Reference get operacionesRef => imagenesRef.child('operaciones');
  Reference get arcasRef => imagenesRef.child('depositos');
}

final storage = _Storage();
