import 'package:material_ui/material_ui.dart';

import '../../models/pedido.dart';
import '../../services/tienda.dart';
import '../../utils/formato_moneda.dart';
import '../../widgets/imagen_producto.dart';
import '../../widgets/logo_forno.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});

  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  final Map<int, int?> _seleccionesDomiciliario = {};

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
    final idsDomiciliarios = <int>{};
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
    final estados = <String>{...EstadoPedido.secuencia, pedido.estado}.toList();
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
              initialValue: pedido.estado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: estados
                  .map((estado) =>
                      DropdownMenuItem(value: estado, child: Text(estado)))
                  .toList(),
              onChanged: (estado) {
                if (estado != null) {
                  tienda.actualizarEstadoPedido(pedido.id, estado);
                  setState(() {});
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              initialValue: domiciliarioSeleccionado,
              decoration:
                  const InputDecoration(labelText: 'Domiciliario asignado'),
              hint: const Text('Seleccionar domiciliario'),
              items: opcionesDomiciliarios
                  .map((domiciliario) => DropdownMenuItem(
                      value: domiciliario.id, child: Text(domiciliario.nombre)))
                  .toList(),
              onChanged: (id) {
                setState(() => _seleccionesDomiciliario[pedido.id] = id);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: domiciliarioSeleccionado == null
                    ? null
                    : () {
                        final asignado = tienda.asignarDomiciliario(
                          pedido.id,
                          domiciliarioSeleccionado,
                        );
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
        ],
      ),
    );
  }
}
