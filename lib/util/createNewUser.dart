import 'package:cambio_veraz/firebase_options.dart';
import 'package:cambio_veraz/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

createNewUser(Usuario usuario, String password) async {
  FirebaseApp auxApp = await Firebase.initializeApp(
      name: 'auxApp', options: DefaultFirebaseOptions.currentPlatform);

  FirebaseAuth auth = FirebaseAuth.instanceFor(app: auxApp);

  await auth.createUserWithEmailAndPassword(
    email: usuario.email!,
    password: password,
  );
}
