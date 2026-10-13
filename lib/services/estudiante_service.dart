import '../models/estudiante.dart';
import '../data/repository.dart';

// ============================================
// SERVICIO DE ESTUDIANTES
// ============================================
// A diferencia de la versión de consola, aquí no
// usamos print(): cada función devuelve un
// resultado (String? de error, o una lista) para
// que la capa de widgets decida cómo mostrarlo
// (SnackBar, diálogo, etc).

// ------------------------------------------
// CREATE - AGREGAR ESTUDIANTE
// ------------------------------------------
// Retorna null si todo salió bien, o un mensaje
// de error en caso contrario.
String? agregarEstudiante(
  int id,
  String nombre,
  String correo,
  int cursoId,
) {
  final curso = buscarCursoPorId(cursoId);

  if (curso == null) {
    return 'No existe el curso con ID $cursoId';
  }

  final nuevoEstudiante = Estudiante(
    id: id,
    nombre: nombre,
    correo: correo,
    curso: curso,
  );

  estudiantes.add(nuevoEstudiante);

  return null;
}

// ------------------------------------------
// UPDATE - ACTUALIZAR ESTUDIANTE
// ------------------------------------------
String? actualizarEstudiante(
  int id,
  String nuevoNombre,
  String nuevoCorreo,
  int nuevoCursoId,
) {
  final estudiante = buscarEstudiantePorId(id);

  if (estudiante == null) {
    return 'No existe el estudiante con ID $id';
  }

  final nuevoCurso = buscarCursoPorId(nuevoCursoId);

  if (nuevoCurso == null) {
    return 'No existe el curso con ID $nuevoCursoId';
  }

  estudiante.nombre = nuevoNombre;
  estudiante.correo = nuevoCorreo;
  estudiante.curso = nuevoCurso;

  return null;
}

// ------------------------------------------
// DELETE - ELIMINAR ESTUDIANTE
// ------------------------------------------
String? eliminarEstudiante(int id) {
  final estudiante = buscarEstudiantePorId(id);

  if (estudiante == null) {
    return 'No existe el estudiante con ID $id';
  }

  estudiantes.remove(estudiante);

  return null;
}

// ------------------------------------------
// SIGUIENTE ID DISPONIBLE (para el formulario)
// ------------------------------------------
int siguienteIdEstudiante() {
  if (estudiantes.isEmpty) return 1;
  return estudiantes.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
}

// ------------------------------------------
// ESTUDIANTES DE UN CURSO
// ------------------------------------------
List<Estudiante> obtenerEstudiantesPorCurso(int cursoId) {
  return estudiantes.where((e) => e.curso.id == cursoId).toList();
}
