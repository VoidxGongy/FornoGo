import 'package:flutter/material.dart';

import '../../models/pedido.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';
import '../../widgets/logo_forno.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  final Map<String, String?> _seleccionesDomiciliario = {};

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
        title: const Text('Pedidos recibidos'),
      ),
      body: AnimatedBuilder(
        animation: tienda,
        builder: (context, _) {
          final pedidos = tienda.pedidos.reversed.toList();
          return pedidos.isEmpty
              ? const Center(child: Text('No hay pedidos registrados.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pedidos.length,
                  itemBuilder: (_, index) => _pedidoCard(pedidos[index]),
                );
        },
      ),
    );
  }

  Widget _pedidoCard(Pedido pedido) {
    final tienda = Tienda.instancia;
    final domiciliarios = tienda.domiciliariosActivos();
    final idsDomiciliarios = <String>{};
    final opcionesDomiciliarios = domiciliarios
        .where((domiciliario) => idsDomiciliarios.add(domiciliario.id))
        .toList();
    final candidatoDomiciliario =
        _seleccionesDomiciliario[pedido.id] ?? pedido.domiciliarioId;
    // Un pedido antiguo puede apuntar a un domiciliario eliminado o inactivo.
    // DropdownButton exige que initialValue exista exactamente una vez.
    final domiciliarioSeleccionado = candidatoDomiciliario != null &&
            idsDomiciliarios.contains(candidatoDomiciliario)
        ? candidatoDomiciliario
        : null;
    final puedeGestionar = pedido.estado != EstadoPedido.entregado &&
        pedido.estado != EstadoPedido.cancelado &&
        pedido.estado != EstadoPedido.extraviado;
    return Card(
      child: ExpansionTile(
        title: Text('Pedido #${pedido.id} · ${pedido.nombreCliente}'),
        subtitle:
            Text('${pedido.estado} · ${formatoPesosColombianos(pedido.total)}'),
        children: [
          ...pedido.items.map((item) {
            final producto = tienda.buscarProductoPorId(item.productoId);
            return ListTile(
              dense: true,
              leading: ImagenProducto(
                ruta: producto?.rutaImagen ?? '',
                esAsset: producto?.esAsset ?? true,
                nombreProducto: item.nombre,
                width: 48,
                height: 48,
                borderRadius: 10,
              ),
              title: Text('${item.cantidad} × ${item.nombre}'),
              trailing: Text(formatoPesosColombianos(item.subtotal)),
            );
          }),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(pedido.direccion),
            subtitle: Text(pedido.telefono),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              key: ValueKey((pedido.id, pedido.estado)),
              initialValue: pedido.estado,
              decoration: const InputDecoration(
                labelText: 'Estado del pedido',
              ),
              items: EstadoPedido.estadosAdministrables
                  .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      ))
                  .toList(),
              onChanged: (estado) {
                if (estado == null || estado == pedido.estado) return;
                ejecutarOperacion(
                  context,
                  () =>
                      tienda.actualizarEstadoAdministrativo(pedido.id, estado),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              key: ValueKey((
                pedido.id,
                pedido.domiciliarioId,
                domiciliarioSeleccionado,
              )),
              initialValue: domiciliarioSeleccionado,
              decoration:
                  const InputDecoration(labelText: 'Domiciliario asignado'),
              hint: const Text('Seleccionar domiciliario'),
              items: opcionesDomiciliarios
                  .map((domiciliario) => DropdownMenuItem(
                      value: domiciliario.id, child: Text(domiciliario.nombre)))
                  .toList(),
              onChanged: (id) {
                setState(() {
                  if (id == null) {
                    _seleccionesDomiciliario.remove(pedido.id);
                  } else {
                    _seleccionesDomiciliario[pedido.id] = id;
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !puedeGestionar || domiciliarioSeleccionado == null
                    ? null
                    : () async {
                        final asignado =
                            await ejecutarOperacion(context, () async {
                          await tienda.asignarDomiciliario(
                            pedido.id,
                            domiciliarioSeleccionado,
                          );
                        });
                        if (!mounted) return;
                        if (asignado) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido asignado correctamente.'),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.delivery_dining_outlined),
                label: Text(
                  pedido.domiciliarioId == null
                      ? 'Asignar pedido'
                      : 'Guardar asignación',
                ),
              ),
            ),
          ),
          if (puedeGestionar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _actualizarIncidencia(
                      pedido,
                      '¿Cancelar este pedido?',
                      'cancelar',
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar pedido'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _actualizarIncidencia(
                      pedido,
                      '¿Marcar este pedido como extraviado?',
                      'extraviar',
                    ),
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Marcar extraviado'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _actualizarIncidencia(
      Pedido pedido, String pregunta, String accion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar pedido'),
        content: Text(pregunta),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final actualizado = await ejecutarOperacion(
      context,
      () => accion == 'cancelar'
          ? Tienda.instancia.cancelarPedido(pedido.id)
          : Tienda.instancia.marcarPedidoExtraviado(pedido.id),
    );
    if (actualizado && mounted) setState(() {});
  }
}
