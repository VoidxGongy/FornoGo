import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';

class CategoriasAdminScreen extends StatefulWidget {
  const CategoriasAdminScreen({super.key});
  @override
  State<CategoriasAdminScreen> createState() => _CategoriasAdminScreenState();
}

class _CategoriasAdminScreenState extends State<CategoriasAdminScreen> {
  void _editar([Categoria? categoria]) {
    final controller = TextEditingController(text: categoria?.nombre ?? '');
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: Text(
                    categoria == null ? 'Nueva categoría' : 'Editar categoría'),
                content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nombre')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () async {
                        final nombre = controller.text.trim();
                        if (nombre.isEmpty) return;
                        final tienda = Tienda.instancia;
                        final listo = await ejecutarOperacion(
                            context,
                            () => categoria == null
                                ? tienda.agregarCategoria(
                                    Categoria(id: 0, nombre: nombre))
                                : tienda.editarCategoria(Categoria(
                                    id: categoria.id,
                                    nombre: nombre,
                                    activa: true)));
                        if (!mounted) return;
                        if (listo) Navigator.pop(context);
                      },
                      child: const Text('Guardar'))
                ])).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Tienda.instancia,
        builder: (context, _) => _contenido(context),
      );

  Widget _contenido(BuildContext context) {
    final categorias = Tienda.instancia.categorias;
    return Scaffold(
        appBar: AppBar(title: const Text('Categorías')),
        body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categorias.length,
            itemBuilder: (_, index) {
              final categoria = categorias[index];
              return Card(
                  child: ListTile(
                      title: Text(categoria.nombre),
                      subtitle: Text(categoria.activa ? 'Activa' : 'Inactiva'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            onPressed: () => _editar(categoria),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () =>
                                ejecutarOperacion(context, () async {
                                  if (!await Tienda.instancia
                                      .eliminarCategoria(categoria.id)) {
                                    throw StateError(
                                        'Desactiva primero los productos de esta categoría.');
                                  }
                                }),
                            tooltip: 'Desactivar categoría',
                            icon: const Icon(Icons.archive_outlined))
                      ])));
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _editar(), child: const Icon(Icons.add)));
  }
}
