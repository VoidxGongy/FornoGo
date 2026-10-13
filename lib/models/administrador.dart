/// Administrador de la pizzería. Se crea por semilla; no hay registro público.
class Administrador {
  int id;
  String nombre;
  String correo;
  String hashClave;

  Administrador({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.hashClave,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'hashClave': hashClave,
    };
  }

  factory Administrador.fromJson(Map<String, dynamic> json) {
    return Administrador(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      hashClave: json['hashClave'] as String,
    );
  }
}
