import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/tienda.dart';

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
                      onPressed: () {
                        final nombre = controller.text.trim();
                        if (nombre.isEmpty) return;
                        final tienda = Tienda.instancia;
                        if (categoria == null) {
                          tienda.agregarCategoria(
                              Categoria(id: 0, nombre: nombre));
                        } else {
                          tienda.editarCategoria(Categoria(
                              id: categoria.id,
                              nombre: nombre,
                              activa: categoria.activa));
                        }
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Guardar'))
                ])).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {
                              final eliminada = Tienda.instancia
                                  .eliminarCategoria(categoria.id);
                              setState(() {});
                              if (!eliminada) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'No se puede eliminar una categoría con productos.')));
                              }
                            },
                            icon: const Icon(Icons.delete))
                      ])));
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _editar(), child: const Icon(Icons.add)));
  }
}
