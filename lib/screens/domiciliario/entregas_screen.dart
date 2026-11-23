import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../../models/sesion.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/logo_forno.dart';

class EntregasScreen extends StatefulWidget {
  const EntregasScreen({super.key, this.mostrarCompletados = false});

  final bool mostrarCompletados;

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Tienda.instancia,
      builder: (context, _) {
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
                    pedido.estado != EstadoPedido.rechazado &&
                    pedido.estado != EstadoPedido.cancelado)
            .toList();
        return Scaffold(
          appBar: AppBar(
            leading: const Padding(
              padding: EdgeInsets.all(6),
              child: LogoForno(size: 36, soloIcono: true),
            ),
            title: const Text('Mis entregas'),
          ),
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
                    final puedeIniciar = pedido.estado == EstadoPedido.listo;
                    final puedeConfirmar =
                        pedido.estado == EstadoPedido.enCamino;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                  'Pedido #${pedido.id} · ${pedido.nombreCliente}'),
                              subtitle: Text(
                                  '${pedido.direccion}\nTotal: ${formatoPesosColombianos(pedido.total)}'),
                              isThreeLine: true,
                              trailing: _estadoEntrega(pedido),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: puedeIniciar
                                    ? () => _iniciarEntrega(pedido)
                                    : puedeConfirmar
                                        ? () => _confirmar(pedido)
                                        : null,
                                icon: Icon(puedeIniciar
                                    ? Icons.local_shipping_outlined
                                    : Icons.sync),
                                label:
                                    Text(pedido.estado == EstadoPedido.entregado
                                        ? 'Pedido entregado'
                                        : puedeIniciar
                                            ? 'Iniciar entrega'
                                            : puedeConfirmar
                                                ? 'Confirmar entrega'
                                                : 'Aún no entregado'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _estadoEntrega(Pedido pedido) {
    final entregado = pedido.estado == EstadoPedido.entregado;
    return Chip(
      avatar: Icon(
        entregado ? Icons.check_circle : Icons.schedule,
        size: 18,
      ),
      label: Text(entregado ? 'Entregado' : 'Aún no entregado'),
    );
  }

  Future<void> _iniciarEntrega(Pedido pedido) async {
    if (!mounted) return;
    await ejecutarOperacion(
        context, () => Tienda.instancia.iniciarEntrega(pedido.id));
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
    if (confirmado == true && mounted) {
      await ejecutarOperacion(
          context,
          () => Tienda.instancia.confirmarEntrega(
                pedidoId: pedido.id,
                metodoPago: metodo,
              ));
    }
  }
}
