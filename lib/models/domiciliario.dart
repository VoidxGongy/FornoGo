/// Domiciliario. Solo el administrador lo registra; no hay registro público.
class Domiciliario {
  int id;
  String nombre;
  String correo;
  String telefono;
  String hashClave;
  bool activo;

  Domiciliario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.hashClave,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'hashClave': hashClave,
      'activo': activo,
    };
  }

  factory Domiciliario.fromJson(Map<String, dynamic> json) {
    return Domiciliario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String,
      hashClave: json['hashClave'] as String,
      activo: json['activo'] as bool? ?? true,
    );
  }
}
