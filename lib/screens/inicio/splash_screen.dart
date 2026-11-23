import 'package:material_ui/material_ui.dart';

import '../../services/tienda.dart';
import '../../theme/tema_fornogo.dart';
import '../../widgets/logo_forno.dart';
import '../navegacion/rol_home_screen.dart';
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
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _animacion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _cargarAplicacion();
  }

  Future<void> _cargarAplicacion() async {
    try {
      await Tienda.instancia.inicializar();
    } catch (_) {
      if (mounted) setState(() => _error = true);
      return;
    }
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
                    const SizedBox(height: 48),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      child: _error
                          ? TextButton(
                              key: const ValueKey('error'),
                              onPressed: () {
                                setState(() => _error = false);
                                _cargarAplicacion();
                              },
                              child:
                                  const Text('Error de conexión. Reintentar'))
                          : !_listo
                              ? const CircularProgressIndicator(
                                  key: ValueKey('cargando'),
                                )
                              : Column(
                                  key: const ValueKey('acciones'),
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      height: 50,
                                      child: FilledButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
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
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegistroClienteScreen(),
                                          ),
                                        ),
                                        child: const Text('Crear cuenta'),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
