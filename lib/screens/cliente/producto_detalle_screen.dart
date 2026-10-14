import 'package:flutter/material.dart';

import '../../models/producto.dart';
import '../../services/tienda.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Hero(
              tag: 'producto-${producto.id}',
              child: ImagenProducto(
                  ruta: producto.rutaImagen,
                  esAsset: producto.esAsset,
                  nombreProducto: producto.nombre,
                  width: double.infinity,
                  height: 240,
                  borderRadius: 16,
                  fit: BoxFit.cover)),
          const SizedBox(height: 20),
          Text(producto.nombre,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(producto.descripcion),
          const SizedBox(height: 12),
          Text(formatoPesosColombianos(producto.precio),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed:
                    _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                icon: const Icon(Icons.remove_circle_outline)),
            Text('$_cantidad', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
                onPressed: () => setState(() => _cantidad++),
                icon: const Icon(Icons.add_circle_outline))
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
                onPressed: () {
                  Tienda.instancia.agregarAlCarrito(producto, _cantidad);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Producto agregado al carrito')));
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Agregar al carrito')),
          ),
        ],
      ),
    );
  }
}
