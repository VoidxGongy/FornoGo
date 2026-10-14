import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cliente.dart';
import '../../models/pedido.dart';
import '../../services/tienda.dart';
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
    final cliente = _cliente;
    _direccion =
        TextEditingController(text: cliente?.direccionPredeterminada ?? '');
  }

  Cliente? get _cliente {
    final sesion = Tienda.instancia.sesion;
    if (sesion == null) return null;
    return Tienda.instancia.buscarClientePorId(sesion.usuarioId);
  }

  @override
  void dispose() {
    _direccion.dispose();
    _referencias.dispose();
    super.dispose();
  }

  Future<void> _abrirWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/573118965528?text=Hola%20FornoGO,%20quiero%20confirmar%20una%20transferencia');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')));
    }
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    final cliente = _cliente;
    if (cliente == null || Tienda.instancia.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay cliente o productos para confirmar.')));
      return;
    }
    Tienda.instancia.confirmarPedido(
      cliente: cliente,
      direccion: _direccion.text.trim(),
      referencias: _referencias.text.trim(),
      metodoPago: _metodoPago,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido confirmado correctamente.')));
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
            if (_metodoPago == MetodoPago.transferencia) ...[
              const SizedBox(height: 16),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Datos bancarios',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text(
                                'Banco FornoGO\nCuenta de ahorros: 123-456-789\nTitular: FornoGO S.A.S.'),
                            TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text:
                                          'Banco FornoGO - Cuenta 123-456-789'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Datos copiados.')));
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copiar datos')),
                            OutlinedButton.icon(
                                onPressed: _abrirWhatsApp,
                                icon: const Icon(Icons.chat),
                                label: const Text(
                                    'Enviar comprobante por WhatsApp'))
                          ]))),
            ],
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _confirmar, child: const Text('Confirmar pedido')),
          ],
        ),
      ),
    );
  }
}
