import 'package:flutter/material.dart';
import '../data/repository.dart';
import '../models/estudiante.dart';
import '../services/estudiante_service.dart';

// ============================================
// PANTALLA: FORMULARIO DE ESTUDIANTE
// ============================================
// Si "estudiante" es null -> modo Crear (CREATE)
// Si "estudiante" no es null -> modo Editar (UPDATE)

class EstudianteFormScreen extends StatefulWidget {
  final Estudiante? estudiante;

  const EstudianteFormScreen({super.key, this.estudiante});

  @override
  State<EstudianteFormScreen> createState() => _EstudianteFormScreenState();
}

class _EstudianteFormScreenState extends State<EstudianteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _correoController;
  int? _cursoIdSeleccionado;

  bool get _esEdicion => widget.estudiante != null;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.estudiante?.nombre ?? '');
    _correoController =
        TextEditingController(text: widget.estudiante?.correo ?? '');
    _cursoIdSeleccionado = widget.estudiante?.curso.id ??
        (cursos.isNotEmpty ? cursos.first.id : null);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate() || _cursoIdSeleccionado == null) {
      return;
    }

    final String? error;

    if (_esEdicion) {
      error = actualizarEstudiante(
        widget.estudiante!.id,
        _nombreController.text.trim(),
        _correoController.text.trim(),
        _cursoIdSeleccionado!,
      );
    } else {
      error = agregarEstudiante(
        siguienteIdEstudiante(),
        _nombreController.text.trim(),
        _correoController.text.trim(),
        _cursoIdSeleccionado!,
      );
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pop(context, true); // true = hubo cambios, refrescar lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar estudiante' : 'Nuevo estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!valor.contains('@')) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _cursoIdSeleccionado,
                decoration: const InputDecoration(labelText: 'Curso'),
                items: cursos
                    .map(
                      (curso) => DropdownMenuItem(
                        value: curso.id,
                        child: Text(curso.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    _cursoIdSeleccionado = valor;
                  });
                },
                validator: (valor) =>
                    valor == null ? 'Selecciona un curso' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardar,
                child: Text(_esEdicion ? 'Guardar cambios' : 'Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
