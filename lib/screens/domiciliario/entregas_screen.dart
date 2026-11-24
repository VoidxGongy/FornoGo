import 'package:material_ui/material_ui.dart';

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
                ? pedido.estado == EstadoPedido.entregado ||
                    pedido.estado == EstadoPedido.extraviado
                : pedido.estado != EstadoPedido.entregado &&
                    pedido.estado != EstadoPedido.rechazado &&
                    pedido.estado != EstadoPedido.cancelado &&
                    pedido.estado != EstadoPedido.extraviado)
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
                    final puedeActualizar =
                        pedido.estado != EstadoPedido.entregado &&
                            pedido.estado != EstadoPedido.rechazado &&
                            pedido.estado != EstadoPedido.cancelado &&
                            pedido.estado != EstadoPedido.extraviado;
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
                                  '${pedido.direccion}\nEstado: ${pedido.estado}\nTotal: ${formatoPesosColombianos(pedido.total)}'),
                              isThreeLine: true,
                              trailing: _estadoEntrega(pedido),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: puedeActualizar
                                    ? () => _confirmar(pedido)
                                    : null,
                                icon: const Icon(Icons.sync),
                                label:
                                    Text(pedido.estado == EstadoPedido.entregado
                                        ? 'Pedido entregado'
                                        : puedeActualizar
                                            ? 'Actualizar estado'
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
        entregado ? Icons.check_circle : Icons.local_shipping_outlined,
        size: 18,
      ),
      label: Text(pedido.estado),
    );
  }

  Future<void> _confirmar(Pedido pedido) async {
    final estados = pedido.estado == EstadoPedido.enCamino
        ? [EstadoPedido.entregado]
        : [EstadoPedido.enCamino];
    var estado = estados.first;
    String metodo = pedido.metodoPago;
    final respuesta = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (context, actualizar) => AlertDialog(
                title: Text('Actualizar pedido #${pedido.id}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: estado,
                      decoration:
                          const InputDecoration(labelText: 'Nuevo estado'),
                      items: [
                        for (final opcion in estados)
                          DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                          ),
                      ],
                      onChanged: (v) =>
                          actualizar(() => estado = v ?? estado),
                    ),
                    if (estado == EstadoPedido.entregado) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: metodo,
                        decoration: const InputDecoration(
                            labelText: 'Método de pago recibido'),
                        items: const [
                          DropdownMenuItem(
                              value: MetodoPago.efectivo,
                              child: Text('Efectivo')),
                          DropdownMenuItem(
                              value: MetodoPago.transferencia,
                              child: Text('Transferencia')),
                          DropdownMenuItem(
                              value: MetodoPago.tarjeta,
                              child: Text('Tarjeta')),
                        ],
                        onChanged: (v) =>
                            actualizar(() => metodo = v ?? metodo),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(
                          context,
                          (estado, estado == EstadoPedido.entregado
                              ? metodo
                              : null)),
                      child: const Text('Guardar estado')),
                ],
              )),
    );
    if (respuesta != null && mounted) {
      await ejecutarOperacion(
          context,
          () => Tienda.instancia.actualizarEstadoDomiciliario(
                pedidoId: pedido.id,
                estado: respuesta.$1,
                metodoPago: respuesta.$2,
              ));
    }
  }
}
