import 'item_pedido.dart';
import 'pedido_firestore.dart';

/// Constantes de estado del pedido (misma secuencia del prototipo).
class EstadoPedido {
  static const String pendiente = 'Pendiente';
  static const String asignado = 'Asignado';
  static const String aceptado = 'Aceptado';
  static const String enPreparacion = 'En preparación';
  static const String listo = 'Listo';
  static const String enCamino = 'En camino';
  static const String entregado = 'Entregado';
  static const String rechazado = 'Rechazado';
  static const String cancelado = 'Cancelado';
  static const String extraviado = 'Extraviado';

  static const nombres = {
    EstadoPedidoFirestore.pendiente: pendiente,
    EstadoPedidoFirestore.asignado: asignado,
    EstadoPedidoFirestore.aceptado: aceptado,
    EstadoPedidoFirestore.enPreparacion: enPreparacion,
    EstadoPedidoFirestore.listo: listo,
    EstadoPedidoFirestore.enCamino: enCamino,
    EstadoPedidoFirestore.entregado: entregado,
    EstadoPedidoFirestore.rechazado: rechazado,
    EstadoPedidoFirestore.cancelado: cancelado,
    EstadoPedidoFirestore.extraviado: extraviado,
  };

  static EstadoPedidoFirestore paraFirestore(String estado) =>
      nombres.entries.singleWhere((elemento) => elemento.value == estado).key;

  static List<String> siguientes(String estado) => switch (estado) {
        pendiente => [asignado, rechazado, cancelado],
        asignado => [entregado, extraviado, cancelado],
        aceptado => [enPreparacion, cancelado],
        enPreparacion => [listo, cancelado],
        listo => [enCamino, cancelado],
        enCamino => [entregado, extraviado, cancelado],
        _ => [],
      };

  static const List<String> secuencia = [
    pendiente,
    asignado,
    aceptado,
    enPreparacion,
    listo,
    enCamino,
    entregado,
  ];

  static const List<String> estadosAdministrables = [
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
  ];
}

/// Métodos de pago permitidos (se cobran al entregar, salvo transferencia).
class MetodoPago {
  static const String efectivo = 'Efectivo';
  static const String tarjeta = 'Tarjeta';
  static const String transferencia = 'Transferencia';
}

/// Pedido confirmado por un cliente.
class Pedido {
  String id;
  String clienteId;
  String nombreCliente;
  String telefono;
  String direccion;
  String referencias;
  List<ItemPedido> items;
  double subtotal;
  double domicilio;
  double total;
  String metodoPago;
  String estado;
  String? domiciliarioId;
  DateTime fecha;
  double? montoRecibido;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.nombreCliente,
    required this.telefono,
    required this.direccion,
    this.referencias = '',
    required this.items,
    required this.subtotal,
    this.domicilio = 5000,
    required this.total,
    required this.metodoPago,
    this.estado = EstadoPedido.pendiente,
    this.domiciliarioId,
    required this.fecha,
    this.montoRecibido,
  });

  factory Pedido.fromFirestore(PedidoFirestore datos) => Pedido(
        id: datos.id,
        clienteId: datos.usuarioId,
        nombreCliente: datos.nombreCliente,
        telefono: datos.telefono,
        direccion: datos.direccion,
        referencias: datos.referencias ?? '',
        items: [
          for (final item in datos.items)
            ItemPedido(
              productoId: int.parse(item.productoId),
              nombre: item.nombreProducto,
              precioUnitario: item.precioUnitarioCentavos / 100,
              cantidad: item.cantidad,
            ),
        ],
        subtotal: datos.subtotalCentavos / 100,
        domicilio: datos.domicilioCentavos / 100,
        total: datos.totalCentavos / 100,
        metodoPago: switch (datos.metodoPago) {
          MetodoPagoFirestore.efectivo => MetodoPago.efectivo,
          MetodoPagoFirestore.tarjeta => MetodoPago.tarjeta,
          MetodoPagoFirestore.transferencia => MetodoPago.transferencia,
        },
        estado: EstadoPedido.nombres[datos.estado]!,
        domiciliarioId: datos.domiciliarioId,
        fecha:
            datos.fecha ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        montoRecibido: datos.montoRecibidoCentavos == null
            ? null
            : datos.montoRecibidoCentavos! / 100,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'nombreCliente': nombreCliente,
      'telefono': telefono,
      'direccion': direccion,
      'referencias': referencias,
      // Cada ítem también se convierte a mapa para armar el JSON de la lista.
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'domicilio': domicilio,
      'total': total,
      'metodoPago': metodoPago,
      'estado': estado,
      'domiciliarioId': domiciliarioId,
      'fecha': fecha.toIso8601String(),
      'montoRecibido': montoRecibido,
    };
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final listaItems = json['items'] as List<dynamic>? ?? [];
    return Pedido(
      id: json['id'].toString(),
      clienteId: json['clienteId'].toString(),
      nombreCliente: json['nombreCliente'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      referencias: json['referencias'] as String? ?? '',
      items: listaItems
          .map((item) => ItemPedido.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      domicilio: (json['domicilio'] as num?)?.toDouble() ?? 5000,
      total: (json['total'] as num).toDouble(),
      metodoPago: json['metodoPago'] as String,
      estado: json['estado'] as String? ?? EstadoPedido.pendiente,
      domiciliarioId: json['domiciliarioId']?.toString(),
      fecha: DateTime.parse(json['fecha'] as String),
      montoRecibido: (json['montoRecibido'] as num?)?.toDouble(),
    );
  }
}
