import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/operacion.dart';
import 'package:cambio_veraz/models/rol.dart';
import 'package:cambio_veraz/models/tasa.dart';
import 'package:cambio_veraz/models/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _Database {
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  late CollectionReference operacionesRef;
  late CollectionReference clientesRef;
  late CollectionReference monedasRef;
  late CollectionReference tasasRef;
  late CollectionReference arcasRef;
  late CollectionReference cuentasRef;
  late CollectionReference rolesRef;
  late CollectionReference usuariosRef;

  _Database() {
    operacionesRef = instance.collection('operaciones');
    clientesRef = instance.collection('clientes');
    monedasRef = instance.collection('monedas');
    tasasRef = instance.collection('tasas');
    arcasRef = instance.collection('arcas');
    cuentasRef = instance.collection('cuentas');
    rolesRef = instance.collection('roles');
    usuariosRef = instance.collection('usuarios');
  }

  Future<List<Operacion>> get operaciones async {
    final opSnapshot =
        await operacionesRef.orderBy('fecha', descending: true).get();

    final List<Operacion> operaciones = [];

    for (var e in opSnapshot.docs) {
      final cliente = await getClienteByReference(e.get('cliente'));
      final cuentaEntrante =
          await getCuentaByReference(e.get('cuentaEntrante'));
      final cuentaSaliente =
          await getCuentaByReference(e.get('cuentaSaliente'));

      operaciones.add(Operacion.fromSnapshot(
        snapshot: e,
        cliente: cliente,
        cuentaEntrante: cuentaEntrante,
        cuentaSaliente: cuentaSaliente,
      ));
    }

    return operaciones;
  }

  Stream<Future<List<Operacion>>> get operacionesStream {
    return operacionesRef
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((opSnapshot) async {
      final List<Operacion> operaciones = [];

      for (var e in opSnapshot.docs) {
        final cliente = await getClienteByReference(e.get('cliente'));
        final cuentaEntrante =
            await getCuentaByReference(e.get('cuentaEntrante'));
        final cuentaSaliente =
            await getCuentaByReference(e.get('cuentaSaliente'));

        operaciones.add(Operacion.fromSnapshot(
          snapshot: e,
          cliente: cliente,
          cuentaEntrante: cuentaEntrante,
          cuentaSaliente: cuentaSaliente,
        ));
      }

      return operaciones;
    });
  }

  Future<List<Cliente>> get clientes async {
    final cliSnapshot = await clientesRef.get();

    final List<Cliente> clientes =
        cliSnapshot.docs.map((e) => Cliente.fromSnapshot(e)).toList();

    return clientes;
  }

  Stream<List<Cliente>> get clientesStream {
    return clientesRef
        .orderBy('nombre', descending: true)
        .snapshots()
        .map((opSnapshot) {
      final List<Cliente> operaciones = [];

      for (var e in opSnapshot.docs) {
        operaciones.add(Cliente.fromSnapshot(e));
      }

      return operaciones;
    });
  }

  Future<List<Cuenta>> get cuentas async {
    final cliSnapshot = await cuentasRef.orderBy('nombre').get();

    final List<Cuenta> cuentas = [];

    for (var e in cliSnapshot.docs) {
      final moneda = await getMonedaByReference(e.get('moneda'));

      cuentas.add(Cuenta.fromSnapshot(snapshot: e, moneda: moneda));
    }

    return cuentas;
  }

  Stream<Future<List<Cuenta>>> get cuentasStream {
    return cuentasRef.orderBy('nombre').snapshots().map((opSnapshot) async {
      final List<Cuenta> operaciones = [];

      for (var e in opSnapshot.docs) {
        final moneda = await getMonedaByReference(e.get('moneda'));

        operaciones.add(Cuenta.fromSnapshot(snapshot: e, moneda: moneda));
      }

      return operaciones;
    });
  }

  Future<List<Moneda>> get monedas async {
    final snapshot = await monedasRef.get();

    final List<Moneda> list = [];

    for (var e in snapshot.docs) {
      list.add(Moneda.fromSnapshot(e));
    }

    return list;
  }

  Stream<List<Moneda>> get monedasStream {
    return monedasRef.orderBy('nombre').snapshots().map((opSnapshot) {
      final List<Moneda> operaciones = [];

      for (var e in opSnapshot.docs) {
        operaciones.add(Moneda.fromSnapshot(e));
      }

      return operaciones;
    });
  }

  Future<List<Tasa>> get tasas async {
    final snapshot = await tasasRef.get();

    final List<Tasa> list = [];

    for (var e in snapshot.docs) {
      final monedaEntrante =
          await getMonedaByReference(e.get('monedaEntrante'));
      final monedaSaliente =
          await getMonedaByReference(e.get('monedaSaliente'));

      list.add(Tasa.fromSnapshot(
          snapshot: e,
          monedaEntrante: monedaEntrante,
          monedaSaliente: monedaSaliente));
    }

    return list;
  }

  Stream<Future<List<Tasa>>> get tasasStream {
    return tasasRef.orderBy('nombre').snapshots().map((opSnapshot) async {
      final List<Tasa> operaciones = [];

      for (var e in opSnapshot.docs) {
        final monedaEntrante =
            await getMonedaByReference(e.get('monedaEntrante'));
        final monedaSaliente =
            await getMonedaByReference(e.get('monedaSaliente'));

        operaciones.add(Tasa.fromSnapshot(
            snapshot: e,
            monedaEntrante: monedaEntrante,
            monedaSaliente: monedaSaliente));
      }

      return operaciones;
    });
  }

  Future<List<Deposito>> get arcas async {
    final snapshot = await arcasRef.get();

    final List<Deposito> list = [];

    for (var e in snapshot.docs) {
      final cuentaReceptora =
          await getCuentaByReference(e.get('cuentaReceptora'));

      list.add(
          Deposito.fromSnapshot(snapshot: e, cuentaReceptora: cuentaReceptora));
    }

    return list;
  }

  Stream<Future<List<Deposito>>> get arcasStream {
    return arcasRef
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((opSnapshot) async {
      final List<Deposito> operaciones = [];

      for (var e in opSnapshot.docs) {
        final cuentaReceptora =
            await getCuentaByReference(e.get('cuentaReceptora'));

        operaciones.add(Deposito.fromSnapshot(
            snapshot: e, cuentaReceptora: cuentaReceptora));
      }

      return operaciones;
    });
  }

  Future<List<Rol>> get roles async {
    final snapshot = await rolesRef.get();

    return snapshot.docs.map<Rol>((e) => Rol.fromSnapshot(e)).toList();
  }

  Future<List<Usuario>> get usuarios async {
    final snapshot = await usuariosRef.get();

    return snapshot.docs.map<Usuario>((e) => Usuario.fromSnapshot(e)).toList();
  }

  Future<Usuario> getUsuarioById(String id) async {
    final snapshot = await usuariosRef.doc(id).get();

    final usuario = Usuario.fromSnapshot(snapshot);

    return usuario;
  }

  Future<Usuario> getUsuarioByReference(DocumentReference ref) async {
    final snapshot = await usuariosRef.doc(ref.id).get();

    final usuario = Usuario.fromSnapshot(snapshot);

    return usuario;
  }

  Future<Cliente> getClienteById(String id) async {
    final cliSnapshot = await clientesRef.doc(id).get();

    final cliente = Cliente.fromSnapshot(cliSnapshot);

    return cliente;
  }

  Future<Cliente> getClienteByReference(DocumentReference ref) async {
    final cliSnapshot = await clientesRef.doc(ref.id).get();

    final cliente = Cliente.fromSnapshot(cliSnapshot);

    return cliente;
  }

  Future<Moneda> getMonedaById(String id) async {
    final monSnapshot = await monedasRef.doc(id).get();

    final moneda = Moneda.fromSnapshot(monSnapshot);

    return moneda;
  }

  Future<Moneda> getMonedaByReference(DocumentReference ref) async {
    final monSnapshot = await monedasRef.doc(ref.id).get();

    final moneda = Moneda.fromSnapshot(monSnapshot);

    return moneda;
  }

  Future<Cuenta> getCuentaById(String id) async {
    final cuenSnapshot = await cuentasRef.doc(id).get();

    final moneda = await getMonedaByReference(cuenSnapshot.get('moneda'));

    final cuenta = Cuenta.fromSnapshot(snapshot: cuenSnapshot, moneda: moneda);

    return cuenta;
  }

  Future<Cuenta> getCuentaByReference(DocumentReference ref) async {
    final cuenSnapshot = await cuentasRef.doc(ref.id).get();

    final moneda = await getMonedaByReference(cuenSnapshot.get('moneda'));

    final cuenta = Cuenta.fromSnapshot(snapshot: cuenSnapshot, moneda: moneda);

    return cuenta;
  }

  Future<double> getBalanceCuenta(Cuenta cuenta) async {
    final depositosList = await arcas;
    final operacionesList = await operaciones;

    final depositos = depositosList
        .where((element) => element.cuentaReceptora.id == cuenta.id);

    final operacionesRecibe = operacionesList
        .where((element) => element.cuentaEntrante.id == cuenta.id);

    final operacionesEnvia = operacionesList
        .where((element) => element.cuentaSaliente.id == cuenta.id);

    double balance = 0;

    for (var element in depositos) {
      balance += element.monto;
    }

    for (var element in operacionesRecibe) {
      balance += element.monto;
    }

    for (var element in operacionesEnvia) {
      balance -= element.monto * element.tasa.tasa;
    }

    return balance;
  }
}

final database = _Database();
