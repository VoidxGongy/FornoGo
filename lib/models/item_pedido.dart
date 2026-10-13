/// Línea de un pedido ya confirmado (copia de nombre y precio en ese momento).
class ItemPedido {
  int productoId;
  String nombre;
  double precioUnitario;
  int cantidad;

  ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });

  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
    };
  }

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      productoId: json['productoId'] as int,
      nombre: json['nombre'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
    );
  }
}
