import 'package:flutter/material.dart';

import '../../services/tienda.dart';
import '../../widgets/logo_forno.dart';
import '../rol_home_screen.dart';
import 'registro_cliente_screen.dart';

/// Inicio de sesión local para los tres perfiles de FornoGO.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  bool _ocultarClave = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  void _iniciarSesion() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    final correcto = Tienda.instancia.iniciarSesion(
      _correoController.text.trim(),
      _claveController.text,
    );
    setState(() => _cargando = false);

    if (!correcto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo o contraseña incorrectos.')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RolHomeScreen()),
    );
  }

  Future<void> _abrirRegistro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroClienteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LogoForno(size: 124),
                  const SizedBox(height: 12),
                  Text(
                    'FornoGO',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu pizza favorita, hasta tu puerta',
                    textAlign: TextAlign.center,
                  ),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _correoController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.email_outlined)),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!valor.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _claveController,
                            obscureText: _ocultarClave,
                            decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                    onPressed: () => setState(
                                        () => _ocultarClave = !_ocultarClave),
                                    icon: Icon(_ocultarClave
                                        ? Icons.visibility
                                        : Icons.visibility_off))),
                            validator: (valor) => valor == null || valor.isEmpty
                                ? 'Ingresa tu contraseña'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                  onPressed: _cargando ? null : _iniciarSesion,
                                  child: Text(_cargando
                                      ? 'Ingresando...'
                                      : 'Iniciar sesión'))),
                          TextButton(
                              onPressed: _abrirRegistro,
                              child: const Text('Crear cuenta de cliente')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
