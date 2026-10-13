import 'curso.dart';

// ============================================
// MODELO: ESTUDIANTE
// ============================================

class Estudiante {
  int id;
  String nombre;
  String correo;

  // Relación entre Estudiante y Curso
  Curso curso;

  Estudiante({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.curso,
  });

  // Método propio de la clase
  String mostrarInfo() {
    return '''
Estudiante #$id
Nombre: $nombre
Correo: $correo
Curso: ${curso.nombre}
''';
  }

  @override
  String toString() {
    return 'Estudiante{id: $id, nombre: $nombre, correo: $correo, curso: ${curso.nombre}}';
  }
}
