import 'package:material_ui/material_ui.dart';

import '../../models/producto.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final Producto producto;
  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contenido = _informacionProducto(context, producto);
          final imagen = Hero(
            tag: 'producto-${producto.id}',
            child: ImagenProducto(
              ruta: producto.rutaImagen,
              esAsset: producto.esAsset,
              nombreProducto: producto.nombre,
              width: double.infinity,
              height: double.infinity,
              borderRadius: 18,
              fit: BoxFit.cover,
            ),
          );
          final amplio = constraints.maxWidth >= 820;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: amplio
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AspectRatio(aspectRatio: 1, child: imagen),
                          ),
                          const SizedBox(width: 32),
                          Expanded(child: contenido),
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(height: 240, child: imagen),
                          const SizedBox(height: 24),
                          contenido,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _informacionProducto(BuildContext context, Producto producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.nombre,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(producto.descripcion),
        const SizedBox(height: 16),
        Text(
          formatoPesosColombianos(producto.precio),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed:
                  _cantidad > 1 ? () => setState(() => _cantidad--) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_cantidad', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              onPressed: () => setState(() => _cantidad++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              final guardado = await ejecutarOperacion(
                context,
                () => Tienda.instancia.agregarAlCarrito(producto, _cantidad),
              );
              if (!guardado || !context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Producto agregado al carrito'),
              ));
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Agregar al carrito'),
          ),
        ),
      ],
    );
  }
}
