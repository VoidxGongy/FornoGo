/// Modelo de producto del catálogo de la pizzería.
class Producto {
  int id;
  String nombre;
  String descripcion;
  double precio;
  int categoriaId;

  /// Ruta del archivo: un asset (assets/images/...) o un archivo local.
  String rutaImagen;

  /// En el flujo actual se usan los PNG locales declarados como assets.
  bool esAsset;
  bool disponible;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoriaId,
    required this.rutaImagen,
    this.esAsset = true,
    this.disponible = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoriaId': categoriaId,
      'rutaImagen': rutaImagen,
      'esAsset': esAsset,
      'disponible': disponible,
    };
  }

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      categoriaId: json['categoriaId'] as int,
      rutaImagen: json['rutaImagen'] as String? ?? '',
      esAsset: json['esAsset'] as bool? ?? true,
      disponible: json['disponible'] as bool? ?? true,
    );
  }
}
