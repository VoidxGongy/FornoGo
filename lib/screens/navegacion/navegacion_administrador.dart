import 'package:material_ui/material_ui.dart';

import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import '../administrador/domiciliarios_admin_screen.dart';
import '../administrador/pedidos_admin_screen.dart';
import '../administrador/productos_admin_screen.dart';
import '../administrador/mas_admin_screen.dart';

class NavegacionAdministrador extends StatefulWidget {
  const NavegacionAdministrador({super.key});

  @override
  State<NavegacionAdministrador> createState() =>
      _NavegacionAdministradorState();
}

class _NavegacionAdministradorState extends State<NavegacionAdministrador> {
  int _indice = 0;

  void _cerrarSesion() =>
      ejecutarOperacion(context, Tienda.instancia.cerrarSesion);

  @override
  Widget build(BuildContext context) {
    return NavegacionAdaptable(
      body: IndexedStack(
        index: _indice,
        children: [
          const PedidosAdminScreen(),
          const ProductosAdminScreen(),
          const DomiciliariosAdminScreen(),
          MasAdminScreen(cerrarSesion: _cerrarSesion),
        ],
      ),
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
    );
  }
}
