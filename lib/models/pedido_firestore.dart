import 'package:cloud_firestore/cloud_firestore.dart';

import 'campos_firestore.dart';

enum EstadoPedidoFirestore {
  pendiente,
  asignado,
  aceptado,
  enPreparacion,
  listo,
  enCamino,
  entregado,
  rechazado,
  cancelado,
  extraviado,
}

enum MetodoPagoFirestore { efectivo, tarjeta, transferencia }

/// Línea embebida que conserva el nombre y el precio vigentes en la compra.
class ItemPedidoFirestore {
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final int precioUnitarioCentavos;

  ItemPedidoFirestore({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitarioCentavos,
  }) {
    idCatalogoDesdeDocumento(productoId, null);
    RangeError.checkValueInInterval(cantidad, 1, _maximoImporte, 'cantidad');
    RangeError.checkValueInInterval(precioUnitarioCentavos, 0,
        _maximoImporte ~/ cantidad, 'precioUnitarioCentavos');
  }

  int get subtotalCentavos => cantidad * precioUnitarioCentavos;

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombreProducto': nombreProducto,
        'cantidad': cantidad,
        'precioUnitarioCentavos': precioUnitarioCentavos,
      };

  factory ItemPedidoFirestore.fromMap(Map<String, dynamic> datos) =>
      ItemPedidoFirestore(
        productoId: datos['productoId'] as String,
        nombreProducto: datos['nombreProducto'] as String,
        cantidad: datos['cantidad'] as int,
        precioUnitarioCentavos: datos['precioUnitarioCentavos'] as int,
      );
}

/// Pedido en pedidos/{id}. Los importes se expresan en centavos de COP.
class PedidoFirestore {
  static const moneda = 'COP';

  final String id;
  final String usuarioId;
  final String? domiciliarioId;
  final EstadoPedidoFirestore estado;
  final MetodoPagoFirestore metodoPago;
  final DateTime? fecha;
  final String nombreCliente;
  final String telefono;
  final String direccion;
  final String? referencias;
  final List<ItemPedidoFirestore> items;
  final int domicilioCentavos;
  final int? montoRecibidoCentavos;
  final int subtotalCentavos;

  int get totalCentavos => subtotalCentavos + domicilioCentavos;

  PedidoFirestore({
    required this.id,
    required this.usuarioId,
    this.domiciliarioId,
    this.estado = EstadoPedidoFirestore.pendiente,
    required this.metodoPago,
    this.fecha,
    required this.nombreCliente,
    required this.telefono,
    required this.direccion,
    this.referencias,
    required List<ItemPedidoFirestore> items,
    required this.domicilioCentavos,
    this.montoRecibidoCentavos,
  })  : items = List.unmodifiable(items),
        subtotalCentavos = _calcularSubtotal(items) {
    RangeError.checkValueInInterval(
      domicilioCentavos,
      0,
      _maximoImporte - subtotalCentavos,
      'domicilioCentavos',
    );
    if (montoRecibidoCentavos case final monto?) {
      RangeError.checkValueInInterval(
          monto, 0, _maximoImporte, 'montoRecibidoCentavos');
    }
  }

  /// El servicio asigna fecha con serverTimestamp al crear el documento.
  Map<String, dynamic> toMap() => {
        'usuarioId': usuarioId,
        'domiciliarioId': domiciliarioId,
        'estado': estado.name,
        'metodoPago': metodoPago.name,
        if (fecha != null) 'fecha': Timestamp.fromDate(fecha!),
        'nombreCliente': nombreCliente,
        'telefono': telefono,
        'direccion': direccion,
        'referencias': referencias,
        'items': items.map((item) => item.toMap()).toList(),
        'moneda': moneda,
        'subtotalCentavos': subtotalCentavos,
        'domicilioCentavos': domicilioCentavos,
        'totalCentavos': totalCentavos,
        'montoRecibidoCentavos': montoRecibidoCentavos,
      };

  factory PedidoFirestore.fromMap(
    Map<String, dynamic> datos, {
    required String id,
  }) {
    final pedido = PedidoFirestore(
      id: id,
      usuarioId: datos['usuarioId'] as String,
      domiciliarioId: datos['domiciliarioId'] as String?,
      estado: EstadoPedidoFirestore.values.byName(datos['estado'] as String),
      metodoPago:
          MetodoPagoFirestore.values.byName(datos['metodoPago'] as String),
      fecha: fechaDesdeFirestore(datos['fecha']),
      nombreCliente: datos['nombreCliente'] as String,
      telefono: datos['telefono'] as String,
      direccion: datos['direccion'] as String,
      referencias: datos['referencias'] as String?,
      items: (datos['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(ItemPedidoFirestore.fromMap)
          .toList(),
      domicilioCentavos: datos['domicilioCentavos'] as int,
      montoRecibidoCentavos: datos['montoRecibidoCentavos'] as int?,
    );
    if (datos['moneda'] != moneda ||
        datos['subtotalCentavos'] != pedido.subtotalCentavos ||
        datos['totalCentavos'] != pedido.totalCentavos) {
      throw const FormatException(
          'Los importes del pedido son inconsistentes.');
    }
    return pedido;
  }

  static int _calcularSubtotal(List<ItemPedidoFirestore> items) {
    if (items.isEmpty) {
      throw ArgumentError('El pedido requiere al menos un ítem.');
    }
    return items.fold(
        0, (total, item) => _sumarImportes(total, item.subtotalCentavos));
  }
}

// Mayor entero con representación exacta en los clientes web.
const int _maximoImporte = 9007199254740991;

int _sumarImportes(int subtotal, int adicional) {
  RangeError.checkValueInInterval(
      adicional, 0, _maximoImporte - subtotal, 'importe');
  return subtotal + adicional;
}
