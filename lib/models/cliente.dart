/// Cliente registrado en la aplicación (único perfil con registro público).
class Cliente {
  int id;
  String nombre;
  String correo;
  String telefono;

  /// Clave cifrada de forma académica (NO es un sistema seguro de producción).
  String hashClave;
  String direccionPredeterminada;

  Cliente({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.hashClave,
    this.direccionPredeterminada = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'hashClave': hashClave,
      'direccionPredeterminada': direccionPredeterminada,
    };
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String,
      hashClave: json['hashClave'] as String,
      direccionPredeterminada: json['direccionPredeterminada'] as String? ?? '',
    );
  }
}
