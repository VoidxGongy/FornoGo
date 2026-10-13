import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models/estudiante.dart';
import '../services/estudiante_service.dart';
import 'estudiante_form_screen.dart';

// ============================================
// PANTALLA: LISTA DE ESTUDIANTES (CRUD)
// ============================================

class EstudiantesScreen extends StatefulWidget {
  const EstudiantesScreen({super.key});

  @override
  State<EstudiantesScreen> createState() => _EstudiantesScreenState();
}

class _EstudiantesScreenState extends State<EstudiantesScreen> {
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _abrirFormulario({Estudiante? estudiante}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EstudianteFormScreen(estudiante: estudiante),
      ),
    );

    if (resultado == true) {
      setState(() {}); // refresca la lista tras crear/editar
    }
  }

  void _confirmarEliminar(Estudiante estudiante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text('¿Eliminar a ${estudiante.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final error = eliminarEstudiante(estudiante.id);
              Navigator.pop(context);
              setState(() {});
              _mostrarMensaje(error ?? 'Estudiante eliminado correctamente.');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: estudiantes.isEmpty
          ? const Center(child: Text('No existen estudiantes registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: estudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = estudiantes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${estudiante.id}')),
                    title: Text(estudiante.nombre),
                    subtitle: Text(
                      '${estudiante.correo}\nCurso: ${estudiante.curso.nombre}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _abrirFormulario(estudiante: estudiante),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmarEliminar(estudiante),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
