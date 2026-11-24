import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/categoria.dart';
import '../models/inventario.dart';
import '../models/pedido.dart';
import '../models/pedido_firestore.dart';
import '../models/producto.dart';
import '../models/producto_carrito.dart';
import '../models/sesion.dart';
import '../models/usuario.dart';
import 'notificaciones_forno.dart';
import 'persistencia_local.dart';

const double kCostoDomicilio = 5000;

class Tienda extends ChangeNotifier {
  Tienda._();
  static final Tienda instancia = Tienda._();
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  final _sesiones = <StreamSubscription<dynamic>>[];
  final _catalogo = <StreamSubscription<dynamic>>[];
  final _azar = Random.secure();

  List<Producto> productos = [];
  List<Categoria> categorias = [];
  List<Pedido> pedidos = [];
  List<Usuario> domiciliarios = [];
  Map<int, int> _cantidades = {};
  Map<int, Inventario> inventario = {};
  Usuario? perfil;
  String? errorDeCarga;

  Sesion? get sesion => perfil == null
      ? null
      : Sesion(rol: perfil!.rol.name, usuarioId: perfil!.uid);

  List<ProductoCarrito> get carrito => [
        for (final producto in productos)
          if (_cantidades.containsKey(producto.id))
            ProductoCarrito(
              productoId: producto.id,
              nombre: producto.nombre,
              precioUnitario: producto.precio,
              cantidad: _cantidades[producto.id]!,
              rutaImagen: producto.rutaImagen,
              esAsset: producto.esAsset,
            ),
      ];

  Future<void> inicializar() async {
    if (_catalogo.isEmpty) {
      _catalogo.addAll([
        _db.collection('categorias').orderBy('id').snapshots().listen((datos) {
          categorias = [
            for (final doc in datos.docs)
              Categoria.fromMap(doc.data(), documentoId: doc.id),
          ];
          notifyListeners();
        }, onError: _informarError),
        _db.collection('productos').orderBy('id').snapshots().listen((datos) {
          productos = [
            for (final doc in datos.docs)
              Producto.fromMap(doc.data(), documentoId: doc.id),
          ];
          notifyListeners();
        }, onError: _informarError),
      ]);
    }
    final cuenta = await _auth.authStateChanges().first;
    if (cuenta != null) {
      try {
        await _abrirSesion(cuenta.uid);
      } on StateError {
        await cerrarSesion();
      }
    }
  }

  void _informarError(Object error) {
    errorDeCarga = 'No se pudieron sincronizar los datos con Firebase.';
    debugPrint('FornoGO: $error');
    notifyListeners();
  }

  Future<void> _limpiarSesion() async {
    final pendientes = List.of(_sesiones);
    _sesiones.clear();
    perfil = null;
    pedidos = [];
    domiciliarios = [];
    inventario = {};
    _cantidades = {};
    errorDeCarga = null;
    await PersistenciaLocal.instancia.limpiarSesion();
    notifyListeners();
    await Future.wait(pendientes.map((suscripcion) => suscripcion.cancel()));
  }

  Future<void> _abrirSesion(String uid) async {
    await _limpiarSesion();
    final documento = _db.collection('usuarios').doc(uid);
    final datos =
        (await documento.get(const GetOptions(source: Source.server))).data();
    if (datos == null || datos['activo'] != true) {
      throw StateError('La cuenta no tiene un perfil activo.');
    }
    final usuario = Usuario.fromMap(datos, uid: uid);
    perfil = usuario;
    await PersistenciaLocal.instancia.guardarSesion(uid, usuario.rol.name);

    _sesiones.add(documento.snapshots().listen((doc) {
      final datos = doc.data();
      if (datos == null ||
          datos['activo'] != true ||
          datos['rol'] != usuario.rol.name) {
        unawaited(cerrarSesion().catchError(_informarError));
        return;
      }
      perfil = Usuario.fromMap(datos, uid: uid);
      notifyListeners();
    }, onError: _informarError));

    final pedidosRef = _db.collection('pedidos');
    final consulta = switch (usuario.rol) {
      RolUsuario.cliente => pedidosRef.where('usuarioId', isEqualTo: uid),
      RolUsuario.domiciliario =>
        pedidosRef.where('domiciliarioId', isEqualTo: uid),
      RolUsuario.administrador => pedidosRef,
    };
    _sesiones.add(consulta.snapshots().listen((datos) {
      final recibidos = <Pedido>[];
      for (final doc in datos.docs) {
        if (doc.data()['esDemo'] == true) continue;
        try {
          recibidos.add(Pedido.fromFirestore(
              PedidoFirestore.fromMap(doc.data(), id: doc.id)));
        } catch (error) {
          debugPrint('Pedido inválido (${doc.id}): $error');
        }
      }
      pedidos = recibidos..sort((a, b) => a.fecha.compareTo(b.fecha));
      notifyListeners();
    }, onError: _informarError));
    if (usuario.rol == RolUsuario.cliente ||
        usuario.rol == RolUsuario.domiciliario) {
      NotificacionesForno.instancia.vincular(uid);
    }
    if (usuario.rol == RolUsuario.cliente) {
      _sesiones.add(_carritoRef(uid).snapshots().listen((doc) {
        _cantidades = _leerCantidades(doc.data());
        notifyListeners();
      }, onError: _informarError));
    }
    if (usuario.rol == RolUsuario.administrador) {
      _sesiones.addAll([
        _db
            .collection('usuarios')
            .where('rol', isEqualTo: 'domiciliario')
            .snapshots()
            .listen((datos) {
          domiciliarios = [
            for (final doc in datos.docs)
              Usuario.fromMap(doc.data(), uid: doc.id),
          ];
          notifyListeners();
        }, onError: _informarError),
        _db.collection('inventario').snapshots().listen((datos) {
          inventario = {
            for (final doc in datos.docs)
              int.parse(doc.id):
                  Inventario.fromMap(doc.data(), productoId: doc.id),
          };
          notifyListeners();
        }, onError: _informarError),
      ]);
    }
    notifyListeners();
  }

  Future<void> iniciarSesion(String correo, String clave) async {
    await _auth.signInWithEmailAndPassword(email: correo, password: clave);
    try {
      await _abrirSesion(_auth.currentUser!.uid);
    } catch (_) {
      await cerrarSesion();
      rethrow;
    }
  }

  Future<void> cerrarSesion() async {
    await NotificacionesForno.instancia.desvincular();
    await _auth.signOut();
    await _limpiarSesion();
  }

  Future<void> registrarCliente({
    required String nombre,
    required String correo,
    required String clave,
    required String telefono,
    required String direccion,
  }) async {
    await _crearCuenta(_auth, nombre, correo, clave, telefono,
        direccion: direccion, rol: RolUsuario.cliente);
  }

  Future<void> agregarDomiciliario({
    required String nombre,
    required String correo,
    required String clave,
    required String telefono,
  }) async {
    final app = await Firebase.initializeApp(
      name: 'alta-domiciliario-${_azar.nextInt(1 << 30)}',
      options: Firebase.app().options,
    );
    try {
      await _crearCuenta(
          FirebaseAuth.instanceFor(app: app), nombre, correo, clave, telefono,
          rol: RolUsuario.domiciliario);
    } finally {
      await app.delete();
    }
  }

  Future<void> _crearCuenta(
    FirebaseAuth auth,
    String nombre,
    String correo,
    String clave,
    String telefono, {
    String? direccion,
    required RolUsuario rol,
  }) async {
    final cuenta = (await auth.createUserWithEmailAndPassword(
            email: correo, password: clave))
        .user!;
    final usuario = Usuario(
        uid: cuenta.uid,
        nombre: nombre,
        correo: cuenta.email!,
        telefono: telefono,
        direccionPredeterminada: direccion,
        rol: rol);
    try {
      await _db.collection('usuarios').doc(cuenta.uid).set({
        ...usuario.toMap(),
        'creadoEn': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') await cuenta.delete();
      rethrow;
    } finally {
      await auth.signOut();
    }
  }

  Future<void> editarDomiciliario(String uid, String nombre, String telefono) =>
      _db
          .collection('usuarios')
          .doc(uid)
          .update({'nombre': nombre, 'telefono': telefono});

  Future<void> desactivarDomiciliario(String uid) =>
      _db.collection('usuarios').doc(uid).update({'activo': false});

  List<Usuario> domiciliariosActivos() =>
      domiciliarios.where((usuario) => usuario.activo).toList();

  Categoria? buscarCategoriaPorId(int id) =>
      categorias.where((categoria) => categoria.id == id).firstOrNull;
  Producto? buscarProductoPorId(int id) =>
      productos.where((producto) => producto.id == id).firstOrNull;
  List<Categoria> categoriasActivas() =>
      categorias.where((c) => c.activa).toList();
  List<Producto> productosPorCategoria(int id) =>
      productos.where((p) => p.categoriaId == id && p.disponible).toList();

  Future<void> agregarCategoria(Categoria categoria) async {
    categoria.id = _azar.nextInt(1 << 30) + 1;
    final ref = _db.collection('categorias').doc(categoria.documentoId);
    await _db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) {
        throw StateError('Vuelve a intentar guardar.');
      }
      tx.set(ref, categoria.toMap());
    });
  }

  Future<void> editarCategoria(Categoria categoria) => _db
      .collection('categorias')
      .doc(categoria.documentoId)
      .update(categoria.toMap());
  Future<bool> eliminarCategoria(int id) async {
    if (productos
        .any((producto) => producto.categoriaId == id && producto.disponible)) {
      return false;
    }
    await _db.collection('categorias').doc('$id').update({'activa': false});
    return true;
  }

  Future<void> agregarProducto(Producto producto) async {
    producto.id = _azar.nextInt(1 << 30) + 1;
    final ref = _db.collection('productos').doc(producto.documentoId);
    await _db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) {
        throw StateError('Vuelve a intentar guardar.');
      }
      tx.set(ref, producto.toMap());
      tx.set(_db.collection('inventario').doc(ref.id), {
        ...Inventario(productoId: ref.id, existencias: 0, stockMinimo: 0)
            .toMap(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> editarProducto(Producto producto) => _db
      .collection('productos')
      .doc(producto.documentoId)
      .update(producto.toMap());
  Future<void> eliminarProducto(int id) =>
      _db.collection('productos').doc('$id').update({'disponible': false});

  DocumentReference<Map<String, dynamic>> _carritoRef(String uid) =>
      _db.collection('usuarios').doc(uid).collection('carrito').doc('actual');

  Map<int, int> _leerCantidades(Map<String, dynamic>? datos) => {
        for (final entrada
            in (datos?['cantidades'] as Map<String, dynamic>? ?? {}).entries)
          int.parse(entrada.key): entrada.value as int,
      };

  Future<void> _cambiarCarrito(void Function(Map<int, int>) cambiar) async {
    final ref = _carritoRef(perfil!.uid);
    await _db.runTransaction((tx) async {
      final cantidades = _leerCantidades((await tx.get(ref)).data());
      cambiar(cantidades);
      tx.set(ref, {
        'cantidades':
            cantidades.map((id, cantidad) => MapEntry('$id', cantidad))
      });
    });
  }

  Future<void> agregarAlCarrito(Producto producto, int cantidad) =>
      _cambiarCarrito((items) => items.update(
          producto.id, (actual) => actual + cantidad,
          ifAbsent: () => cantidad));
  Future<void> cambiarCantidadCarrito(int id, int cantidad) => cantidad < 1
      ? eliminarDelCarrito(id)
      : _cambiarCarrito((items) => items[id] = cantidad);
  Future<void> eliminarDelCarrito(int id) =>
      _cambiarCarrito((items) => items.remove(id));
  Future<void> vaciarCarrito() => _carritoRef(perfil!.uid).delete();

  double subtotalCarrito() =>
      carrito.fold(0.0, (total, item) => total + item.subtotal);
  double totalCarrito() => subtotalCarrito() + kCostoDomicilio;

  List<Pedido> pedidosDeCliente(String uid) =>
      pedidos.where((pedido) => pedido.clienteId == uid).toList();

  Future<void> confirmarPedido({
    required String direccion,
    required String referencias,
    required String metodoPago,
  }) async {
    final usuario = perfil!;
    final carritoRef = _carritoRef(usuario.uid);
    final pedidoRef = _db.collection('pedidos').doc();
    await _db.runTransaction((tx) async {
      final cantidades = _leerCantidades((await tx.get(carritoRef)).data());
      if (cantidades.isEmpty) throw StateError('El carrito está vacío.');
      final items = <ItemPedidoFirestore>[];
      for (final entrada in cantidades.entries) {
        final ref = _db.collection('productos').doc('${entrada.key}');
        final datos = (await tx.get(ref)).data();
        if (datos == null || datos['disponible'] != true) {
          throw StateError('Retira los productos que ya no están disponibles.');
        }
        items.add(ItemPedidoFirestore(
          productoId: ref.id,
          nombreProducto: datos['nombre'] as String,
          cantidad: entrada.value,
          precioUnitarioCentavos: ((datos['precio'] as num) * 100).round(),
        ));
      }
      final pedido = PedidoFirestore(
        id: pedidoRef.id,
        usuarioId: usuario.uid,
        metodoPago: MetodoPagoFirestore.values.byName(metodoPago.toLowerCase()),
        nombreCliente: usuario.nombre,
        telefono: usuario.telefono ?? '',
        direccion: direccion,
        referencias: referencias,
        items: items,
        domicilioCentavos: (kCostoDomicilio * 100).round(),
      );
      tx.set(pedidoRef,
          {...pedido.toMap(), 'fecha': FieldValue.serverTimestamp()});
      tx.delete(carritoRef);
    });
  }

  Future<bool> asignarDomiciliario(
      String pedidoId, String domiciliarioId) async {
    final ref = _db.collection('pedidos').doc(pedidoId);
    await _db.runTransaction((tx) async {
      final datos = (await tx.get(ref)).data();
      if (datos == null) throw StateError('El pedido ya no existe.');
      final estado = datos['estado'] as String?;
      if (estado == EstadoPedidoFirestore.entregado.name ||
          estado == EstadoPedidoFirestore.cancelado.name ||
          estado == EstadoPedidoFirestore.extraviado.name) {
        throw StateError('No se puede asignar un pedido finalizado.');
      }
      if (estado != EstadoPedidoFirestore.pendiente.name &&
          estado != EstadoPedidoFirestore.asignado.name) {
        throw StateError('El pedido ya está siendo procesado.');
      }
      if (datos['domiciliarioId'] == domiciliarioId &&
          estado == EstadoPedidoFirestore.asignado.name) {
        return;
      }
      tx.update(ref, {
        'domiciliarioId': domiciliarioId,
        'estado': EstadoPedidoFirestore.asignado.name,
      });
    });
    return true;
  }

  Future<void> cancelarPedido(String pedidoId) =>
      actualizarEstadoPedido(pedidoId, EstadoPedido.cancelado);

  Future<void> marcarPedidoExtraviado(String pedidoId) => _db
      .collection('pedidos')
      .doc(pedidoId)
      .update({'estado': EstadoPedidoFirestore.extraviado.name});

  Future<void> confirmarEntrega(
      {required String pedidoId, required String metodoPago}) async {
    final ref = _db.collection('pedidos').doc(pedidoId);
    await _db.runTransaction((tx) async {
      final datos = (await tx.get(ref)).data();
      if (datos == null) throw StateError('El pedido ya no existe.');
      final pedido = PedidoFirestore.fromMap(datos, id: pedidoId);
      final estado = EstadoPedido.nombres[pedido.estado]!;
      if (![
        EstadoPedido.aceptado,
        EstadoPedido.enPreparacion,
        EstadoPedido.listo,
        EstadoPedido.enCamino,
      ].contains(estado)) {
        throw StateError('El pedido todavía no está listo para entregar.');
      }
      tx.update(ref, {
        'estado': EstadoPedidoFirestore.entregado.name,
        'metodoPago': metodoPago.toLowerCase(),
      });
    });
  }

  Future<void> actualizarEstadoAdministrativo(
      String pedidoId, String estado) async {
    await actualizarEstadoPedido(pedidoId, estado);
  }

  Future<void> actualizarEstadoPedido(String id, String estado) async {
    final ref = _db.collection('pedidos').doc(id);
    await _db.runTransaction((tx) async {
      final datos = (await tx.get(ref)).data()!;
      final pedido = PedidoFirestore.fromMap(datos, id: id);
      final siguiente = EstadoPedido.paraFirestore(estado);
      if (siguiente == pedido.estado) return;
      if (!EstadoPedido.siguientes(EstadoPedido.nombres[pedido.estado]!)
          .contains(estado)) {
        throw StateError('El pedido cambió de estado. Actualiza la vista.');
      }
      final acepta = (pedido.estado == EstadoPedidoFirestore.pendiente ||
              pedido.estado == EstadoPedidoFirestore.asignado) &&
          siguiente == EstadoPedidoFirestore.aceptado;
      final devuelve = siguiente == EstadoPedidoFirestore.cancelado &&
          const {
            EstadoPedidoFirestore.aceptado,
            EstadoPedidoFirestore.enPreparacion,
            EstadoPedidoFirestore.listo,
            EstadoPedidoFirestore.enCamino,
          }.contains(pedido.estado);
      final cantidades = <String, int>{};
      if (acepta || devuelve) {
        for (final item in pedido.items) {
          cantidades.update(item.productoId, (valor) => valor + item.cantidad,
              ifAbsent: () => item.cantidad);
        }
      }
      final inventarios =
          <DocumentReference<Map<String, dynamic>>, Inventario>{};
      for (final id in cantidades.keys) {
        final stockRef = _db.collection('inventario').doc(id);
        final stock = (await tx.get(stockRef)).data();
        if (stock == null) {
          throw StateError('El producto $id requiere inventario.');
        }
        inventarios[stockRef] = Inventario.fromMap(stock, productoId: id);
      }
      if (acepta) {
        for (final item in pedido.items) {
          final datos =
              (await tx.get(_db.collection('productos').doc(item.productoId)))
                  .data();
          if (datos == null ||
              datos['disponible'] != true ||
              ((datos['precio'] as num) * 100).round() !=
                  item.precioUnitarioCentavos) {
            throw StateError(
                'El catálogo cambió. Rechaza el pedido para que el cliente lo vuelva a solicitar.');
          }
        }
      }
      for (final entrada in inventarios.entries) {
        final delta = cantidades[entrada.key.id]! * (acepta ? -1 : 1);
        if (entrada.value.existencias + delta < 0) {
          throw StateError(
              'No hay stock suficiente para el producto ${entrada.key.id}.');
        }
        _escribirMovimiento(
            tx,
            entrada.key,
            entrada.value,
            delta,
            entrada.value.stockMinimo,
            acepta
                ? TipoMovimientoInventario.venta
                : TipoMovimientoInventario.devolucion,
            pedidoId: id);
      }
      tx.update(ref, {'estado': siguiente.name});
    });
  }

  Future<void> ajustarInventario(int id, int existencias, int minimo) async {
    final ref = _db.collection('inventario').doc('$id');
    await _db.runTransaction((tx) async {
      final datos = (await tx.get(ref)).data();
      final anterior = datos == null
          ? Inventario(productoId: ref.id, existencias: 0, stockMinimo: 0)
          : Inventario.fromMap(datos, productoId: ref.id);
      _escribirMovimiento(tx, ref, anterior, existencias - anterior.existencias,
          minimo, TipoMovimientoInventario.ajuste);
    });
  }

  void _escribirMovimiento(
      Transaction tx,
      DocumentReference<Map<String, dynamic>> ref,
      Inventario anterior,
      int delta,
      int minimo,
      TipoMovimientoInventario tipo,
      {String? pedidoId}) {
    tx.set(ref, {
      ...Inventario(
              productoId: ref.id,
              existencias: anterior.existencias + delta,
              stockMinimo: minimo)
          .toMap(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
    if (delta == 0) return;
    final movimientos = ref.collection('movimientos');
    final movimientoRef = pedidoId == null
        ? movimientos.doc()
        : movimientos.doc('${tipo.name}_$pedidoId');
    final movimiento = MovimientoInventario(
      id: movimientoRef.id,
      productoId: ref.id,
      tipo: tipo,
      cantidadDelta: delta,
      existenciasAnteriores: anterior.existencias,
      pedidoId: pedidoId,
      usuarioId: perfil!.uid,
    );
    tx.set(movimientoRef,
        {...movimiento.toMap(), 'fecha': FieldValue.serverTimestamp()});
  }
}
