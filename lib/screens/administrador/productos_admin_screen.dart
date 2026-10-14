import 'package:flutter/material.dart';

import '../../services/tienda.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';
import 'producto_form_screen.dart';

class ProductosAdminScreen extends StatefulWidget {
  const ProductosAdminScreen({super.key});
  @override
  State<ProductosAdminScreen> createState() => _ProductosAdminScreenState();
}

class _ProductosAdminScreenState extends State<ProductosAdminScreen> {
  Future<void> _formulario({Object? producto}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductoFormScreen(producto: producto as dynamic)));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: tienda.productos.isEmpty
          ? const Center(child: Text('No hay productos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tienda.productos.length,
              itemBuilder: (_, index) {
                final producto = tienda.productos[index];
                final categoria =
                    tienda.buscarCategoriaPorId(producto.categoriaId);
                return Card(
                    child: ListTile(
                  leading: ImagenProducto(
                      ruta: producto.rutaImagen, esAsset: producto.esAsset),
                  title: Text(producto.nombre),
                  subtitle: Text(
                      '${categoria?.nombre ?? 'Sin categoría'} · ${formatoPesosColombianos(producto.precio)}'),
                  trailing: PopupMenuButton<String>(
                      onSelected: (opcion) {
                        if (opcion == 'editar') _formulario(producto: producto);
                        if (opcion == 'eliminar') {
                          tienda.eliminarProducto(producto.id);
                          setState(() {});
                        }
                      },
                      itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'editar', child: Text('Editar')),
                            PopupMenuItem(
                                value: 'eliminar', child: Text('Eliminar'))
                          ]),
                ));
              },
            ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'admin-producto-fab',
          onPressed: () => _formulario(),
          child: const Icon(Icons.add)),
    );
  }
}
