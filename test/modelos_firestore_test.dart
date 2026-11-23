import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p23092026/models/categoria.dart';
import 'package:p23092026/models/inventario.dart';
import 'package:p23092026/models/pedido_firestore.dart';
import 'package:p23092026/models/producto.dart';
import 'package:p23092026/models/usuario.dart';

void main() {
  final fecha = DateTime.utc(2026, 1, 1, 12);

  test('El catálogo conserva los campos publicados y sus referencias', () {
    final datosCategoria = {'id': 1, 'nombre': 'Pizzas', 'activa': true};
    final datosProducto = {
      'id': 7,
      'nombre': 'Margarita',
      'descripcion': 'Tomate y mozzarella',
      'precio': 28000,
      'categoriaId': 1,
      'rutaImagen': 'assets/images/pizza_margarita.png',
      'esAsset': true,
      'disponible': true,
    };
    final categoria = Categoria.fromMap(datosCategoria, documentoId: '1');
    final producto = Producto.fromMap(datosProducto, documentoId: '7');

    expect(producto.categoriaDocumentoId, categoria.documentoId);
    expect(producto.documentoId, '7');
    expect(categoria.toMap(), datosCategoria);
    expect(producto.toMap(), datosProducto);
    expect(
      () => Producto.fromMap(datosProducto, documentoId: '8'),
      throwsFormatException,
    );
  });

  test('El UID viene de la ruta y la fecha se guarda como Timestamp', () {
    final usuario = Usuario(
      uid: 'uid-cliente',
      nombre: 'Cliente de prueba',
      correo: 'cliente@example.com',
      creadoEn: fecha,
    );
    final datos = usuario.toMap();

    expect(datos.containsKey('uid'), isFalse);
    expect(datos['creadoEn'], isA<Timestamp>());
    final convertido = Usuario.fromMap(datos, uid: usuario.uid);
    expect(convertido.uid, usuario.uid);
    expect(convertido.rol, RolUsuario.cliente);
    expect(convertido.creadoEn, fecha);
  });

  test('El pedido conserva el precio comprado y valida sus importes', () {
    final pedido = PedidoFirestore(
      id: 'pedido-prueba',
      usuarioId: 'uid-cliente',
      metodoPago: MetodoPagoFirestore.efectivo,
      fecha: fecha,
      nombreCliente: 'Cliente de prueba',
      telefono: '0000000000',
      direccion: 'Dirección ficticia',
      items: [
        ItemPedidoFirestore(
          productoId: '7',
          nombreProducto: 'Margarita',
          cantidad: 2,
          precioUnitarioCentavos: 2800000,
        ),
      ],
      domicilioCentavos: 500000,
    );
    final datos = pedido.toMap();
    final convertido = PedidoFirestore.fromMap(datos, id: pedido.id);

    expect(convertido.usuarioId, pedido.usuarioId);
    expect(convertido.items.single.productoId, '7');
    expect(convertido.items.single.precioUnitarioCentavos, 2800000);
    expect(convertido.fecha, fecha);
    expect(convertido.totalCentavos, 6100000);
    expect(
      () => PedidoFirestore.fromMap({...datos, 'totalCentavos': 1},
          id: pedido.id),
      throwsFormatException,
    );
  });

  test('El inventario activa la alerta al alcanzar el mínimo', () {
    final inventario = Inventario(
      productoId: '7',
      existencias: 3,
      stockMinimo: 3,
      actualizadoEn: fecha,
    );
    final datos = inventario.toMap();

    expect(datos['stockBajo'], isTrue);
    expect(
      Inventario.fromMap(datos, productoId: '7').actualizadoEn,
      fecha,
    );
    expect(
      () => Inventario.fromMap({...datos, 'stockBajo': false}, productoId: '7'),
      throwsFormatException,
    );
  });

  test('Un movimiento de venta enlaza el pedido y conserva el saldo', () {
    final venta = MovimientoInventario(
      id: 'venta-pedido-prueba',
      productoId: '7',
      tipo: TipoMovimientoInventario.venta,
      cantidadDelta: -2,
      existenciasAnteriores: 5,
      pedidoId: 'pedido-prueba',
    );
    final datos = venta.toMap();
    final convertido = MovimientoInventario.fromMap(
      datos,
      id: venta.id,
      productoId: venta.productoId,
    );

    expect(convertido.pedidoId, 'pedido-prueba');
    expect(convertido.existenciasResultantes, 3);
    expect(
      () => MovimientoInventario.fromMap(
        {...datos, 'pedidoId': null},
        id: venta.id,
        productoId: venta.productoId,
      ),
      throwsArgumentError,
    );
  });
}
