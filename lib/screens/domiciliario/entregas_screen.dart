import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../../models/sesion.dart';
import '../../services/tienda.dart';
import '../../utils/formato_moneda.dart';
<<<<<<< HEAD
=======
import '../../widgets/logo_forno.dart';
>>>>>>> 4e4b37b (Mejora del menu y detelles)

class EntregasScreen extends StatefulWidget {
  const EntregasScreen({super.key, this.mostrarCompletados = false});

  final bool mostrarCompletados;

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  @override
  Widget build(BuildContext context) {
    final sesion = Tienda.instancia.sesion;
    final todas = sesion?.rol == Rol.domiciliario
        ? Tienda.instancia.pedidos
            .where((pedido) => pedido.domiciliarioId == sesion!.usuarioId)
            .toList()
        : <Pedido>[];
    final entregas = todas
        .where((pedido) => widget.mostrarCompletados
            ? pedido.estado == EstadoPedido.entregado
            : pedido.estado != EstadoPedido.entregado &&
                pedido.estado != EstadoPedido.rechazado)
        .toList();
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Mis entregas')),
=======
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
        title: const Text('Mis entregas'),
      ),
>>>>>>> 4e4b37b (Mejora del menu y detelles)
      body: entregas.isEmpty
          ? Center(
              child: Text(widget.mostrarCompletados
                  ? 'No tienes entregas completadas.'
                  : 'No tienes entregas pendientes.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entregas.length,
              itemBuilder: (_, index) {
                final pedido = entregas[index];
                return Card(
                  child: ListTile(
                    title:
                        Text('Pedido #${pedido.id} · ${pedido.nombreCliente}'),
                    subtitle: Text(
                        '${pedido.direccion}\nTotal: ${formatoPesosColombianos(pedido.total)}'),
                    isThreeLine: true,
                    trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => _confirmar(pedido)),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmar(Pedido pedido) async {
    String metodo = pedido.metodoPago;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (context, actualizar) => AlertDialog(
                title: Text('Confirmar pedido #${pedido.id}'),
                content: DropdownButtonFormField<String>(
                    initialValue: metodo,
                    items: const [
                      DropdownMenuItem(
                          value: MetodoPago.efectivo, child: Text('Efectivo')),
                      DropdownMenuItem(
                          value: MetodoPago.transferencia,
                          child: Text('Transferencia')),
                      DropdownMenuItem(
                          value: MetodoPago.tarjeta, child: Text('Tarjeta'))
                    ],
                    onChanged: (v) => actualizar(() => metodo = v ?? metodo)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirmar entrega'))
                ],
              )),
    );
    if (confirmado == true) {
      Tienda.instancia
          .confirmarEntrega(pedidoId: pedido.id, metodoPago: metodo);
      setState(() {});
    }
  }
}
