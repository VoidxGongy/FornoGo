import 'package:flutter/material.dart';

import '../theme/tema_fornogo.dart';

/// Barra inferior reutilizable para los tres perfiles de FornoGO.
class BarraNavegacionInferior extends StatelessWidget {
  const BarraNavegacionInferior({
    super.key,
    required this.indiceSeleccionado,
    required this.destinos,
    required this.alCambiar,
  });

  final int indiceSeleccionado;
  final List<NavigationDestination> destinos;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: TemaFornoGO.superficie,
          border: Border(top: BorderSide(color: TemaFornoGO.borde)),
        ),
        child: NavigationBar(
          selectedIndex: indiceSeleccionado,
          onDestinationSelected: alCambiar,
          destinations: destinos,
          backgroundColor: TemaFornoGO.superficie,
          indicatorColor: const Color(0xFFFDECEC),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}
