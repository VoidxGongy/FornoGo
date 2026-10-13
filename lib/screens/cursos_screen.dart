import 'package:flutter/material.dart';
import '../data/repository.dart';
import 'curso_detalle_screen.dart';

// ============================================
// PANTALLA: LISTA DE CURSOS
// ============================================

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (cursos.isEmpty) {
      return const Center(
        child: Text('No hay cursos registrados.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cursos.length,
      itemBuilder: (context, index) {
        final curso = cursos[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(child: Text('${curso.id}')),
            title: Text(curso.nombre),
            subtitle: Text(curso.descripcion),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CursoDetalleScreen(curso: curso),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
