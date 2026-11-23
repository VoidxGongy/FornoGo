import 'package:cloud_firestore/cloud_firestore.dart';

import 'campos_firestore.dart';

enum RolUsuario { cliente, administrador, domiciliario }

/// Perfil en usuarios/{uid}. Firebase Auth administra las credenciales.
class Usuario {
  final String uid;
  String get id => uid;
  final String nombre;
  final String correo;
  final String? telefono;
  final String? direccionPredeterminada;
  final RolUsuario rol;
  final bool activo;
  final DateTime? creadoEn;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    this.telefono,
    this.direccionPredeterminada,
    this.rol = RolUsuario.cliente,
    this.activo = true,
    this.creadoEn,
  });

  /// Al crear el documento, el servicio asigna creadoEn con serverTimestamp.
  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'direccionPredeterminada': direccionPredeterminada,
        'rol': rol.name,
        'activo': activo,
        if (creadoEn != null) 'creadoEn': Timestamp.fromDate(creadoEn!),
      };

  factory Usuario.fromMap(
    Map<String, dynamic> datos, {
    required String uid,
  }) =>
      Usuario(
        uid: uid,
        nombre: datos['nombre'] as String,
        correo: datos['correo'] as String,
        telefono: datos['telefono'] as String?,
        direccionPredeterminada: datos['direccionPredeterminada'] as String?,
        rol: RolUsuario.values.byName(datos['rol'] as String),
        activo: datos['activo'] as bool,
        creadoEn: fechaDesdeFirestore(datos['creadoEn']),
      );
}
