import 'package:flutter/material.dart';

import '../services/tienda.dart';
import '../widgets/barra_navegacion_inferior.dart';
import 'administrador/domiciliarios_admin_screen.dart';
import 'administrador/pedidos_admin_screen.dart';
import 'administrador/productos_admin_screen.dart';
import 'inicio/login_screen.dart';
import 'mas_admin_screen.dart';

class NavegacionAdministrador extends StatefulWidget {
  const NavegacionAdministrador({super.key});

  @override
  State<NavegacionAdministrador> createState() =>
      _NavegacionAdministradorState();
}

class _NavegacionAdministradorState extends State<NavegacionAdministrador> {
  int _indice = 0;

  void _cerrarSesion() {
    Tienda.instancia.cerrarSesion();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: [
          const PedidosAdminScreen(),
          const ProductosAdminScreen(),
          const DomiciliariosAdminScreen(),
          MasAdminScreen(cerrarSesion: _cerrarSesion),
        ],
      ),
      bottomNavigationBar: BarraNavegacionInferior(
        indiceSeleccionado: _indice,
        alCambiar: (indice) => setState(() => _indice = indice),
        destinos: const [
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pedidos'),
          NavigationDestination(
              icon: Icon(Icons.local_pizza_outlined),
              selectedIcon: Icon(Icons.local_pizza),
              label: 'Productos'),
          NavigationDestination(
              icon: Icon(Icons.delivery_dining_outlined),
              selectedIcon: Icon(Icons.delivery_dining),
              label: 'Domiciliarios'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Más'),
        ],
      ),
    );
  }
}
