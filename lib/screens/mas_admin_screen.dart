import 'package:flutter/material.dart';

import '../models/sesion.dart';
<<<<<<< HEAD
=======
import '../widgets/logo_forno.dart';
>>>>>>> 4e4b37b (Mejora del menu y detelles)
import 'administrador/categorias_admin_screen.dart';
import 'perfil_screen.dart';

class MasAdminScreen extends StatelessWidget {
  const MasAdminScreen({super.key, required this.cerrarSesion});

  final VoidCallback cerrarSesion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Más opciones')),
=======
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
        title: const Text('Más opciones'),
      ),
>>>>>>> 4e4b37b (Mejora del menu y detelles)
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Categorías'),
              subtitle: const Text('Organiza el catálogo de FornoGO'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CategoriasAdminScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil administrativo'),
              subtitle: const Text('Consulta la cuenta activa'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerfilScreen(
                    rol: Rol.administrador,
                    cerrarSesion: cerrarSesion,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Cerrar sesión'),
              subtitle: const Text('Salir de la cuenta administrativa'),
              onTap: cerrarSesion,
            ),
          ),
        ],
      ),
    );
  }
}
