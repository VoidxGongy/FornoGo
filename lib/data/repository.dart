import '../models/curso.dart';
import '../models/estudiante.dart';
import 'api_simulator.dart';

// ============================================
// LISTAS QUE REPRESENTAN NUESTRA BASE DE DATOS
// ============================================

List<Curso> cursos = [];
List<Estudiante> estudiantes = [];

// ============================================
// CARGAR CURSOS
// ============================================

void cargarCursos() {
  for (var dato in respuestaCursosAPI) {
    Curso curso = Curso(
      id: dato['id'],
      nombre: dato['nombre'],
      descripcion: dato['descripcion'],
    );

    cursos.add(curso);
  }
}

// ============================================
// BUSCAR CURSO POR ID
// ============================================

Curso? buscarCursoPorId(int id) {
  for (Curso curso in cursos) {
    if (curso.id == id) {
      return curso;
    }
  }

  return null;
}

// ============================================
// CARGAR ESTUDIANTES
// ============================================

void cargarEstudiantes() {
  for (var dato in respuestaEstudiantesAPI) {
    int cursoId = dato['cursoId'];

    // Buscamos el objeto Curso
    Curso? curso = buscarCursoPorId(cursoId);

    if (curso != null) {
      Estudiante estudiante = Estudiante(
        id: dato['id'],
        nombre: dato['nombre'],
        correo: dato['correo'],
        curso: curso,
      );

      estudiantes.add(estudiante);
    }
  }
}

// ============================================
// BUSCAR ESTUDIANTE POR ID
// ============================================

Estudiante? buscarEstudiantePorId(int id) {
  for (Estudiante estudiante in estudiantes) {
    if (estudiante.id == id) {
      return estudiante;
    }
  }

  return null;
}
