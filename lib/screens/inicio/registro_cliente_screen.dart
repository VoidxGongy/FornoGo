import 'package:flutter/material.dart';

import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../widgets/logo_forno.dart';

/// Registro público disponible únicamente para clientes.
class RegistroClienteScreen extends StatefulWidget {
  const RegistroClienteScreen({super.key});

  @override
  State<RegistroClienteScreen> createState() => _RegistroClienteScreenState();
}

class _RegistroClienteScreenState extends State<RegistroClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _claveController = TextEditingController();
  final _confirmarClaveController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _claveController.dispose();
    _confirmarClaveController.dispose();
    super.dispose();
  }

  String? _obligatorio(String? valor, String campo) {
    return valor == null || valor.trim().isEmpty
        ? '$campo es obligatorio'
        : null;
  }

  bool _registrando = false;

  Future<void> _registrar() async {
    if (_registrando || !_formKey.currentState!.validate()) return;
    setState(() => _registrando = true);
    final guardado = await ejecutarOperacion(
        context,
        () => Tienda.instancia.registrarCliente(
              nombre: _nombreController.text.trim(),
              correo: _correoController.text.trim(),
              clave: _claveController.text,
              telefono: _telefonoController.text.trim(),
              direccion: _direccionController.text.trim(),
            ));
    if (!mounted) return;
    setState(() => _registrando = false);
    if (guardado) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de cliente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(child: LogoForno(size: 90)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (valor) => _obligatorio(valor, 'El nombre'),
            ),
            TextFormField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (valor) {
                final error = _obligatorio(valor, 'El correo');
                if (error != null) return error;
                return valor!.contains('@') ? null : 'Correo inválido';
              },
            ),
            TextFormField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              validator: (valor) => _obligatorio(valor, 'El teléfono'),
            ),
            TextFormField(
              controller: _direccionController,
              decoration:
                  const InputDecoration(labelText: 'Dirección principal'),
              validator: (valor) => _obligatorio(valor, 'La dirección'),
            ),
            TextFormField(
              controller: _claveController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              validator: (valor) {
                if (valor == null || valor.length < 6) {
                  return 'Usa al menos 6 caracteres';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _confirmarClaveController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirmar contraseña'),
              validator: (valor) => valor != _claveController.text
                  ? 'Las contraseñas no coinciden'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _registrando ? null : _registrar,
              child: const Text('Registrar cliente'),
            ),
          ],
        ),
      ),
    );
  }
}
