import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
  PlatformFile? _comprobante;

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
    if (_metodoPago == MetodoPago.transferencia && _comprobante == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona la captura de la transferencia.'),
      ));
      return;
    }
    setState(() => _confirmando = true);
    String? pedidoId;
    final guardado = await ejecutarOperacion(
        context,
        () async => pedidoId = await Tienda.instancia.confirmarPedido(
              direccion: _direccion.text.trim(),
              referencias: _referencias.text.trim(),
              metodoPago: _metodoPago,
            ));
    if (!mounted) return;
    setState(() => _confirmando = false);
    if (!guardado) return;
    if (_metodoPago == MetodoPago.transferencia && pedidoId != null) {
      await _abrirWhatsApp(pedidoId!);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado para confirmación.')));
    Navigator.pop(context);
  }

  Future<void> _seleccionarComprobante() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (!mounted || resultado == null) return;
    setState(() => _comprobante = resultado.files.single);
  }

  Future<void> _abrirWhatsApp(String pedidoId) async {
    final archivo = _comprobante?.name ?? 'captura de transferencia';
    final mensaje = Uri.encodeComponent(
      'FornoGO - Comprobante de transferencia\n'
      'Pedido: $pedidoId\n'
      'Archivo seleccionado: $archivo\n'
      'Adjunto la captura del pago.',
    );
    final uri = Uri.parse('https://wa.me/573053325716?text=$mensaje');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo abrir WhatsApp.'),
      ));
    }
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _confirmando ? null : _seleccionarComprobante,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(_comprobante == null
                    ? 'Seleccionar captura de transferencia'
                    : 'Cambiar captura: ${_comprobante!.name}'),
              ),
              const SizedBox(height: 4),
              const Text(
                'Después de confirmar se abrirá WhatsApp al 305 332 5716. '
                'Confirma el envío y adjunta la captura seleccionada.',
                style: TextStyle(fontSize: 12),
              ),
            ],
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
