import 'package:flutter/material.dart';

import '../theme/tema_fornogo.dart';
import 'logo_forno.dart';

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
        ),
        child: NavigationBar(
          selectedIndex: indiceSeleccionado,
          onDestinationSelected: alCambiar,
          destinations: destinos,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

/// Navegación inferior en teléfonos y rail persistente en pantallas amplias.
class NavegacionAdaptable extends StatelessWidget {
  const NavegacionAdaptable({
    super.key,
    required this.body,
    required this.indiceSeleccionado,
    required this.destinos,
    required this.alCambiar,
  });

  final Widget body;
  final int indiceSeleccionado;
  final List<NavigationDestination> destinos;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pantallaAmplia = constraints.maxWidth >= 840;
        if (!pantallaAmplia) {
          return Scaffold(
            body: body,
            bottomNavigationBar: BarraNavegacionInferior(
              indiceSeleccionado: indiceSeleccionado,
              destinos: destinos,
              alCambiar: alCambiar,
            ),
          );
        }

        final extendida = constraints.maxWidth >= 1120;
        return Scaffold(
          body: Row(
            children: [
              _RailNavegacion(
                destinos: destinos,
                indiceSeleccionado: indiceSeleccionado,
                alCambiar: alCambiar,
                extendida: extendida,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class _RailNavegacion extends StatelessWidget {
  const _RailNavegacion({
    required this.destinos,
    required this.indiceSeleccionado,
    required this.alCambiar,
    required this.extendida,
  });

  final List<NavigationDestination> destinos;
  final int indiceSeleccionado;
  final ValueChanged<int> alCambiar;
  final bool extendida;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: false,
      child: SizedBox(
        width: extendida ? 232 : 88,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, extendida ? 12 : 20),
              child: extendida
                  ? Row(
                      children: [
                        const LogoForno(size: 38, soloIcono: true),
                        const SizedBox(width: 10),
                        Text(
                          'FornoGO',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: TemaFornoGO.rojo,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    )
                  : const LogoForno(size: 38, soloIcono: true),
            ),
            Expanded(
              child: NavigationRail(
                selectedIndex: indiceSeleccionado,
                onDestinationSelected: alCambiar,
                extended: extendida,
                labelType: extendida
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                groupAlignment: -0.75,
                destinations: destinos
                    .map(
                      (destino) => NavigationRailDestination(
                        icon: destino.icon,
                        selectedIcon: destino.selectedIcon,
                        label: Text(destino.label),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
