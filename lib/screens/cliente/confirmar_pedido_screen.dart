import 'package:material_ui/material_ui.dart';

import '../../models/pedido.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../utils/formato_moneda.dart';

class ConfirmarPedidoScreen extends StatefulWidget {
  const ConfirmarPedidoScreen({super.key});

  @override
  State<ConfirmarPedidoScreen> createState() => _ConfirmarPedidoScreenState();
}

class _ConfirmarPedidoScreenState extends State<ConfirmarPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _direccion;
  final _referencias = TextEditingController();
  String _metodoPago = MetodoPago.efectivo;

  @override
  void initState() {
    super.initState();
    final cliente = Tienda.instancia.perfil;
    _direccion =
        TextEditingController(text: cliente?.direccionPredeterminada ?? '');
  }

  @override
  void dispose() {
    _direccion.dispose();
    _referencias.dispose();
    super.dispose();
  }

  bool _confirmando = false;

  Future<void> _confirmar() async {
    if (_confirmando || !_formKey.currentState!.validate()) return;
    setState(() => _confirmando = true);
    final guardado = await ejecutarOperacion(
        context,
        () => Tienda.instancia.confirmarPedido(
              direccion: _direccion.text.trim(),
              referencias: _referencias.text.trim(),
              metodoPago: _metodoPago,
            ));
    if (!mounted) return;
    setState(() => _confirmando = false);
    if (!guardado) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado para confirmación.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Total: ${formatoPesosColombianos(tienda.totalCarrito())}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
                controller: _direccion,
                decoration:
                    const InputDecoration(labelText: 'Dirección de entrega'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La dirección es obligatoria'
                    : null),
            TextFormField(
                controller: _referencias,
                decoration:
                    const InputDecoration(labelText: 'Referencias (opcional)')),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
                initialValue: _metodoPago,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(
                      value: MetodoPago.efectivo, child: Text('Efectivo')),
                  DropdownMenuItem(
                      value: MetodoPago.transferencia,
                      child: Text('Transferencia bancaria')),
                  DropdownMenuItem(
                      value: MetodoPago.tarjeta,
                      child: Text('Tarjeta en datáfono'))
                ],
                onChanged: (v) =>
                    setState(() => _metodoPago = v ?? MetodoPago.efectivo)),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _confirmando ? null : _confirmar,
                child: const Text('Confirmar pedido')),
          ],
        ),
      ),
    );
  }
}
