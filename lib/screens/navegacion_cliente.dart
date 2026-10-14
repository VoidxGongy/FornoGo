import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/tienda.dart';
import '../widgets/barra_navegacion_inferior.dart';
import 'cliente/carrito_screen.dart';
import 'cliente/catalogo_screen.dart';
import 'cliente/pedidos_cliente_screen.dart';
import 'inicio/login_screen.dart';
import 'perfil_screen.dart';

class NavegacionCliente extends StatefulWidget {
  const NavegacionCliente({super.key});

  @override
  State<NavegacionCliente> createState() => _NavegacionClienteState();
}

class _NavegacionClienteState extends State<NavegacionCliente> {
  int _indice = 0;

  void _cerrarSesion() {
    Tienda.instancia.cerrarSesion();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cantidad = Tienda.instancia.carrito
        .fold<int>(0, (total, item) => total + item.cantidad);
    return AnimatedBuilder(
      animation: Tienda.instancia,
      builder: (context, _) => Scaffold(
        body: IndexedStack(
          index: _indice,
          children: [
            const CatalogoScreen(),
            const CarritoScreen(),
            const PedidosClienteScreen(),
            PerfilScreen(rol: Rol.cliente, cerrarSesion: _cerrarSesion),
          ],
        ),
        bottomNavigationBar: BarraNavegacionInferior(
          indiceSeleccionado: _indice,
          alCambiar: (indice) => setState(() => _indice = indice),
          destinos: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio'),
            NavigationDestination(
                icon: _iconoCarrito(Icons.shopping_bag_outlined, cantidad),
                selectedIcon: _iconoCarrito(Icons.shopping_bag, cantidad),
                label: 'Carrito'),
            const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Pedidos'),
            const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _iconoCarrito(IconData icono, int cantidad) {
    return Badge(
        isLabelVisible: cantidad > 0,
        label: Text('$cantidad'),
        child: Icon(icono));
  }
}
