import 'package:cambio_veraz/models/arca.dart';
import 'package:cambio_veraz/models/cliente.dart';
import 'package:cambio_veraz/models/code_verification.dart';
import 'package:cambio_veraz/models/cuenta.dart';
import 'package:cambio_veraz/models/moneda.dart';
import 'package:cambio_veraz/models/movimientos.dart';
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
  late CollectionReference codeRef;

  _Database() {
    operacionesRef = instance.collection('operaciones');
    clientesRef = instance.collection('clientes');
    monedasRef = instance.collection('monedas');
    tasasRef = instance.collection('tasas');
    arcasRef = instance.collection('arcas');
    cuentasRef = instance.collection('cuentas');
    rolesRef = instance.collection('roles');
    codeRef = instance.collection('code');
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

  Stream<List<CodeVerification>> get code {
    return codeRef.snapshots().map((opSnapshot) {
      final List<CodeVerification> code = [];

      for (var e in opSnapshot.docs) {
        code.add(CodeVerification.fromSnapshot(e));
      }

      return code;
    });
  }

  Stream<Future<List<Operacion>>> getoperacionesStream(
      String search, DateTime dateNow, String id) {
    return operacionesRef
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((opSnapshot) async {
      final List<Operacion> operaciones = [];

      for (var e in opSnapshot.docs) {
        final date = e.get('fecha');
        final cliente = await getClienteByReference(e.get('cliente'));
        final cuentaEntrante =
            await getCuentaByReference(e.get('cuentaEntrante'));
        final cuentaSaliente =
            await getCuentaByReference(e.get('cuentaSaliente'));

        if (containsIgnoreCase(cliente.nombre, search)) {
          final actualOperation = Operacion.fromSnapshot(
            snapshot: e,
            cliente: cliente,
            cuentaEntrante: cuentaEntrante,
            cuentaSaliente: cuentaSaliente,
          );

          final date = actualOperation.fecha;
          if (isSameDayMonthYear(date, dateNow) &&
              ((actualOperation.cuentaEntrante.id == id) || id == '')) {
            operaciones.add(actualOperation);
          }
        }
      }

      return operaciones;
    });
  }

  bool isSameDayMonthYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool containsIgnoreCase(String haystack, String needle) {
    final String lowerCaseHaystack = haystack.toLowerCase();
    final String lowerCaseNeedle = needle.toLowerCase();

    return lowerCaseHaystack.contains(lowerCaseNeedle);
  }

  Future<List<Cliente>> get clientes async {
    final cliSnapshot =
        await clientesRef.where('nombre', isEqualTo: 'CARLOS EDUARDO ').get();

    final List<Cliente> clientes =
        cliSnapshot.docs.map((e) => Cliente.fromSnapshot(e)).toList();

    return clientes;
  }

  Stream<List<Cliente>> getclientesStream(String search) {
    return clientesRef
        .orderBy('nombre')
        .startAt([search.toUpperCase()])
        .endAt(["$search\uf8ff".toUpperCase()])
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

  Stream<Future<List<Cuenta>>> get cuentasGroupBy {
    return cuentasRef.orderBy('nombre').snapshots().map((opSnapshot) async {
      final List<Cuenta> operaciones = [];

      for (var e in opSnapshot.docs) {
        final moneda = await getMonedaByReference(e.get('moneda'));

        operaciones.add(Cuenta.fromSnapshot(snapshot: e, moneda: moneda));
      }

      return operaciones;
    });
  }

  Stream<Future<List<Cuenta>>> getcuentasFiltradas(String id, String search) {
    return cuentasRef
        .orderBy('nombre')
        .startAt([search.toUpperCase()])
        .endAt(["$search\uf8ff".toUpperCase()])
        .snapshots()
        .map((opSnapshot) async {
          final List<Cuenta> operaciones = [];

          for (var e in opSnapshot.docs) {
            final moneda = await getMonedaByReference(e.get('moneda'));
            if (moneda.id == id || id == '0') {
              operaciones.add(Cuenta.fromSnapshot(snapshot: e, moneda: moneda));
            }
          }

          return operaciones;
        });
  }

  Stream<Future<List<Cuenta>>> getcuentasFiltradasGrupBy(
      String id, String search) {
    return cuentasRef
        .orderBy('nombre')
        .startAt([search.toUpperCase()])
        .endAt(["$search\uf8ff".toUpperCase()])
        .snapshots()
        .map((opSnapshot) async {
          final List<Cuenta> operaciones = [];

          for (var e in opSnapshot.docs) {
            final moneda = await getMonedaByReference(e.get('moneda'));
            if (moneda.id == id || id == '0') {
              operaciones.add(Cuenta.fromSnapshot(snapshot: e, moneda: moneda));
            }
          }

          return operaciones;
        });
  }

  Stream<Future<Map<String, List<Cuenta>>>> getcuentasAgrupadasPorId(
      String id, String search) {
    return getcuentasFiltradasGrupBy(id, search).map((future) async {
      Map<String, List<Cuenta>> cuentasAgrupadas = {};
      List<Cuenta> cuentas = await future;

      // Agrupar las cuentas por ID
      for (Cuenta cuenta in cuentas) {
        String key = cuenta.id; // Asume que Cuenta tiene un campo llamado 'id'
        if (!cuentasAgrupadas.containsKey(key)) {
          cuentasAgrupadas[key] = [];
        }
        cuentasAgrupadas[key]!.add(cuenta);
      }

      return cuentasAgrupadas;
    });
  }

  Stream<Future<Map<String, List<Cuenta>>>> get cuentasAgrupadasPorIdTwo {
    return cuentasGroupBy.map((future) async {
      Map<String, List<Cuenta>> cuentasAgrupadas = {};
      List<Cuenta> cuentas = await future;

      // Agrupar las cuentas por ID
      for (Cuenta cuenta in cuentas) {
        String key = cuenta.id; // Asume que Cuenta tiene un campo llamado 'id'
        if (!cuentasAgrupadas.containsKey(key)) {
          cuentasAgrupadas[key] = [];
        }
        cuentasAgrupadas[key]!.add(cuenta);
      }

      return cuentasAgrupadas;
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

  Stream<Future<List<Tasa>>> gettasasStream(String search) {
    return tasasRef
        .orderBy('nombre')
        .startAt([search.toUpperCase()])
        .endAt(["$search\uf8ff".toUpperCase()])
        .snapshots()
        .map((opSnapshot) async {
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

    final List<Usuario> list = [];
    for (var e in snapshot.docs) {
      final rol = await getRolByReference(e.get('rol'));

      list.add(Usuario.fromSnapshot(e, rol));
    }

    return list;
  }

  Future<Usuario> getUsuarioById(String id) async {
    final snapshot = await usuariosRef.doc(id).get();
    final rol = await getRolByReference(snapshot.get('rol'));

    final usuario = Usuario.fromSnapshot(snapshot, rol);

    return usuario;
  }

  Future<Deposito> getArcaById(String id) async {
    final snapshot = await arcasRef.doc(id).get();
    final cuentaReceptora =
        await getCuentaByReference(snapshot.get('cuentaReceptora'));

    final usuario = Deposito.fromSnapshot(
        snapshot: snapshot, cuentaReceptora: cuentaReceptora);

    return usuario;
  }

  Future<Usuario> getUsuarioByReference(DocumentReference ref) async {
    final snapshot = await usuariosRef.doc(ref.id).get();
    final rol = await getRolByReference(snapshot.get('rol'));

    final usuario = Usuario.fromSnapshot(snapshot, rol);

    return usuario;
  }

  Future<Rol> getRolById(String id) async {
    final rolSnapshot = await rolesRef.doc(id).get();

    final rol = Rol.fromSnapshot(rolSnapshot);

    return rol;
  }

  Future<Rol> getRolByReference(DocumentReference ref) async {
    final rolSnapshot = await rolesRef.doc(ref.id).get();

    final rol = Rol.fromSnapshot(rolSnapshot);

    return rol;
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

  Future<Tasa> getTasaById(String id) async {
    final tasaSnapshot = await tasasRef.doc(id).get();

    final monedaEntrante =
        await getMonedaByReference(tasaSnapshot.get('monedaEntrante'));
    final monedaSaliente =
        await getMonedaByReference(tasaSnapshot.get('monedaSaliente'));

    final tasa = Tasa.fromSnapshot(
        snapshot: tasaSnapshot,
        monedaEntrante: monedaEntrante,
        monedaSaliente: monedaSaliente);

    return tasa;
  }

  Future<Tasa> getTasaByReference(DocumentReference ref) async {
    final tasaSnapshot = await tasasRef.doc(ref.id).get();

    final monedaEntrante =
        await getMonedaByReference(tasaSnapshot.get('monedaEntrante'));
    final monedaSaliente =
        await getMonedaByReference(tasaSnapshot.get('monedaSaliente'));

    final tasa = Tasa.fromSnapshot(
        snapshot: tasaSnapshot,
        monedaEntrante: monedaEntrante,
        monedaSaliente: monedaSaliente);

    return tasa;
  }

  Future<Cuenta> getCuentaById(String id) async {
    final cuenSnapshot = await cuentasRef.doc(id).get();

    final moneda = await getMonedaByReference(cuenSnapshot.get('moneda'));

    final cuenta = Cuenta.fromSnapshot(snapshot: cuenSnapshot, moneda: moneda);

    return cuenta;
  }

  Future<Operacion> getOperacionById(String id) async {
    final operacionSnapshot = await operacionesRef.doc(id).get();

    final cliente =
        await getClienteByReference(operacionSnapshot.get('cliente'));
    final cuentaEntrante =
        await getCuentaByReference(operacionSnapshot.get('cuentaEntrante'));
    final cuentaSaliente =
        await getCuentaByReference(operacionSnapshot.get('cuentaSaliente'));
    final movimientos = await getMovimientosByOperacionId(id);

    final operacion = Operacion.fromSnapshotById(
        snapshot: operacionSnapshot,
        cliente: cliente,
        cuentaEntrante: cuentaEntrante,
        cuentaSaliente: cuentaSaliente,
        movimientos: movimientos);

    return operacion;
  }

  Stream<Future<List<Operacion>>> getoperacionesIEStream(String search) {
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
        final movimientos = await getMovimientosByOperacionId(e.id.toString());

        if (containsIgnoreCase(cliente.nombre, search)) {
          operaciones.add(Operacion.fromSnapshotById(
              snapshot: e,
              cliente: cliente,
              cuentaEntrante: cuentaEntrante,
              cuentaSaliente: cuentaSaliente,
              movimientos: movimientos));
        }
      }

      return operaciones;
    });
  }

  Future<List<Movimientos>> getMovimientosByOperacionId(String id) async {
    final List<Movimientos> movimientos = [];
    final cuenSnapshot =
        await operacionesRef.doc(id).collection('movimientos').get();
    for (final e in cuenSnapshot.docs) {
      final cuentaEntrante =
          await database.getCuentaByReference(e.get('cuentaEntrante'));
      final cuentaSaliente =
          await database.getCuentaByReference(e.get('cuentaSaliente'));
      movimientos.add(Movimientos.fromSnapshot(
          snapshot: e,
          cuentaEntrante: cuentaEntrante,
          cuentaSaliente: cuentaSaliente));
    }

    return movimientos;
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

    //final operacionesEnvia = operacionesList
    //    .where((element) => element.cuentaSaliente.id == cuenta.id);

    double balance = 0;

    for (var element in depositos) {
      balance += element.monto;
    }

    for (var element in operacionesRecibe) {
      balance += element.monto;
    }

    //for (var element in operacionesEnvia) {
    //  balance -= element.monto * element.tasa.tasa;
    //}

    return balance;
  }
}

final database = _Database();
