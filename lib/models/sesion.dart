/// Sesión local del usuario que inició sesión en este dispositivo.
class Sesion {
  /// Valores esperados: cliente, administrador, domiciliario.
  String rol;
  int usuarioId;

  Sesion({
    required this.rol,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'rol': rol,
      'usuarioId': usuarioId,
    };
  }

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      rol: json['rol'] as String,
      usuarioId: json['usuarioId'] as int,
    );
  }
}

/// Constantes de rol para no escribir los textos sueltos en las pantallas.
class Rol {
  static const String cliente = 'cliente';
  static const String administrador = 'administrador';
  static const String domiciliario = 'domiciliario';
}
