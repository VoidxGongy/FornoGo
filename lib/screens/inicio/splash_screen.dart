import 'package:flutter/material.dart';

import '../../services/preferencias.dart';
import '../../services/tienda.dart';
import '../../theme/tema_fornogo.dart';
import '../../data/imagenes_productos.dart';
import '../../widgets/logo_forno.dart';
import '../../widgets/imagen_producto.dart';
import '../rol_home_screen.dart';
import 'login_screen.dart';
import 'registro_cliente_screen.dart';

/// Carga la persistencia antes de dirigir al usuario al flujo correspondiente.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animacion;
  bool _listo = false;

  @override
  void initState() {
    super.initState();
    _animacion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _cargarAplicacion();
  }

  Future<void> _cargarAplicacion() async {
    await Preferencias.instancia.init();
    await Tienda.instancia.cargarPersistencia();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    if (Tienda.instancia.sesion != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RolHomeScreen()),
      );
    } else {
      setState(() => _listo = true);
    }
  }

  @override
  void dispose() {
    _animacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _animacion,
            child: ScaleTransition(
              scale: Tween<double>(begin: .85, end: 1).animate(
                  CurvedAnimation(parent: _animacion, curve: Curves.easeOut)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LogoForno(size: 150),
                    const SizedBox(height: 16),
                    Text('FornoGO',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: TemaFornoGO.rojo,
                                fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Tu pizza favorita, hasta tu puerta',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    const ImagenProducto(
                      ruta: ImagenesProductos.margarita,
                      esAsset: true,
                      width: 180,
                      height: 120,
                      borderRadius: 24,
                      nombreProducto: 'Pizza Margarita',
                    ),
                    const SizedBox(height: 28),
                    if (!_listo)
                      const CircularProgressIndicator()
                    else ...[
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: FilledButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: const Text('Iniciar sesión'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegistroClienteScreen(),
                            ),
                          ),
                          child: const Text('Crear cuenta'),
                        ),
                      ),
                    ],
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
