import 'package:material_ui/material_ui.dart';

import '../../models/sesion.dart';
import '../../services/tienda.dart';
import '../inicio/login_screen.dart';
import 'navegacion_administrador.dart';
import 'navegacion_cliente.dart';
import 'navegacion_domiciliario.dart';

class RolHomeScreen extends StatelessWidget {
  const RolHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Tienda.instancia,
        builder: (context, _) => switch (Tienda.instancia.sesion?.rol) {
          Rol.administrador => const NavegacionAdministrador(),
          Rol.domiciliario => const NavegacionDomiciliario(),
          Rol.cliente => const NavegacionCliente(),
          _ => const LoginScreen(),
        },
      );
}
