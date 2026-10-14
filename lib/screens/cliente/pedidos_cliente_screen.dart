import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../../services/tienda.dart';
import '../../utils/formato_moneda.dart';

class PedidosClienteScreen extends StatefulWidget {
  const PedidosClienteScreen({super.key});

  @override
  State<PedidosClienteScreen> createState() => _PedidosClienteScreenState();
}

class _PedidosClienteScreenState extends State<PedidosClienteScreen> {
  @override
  Widget build(BuildContext context) {
    final sesion = Tienda.instancia.sesion;
    final pedidos = sesion == null
        ? <Pedido>[]
        : Tienda.instancia.pedidosDeCliente(sesion.usuarioId).reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: pedidos.isEmpty
          ? const Center(child: Text('Todavía no tienes pedidos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pedidos.length,
              itemBuilder: (_, index) {
                final pedido = pedidos[index];
                return Card(
                    child: ExpansionTile(
                  title: Text('Pedido #${pedido.id} · ${pedido.estado}'),
                  subtitle: Text(
                      '${formatoPesosColombianos(pedido.total)} · ${pedido.metodoPago}'),
                  children: [
                    ...pedido.items.map((item) => ListTile(
                        dense: true,
                        title: Text('${item.cantidad} × ${item.nombre}'),
                        trailing:
                            Text(formatoPesosColombianos(item.subtotal)))),
                    ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(pedido.direccion),
                        subtitle: Text(pedido.referencias.isEmpty
                            ? 'Sin referencias'
                            : pedido.referencias)),
                  ],
                ));
              },
            ),
    );
  }
}
