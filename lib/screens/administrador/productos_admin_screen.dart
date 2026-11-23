import 'package:material_ui/material_ui.dart';

import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';
import '../../widgets/logo_forno.dart';
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

  Future<void> _ajustarInventario(int id) async {
    final stock = Tienda.instancia.inventario[id];
    var existencias = stock?.existencias.toString() ?? '0';
    var minimo = stock?.stockMinimo.toString() ?? '0';
    final conteo = await showDialog<(int, int)>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Ajustar inventario'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  initialValue: existencias,
                  keyboardType: TextInputType.number,
                  onChanged: (valor) => existencias = valor,
                  decoration: const InputDecoration(labelText: 'Existencias')),
              TextFormField(
                  initialValue: minimo,
                  keyboardType: TextInputType.number,
                  onChanged: (valor) => minimo = valor,
                  decoration: const InputDecoration(labelText: 'Stock mínimo')),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar')),
              FilledButton(
                  onPressed: () {
                    final cantidad = int.tryParse(existencias);
                    final umbral = int.tryParse(minimo);
                    if (cantidad == null ||
                        umbral == null ||
                        cantidad < 0 ||
                        umbral < 0) {
                      return;
                    }
                    Navigator.pop(context, (cantidad, umbral));
                  },
                  child: const Text('Guardar')),
            ],
          );
        });
    if (conteo == null || !mounted) return;
    await ejecutarOperacion(context,
        () => Tienda.instancia.ajustarInventario(id, conteo.$1, conteo.$2));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Tienda.instancia,
        builder: (context, _) => _contenido(context),
      );

  Widget _contenido(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
        title: const Text('Productos'),
      ),
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
                      '${categoria?.nombre ?? 'Sin categoría'} · ${formatoPesosColombianos(producto.precio)} · Existencias ${tienda.inventario[producto.id]?.existencias ?? '—'}${tienda.inventario[producto.id]?.stockBajo == true ? ' · Stock bajo' : ''}'),
                  trailing: PopupMenuButton<String>(
                      onSelected: (opcion) async {
                        if (opcion == 'editar') {
                          _formulario(producto: producto);
                        }
                        if (opcion == 'eliminar') {
                          await ejecutarOperacion(context,
                              () => tienda.eliminarProducto(producto.id));
                        }
                        if (opcion == 'inventario') {
                          await _ajustarInventario(producto.id);
                        }
                      },
                      itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'editar', child: Text('Editar')),
                            PopupMenuItem(
                                value: 'inventario',
                                child: Text('Ajustar inventario')),
                            PopupMenuItem(
                                value: 'eliminar', child: Text('Desactivar'))
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
