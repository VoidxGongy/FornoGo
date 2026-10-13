import 'item_pedido.dart';

/// Constantes de estado del pedido (misma secuencia del prototipo).
class EstadoPedido {
  static const String pendiente = 'Pendiente';
  static const String aceptado = 'Aceptado';
  static const String enPreparacion = 'En preparación';
  static const String listo = 'Listo';
  static const String enCamino = 'En camino';
  static const String entregado = 'Entregado';
  static const String rechazado = 'Rechazado';

  static const List<String> secuencia = [
    pendiente,
    aceptado,
    enPreparacion,
    listo,
    enCamino,
    entregado,
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
  int id;
  int clienteId;
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
  int? domiciliarioId;
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
      id: json['id'] as int,
      clienteId: json['clienteId'] as int,
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
      domiciliarioId: json['domiciliarioId'] as int?,
      fecha: DateTime.parse(json['fecha'] as String),
      montoRecibido: (json['montoRecibido'] as num?)?.toDouble(),
    );
  }
}
