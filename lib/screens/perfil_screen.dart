import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/tienda.dart';
import '../theme/tema_fornogo.dart';
import '../widgets/logo_forno.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen(
      {super.key, required this.rol, required this.cerrarSesion});

  final String rol;
  final VoidCallback cerrarSesion;

  String _nombre() {
    final tienda = Tienda.instancia;
    final id = tienda.sesion?.usuarioId;
    if (id == null) return 'Usuario FornoGO';
    if (rol == Rol.cliente) {
      for (final cliente in tienda.clientes) {
        if (cliente.id == id) return cliente.nombre;
      }
    } else if (rol == Rol.domiciliario) {
      for (final domiciliario in tienda.domiciliarios) {
        if (domiciliario.id == id) return domiciliario.nombre;
      }
    } else {
      for (final admin in tienda.administradores) {
        if (admin.id == id) return admin.nombre;
      }
    }
    return 'Usuario FornoGO';
  }

  String _correo() {
    final tienda = Tienda.instancia;
    final id = tienda.sesion?.usuarioId;
    if (id == null) return '';
    if (rol == Rol.cliente) {
      for (final cliente in tienda.clientes) {
        if (cliente.id == id) return cliente.correo;
      }
    } else if (rol == Rol.domiciliario) {
      for (final domiciliario in tienda.domiciliarios) {
        if (domiciliario.id == id) return domiciliario.correo;
      }
    } else {
      for (final admin in tienda.administradores) {
        if (admin.id == id) return admin.correo;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(title: const Text('Mi perfil')),
=======
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
        title: const Text('Mi perfil'),
      ),
>>>>>>> 4e4b37b (Mejora del menu y detelles)
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const LogoForno(size: 96),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: TemaFornoGO.rojo.withValues(alpha: .1),
                    child: const Icon(Icons.person,
                        color: TemaFornoGO.rojo, size: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(_nombre(),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(_correo(),
                      style:
                          const TextStyle(color: TemaFornoGO.textoSecundario)),
                  const SizedBox(height: 20),
                  Text('Rol: ${rol[0].toUpperCase()}${rol.substring(1)}',
                      style:
                          const TextStyle(color: TemaFornoGO.textoSecundario)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: cerrarSesion,
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Cerrar sesión'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
