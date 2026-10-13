/// Modelo de categoría del menú (Pizzas, Bebidas, Postres, etc.).
class Categoria {
  int id;
  String nombre;
  bool activa;

  Categoria({
    required this.id,
    required this.nombre,
    this.activa = true,
  });

  /// Convierte el objeto a un mapa para poder guardarlo como JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'activa': activa,
    };
  }

  /// Reconstruye una categoría a partir de un mapa JSON.
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      activa: json['activa'] as bool? ?? true,
    );
  }
}
