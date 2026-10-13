import 'package:flutter/material.dart';
import '../models/curso.dart';
import '../services/estudiante_service.dart';

// ============================================
// PANTALLA: DETALLE DE CURSO
// ============================================
// Aquí se ve la relación estudiante.curso en acción:
// filtramos la lista global de estudiantes por
// curso.id, navegando el objeto en vez de comparar
// solo un cursoId suelto.

class CursoDetalleScreen extends StatelessWidget {
  final Curso curso;

  const CursoDetalleScreen({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    final estudiantesDelCurso = obtenerEstudiantesPorCurso(curso.id);

    return Scaffold(
      appBar: AppBar(title: Text(curso.nombre)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              curso.descripcion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Estudiantes inscritos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: estudiantesDelCurso.isEmpty
                ? const Center(
                    child: Text('No hay estudiantes en este curso.'),
                  )
                : ListView.builder(
                    itemCount: estudiantesDelCurso.length,
                    itemBuilder: (context, index) {
                      final estudiante = estudiantesDelCurso[index];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(estudiante.nombre),
                        subtitle: Text(estudiante.correo),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
