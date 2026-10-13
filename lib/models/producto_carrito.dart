/// Ítem que el cliente tiene en el carrito (aún no es un pedido).
class ProductoCarrito {
  int productoId;
  String nombre;
  double precioUnitario;
  int cantidad;
  String rutaImagen;
  bool esAsset;

  ProductoCarrito({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.rutaImagen,
    this.esAsset = true,
  });

  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'rutaImagen': rutaImagen,
      'esAsset': esAsset,
    };
  }

  factory ProductoCarrito.fromJson(Map<String, dynamic> json) {
    return ProductoCarrito(
      productoId: json['productoId'] as int,
      nombre: json['nombre'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      rutaImagen: json['rutaImagen'] as String,
      esAsset: json['esAsset'] as bool? ?? true,
    );
  }
}
