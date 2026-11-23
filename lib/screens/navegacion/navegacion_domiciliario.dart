import 'package:flutter/material.dart';

import '../../models/sesion.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';
import '../../widgets/barra_navegacion_inferior.dart';
import '../domiciliario/entregas_screen.dart';
import '../compartidos/perfil_screen.dart';

class NavegacionDomiciliario extends StatefulWidget {
  const NavegacionDomiciliario({super.key});

  @override
  State<NavegacionDomiciliario> createState() => _NavegacionDomiciliarioState();
}

class _NavegacionDomiciliarioState extends State<NavegacionDomiciliario> {
  int _indice = 0;

  void _cerrarSesion() =>
      ejecutarOperacion(context, Tienda.instancia.cerrarSesion);

  @override
  Widget build(BuildContext context) {
    return NavegacionAdaptable(
      body: IndexedStack(
        index: _indice,
        children: [
          const EntregasScreen(),
          const EntregasScreen(mostrarCompletados: true),
          PerfilScreen(rol: Rol.domiciliario, cerrarSesion: _cerrarSesion),
        ],
      ),
      indiceSeleccionado: _indice,
      alCambiar: (indice) => setState(() => _indice = indice),
      destinos: const [
        NavigationDestination(
            icon: Icon(Icons.delivery_dining_outlined),
            selectedIcon: Icon(Icons.delivery_dining),
            label: 'Asignados'),
        NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Completados'),
        NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil'),
      ],
    );
  }
}
