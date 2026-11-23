/// Identidad y rol del perfil autenticado con Firebase.
class Sesion {
  /// Valores esperados: cliente, administrador, domiciliario.
  String rol;
  String usuarioId;

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
      usuarioId: json['usuarioId'] as String,
    );
  }
}

/// Constantes de rol para no escribir los textos sueltos en las pantallas.
class Rol {
  static const String cliente = 'cliente';
  static const String administrador = 'administrador';
  static const String domiciliario = 'domiciliario';
}
