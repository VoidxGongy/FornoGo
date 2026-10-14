import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/tienda.dart';
import 'navegacion_administrador.dart';
import 'navegacion_cliente.dart';
import 'navegacion_domiciliario.dart';

/// Selecciona la navegación principal según el rol de la sesión local.
class RolHomeScreen extends StatelessWidget {
  const RolHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Tienda.instancia.sesion?.rol) {
      case Rol.administrador:
        return const NavegacionAdministrador();
      case Rol.domiciliario:
        return const NavegacionDomiciliario();
      default:
        return const NavegacionCliente();
    }
  }
}
