import 'package:flutter_test/flutter_test.dart';

import 'package:p23092026/models/item_pedido.dart';
import 'package:p23092026/models/pedido.dart';
import 'package:p23092026/models/producto.dart';
import 'package:p23092026/services/tienda.dart';

void main() {
  test('Producto conserva su ruta de imagen al serializarse', () {
    final producto = Producto(
      id: 1,
      nombre: 'Pizza Margarita',
      descripcion: 'Tomate y mozzarella',
      precio: 28000,
      categoriaId: 1,
      rutaImagen: 'assets/images/pizza_margarita.png',
    );

    final recuperado = Producto.fromJson(producto.toJson());

    expect(recuperado.rutaImagen, 'assets/images/pizza_margarita.png');
    expect(recuperado.precio, 28000);
  });

  test('ItemPedido calcula correctamente su subtotal', () {
    final item = ItemPedido(
      productoId: 1,
      nombre: 'Pizza Pepperoni',
      precioUnitario: 32000,
      cantidad: 2,
    );

    expect(item.subtotal, 64000);
  });

  test('Pedido conserva sus datos y estado en JSON', () {
    final pedido = Pedido(
      id: 10,
      clienteId: 2,
      nombreCliente: 'María García',
      telefono: '3100000000',
      direccion: 'Carrera 10 #20-30',
      items: [
        ItemPedido(
          productoId: 1,
          nombre: 'Pizza Margarita',
          precioUnitario: 28000,
          cantidad: 1,
        ),
      ],
      subtotal: 28000,
      total: 33000,
      metodoPago: MetodoPago.efectivo,
      fecha: DateTime(2026, 1, 1),
    );

    final recuperado = Pedido.fromJson(pedido.toJson());

    expect(recuperado.estado, EstadoPedido.pendiente);
    expect(recuperado.items.single.nombre, 'Pizza Margarita');
    expect(recuperado.total, 33000);
  });

  test('La migración corrige la imagen conocida sin alterar el precio', () {
    final tienda = Tienda.instancia;
    tienda.productos = [
      Producto(
        id: 1,
        nombre: 'Pizza Margarita',
        descripcion: 'Producto guardado anteriormente',
        precio: 29000,
        categoriaId: 1,
        rutaImagen: '',
      ),
    ];

    final cambio = tienda.migrarRutasImagenesProductos();

    expect(cambio, isTrue);
    expect(tienda.productos.single.rutaImagen,
        'assets/images/pizza_margarita.png');
    expect(tienda.productos.single.precio, 29000);
  });
}
