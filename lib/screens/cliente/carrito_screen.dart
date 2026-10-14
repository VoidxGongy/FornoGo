import 'package:flutter/material.dart';

import '../../services/tienda.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';
import '../../widgets/logo_forno.dart';
import 'confirmar_pedido_screen.dart';
import '../inicio/login_screen.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? const BackButton()
            : const Padding(
                padding: EdgeInsets.all(6),
                child: LogoForno(size: 36, soloIcono: true),
              ),
        title: const Text('Carrito'),
        actions: [
          IconButton(
            tooltip: 'Salir',
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: tienda,
        builder: (context, _) {
          final carrito = tienda.carrito;
          return carrito.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Tu carrito está vacío.',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text(
                            'Agrega una pizza o un acompañamiento para comenzar.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.restaurant_menu),
                          label: const Text('Volver al menú'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: carrito.length,
                        itemBuilder: (_, index) {
                          final item = carrito[index];
                          return ListTile(
                            leading: ImagenProducto(
                                ruta: item.rutaImagen,
                                esAsset: item.esAsset,
                                nombreProducto: item.nombre,
                                width: 64,
                                height: 64,
                                borderRadius: 12),
                            title: Text(item.nombre),
                            subtitle: Text(
                                '${formatoPesosColombianos(item.precioUnitario)} c/u'),
                            trailing: SizedBox(
                              width: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () => _cambiar(
                                          item.productoId, item.cantidad - 1),
                                      icon: const Icon(Icons.remove)),
                                  Text('${item.cantidad}'),
                                  IconButton(
                                      onPressed: () => _cambiar(
                                          item.productoId, item.cantidad + 1),
                                      icon: const Icon(Icons.add)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                              'Subtotal: ${formatoPesosColombianos(tienda.subtotalCarrito())}'),
                          Text(
                              'Domicilio: ${formatoPesosColombianos(kCostoDomicilio)}'),
                          Text(
                              'Total: ${formatoPesosColombianos(tienda.totalCarrito())}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                              onPressed: () {
                                tienda.vaciarCarrito();
                                setState(() {});
                              },
                              child: const Text('Vaciar carrito')),
                          FilledButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ConfirmarPedidoScreen()));
                              setState(() {});
                            },
                            child: const Text('Continuar con el pedido'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  void _cambiar(int id, int cantidad) {
    Tienda.instancia.cambiarCantidadCarrito(id, cantidad);
    setState(() {});
  }

  void _cerrarSesion() {
    Tienda.instancia.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
