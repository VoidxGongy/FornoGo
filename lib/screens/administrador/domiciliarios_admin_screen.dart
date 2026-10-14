import 'package:flutter/material.dart';

import '../../models/domiciliario.dart';
import '../../services/tienda.dart';

class DomiciliariosAdminScreen extends StatefulWidget {
  const DomiciliariosAdminScreen({super.key});

  @override
  State<DomiciliariosAdminScreen> createState() =>
      _DomiciliariosAdminScreenState();
}

class _DomiciliariosAdminScreenState extends State<DomiciliariosAdminScreen> {
  Future<void> _formulario([Domiciliario? anterior]) async {
    final resultado = await showDialog<Domiciliario>(
      context: context,
      builder: (_) => _DomiciliarioDialog(domiciliario: anterior),
    );
    if (resultado == null) return;
    final tienda = Tienda.instancia;
    if (anterior == null) {
      tienda.agregarDomiciliario(resultado);
    } else {
      tienda.editarDomiciliario(resultado);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final domiciliarios = Tienda.instancia.domiciliarios;
    return Scaffold(
      appBar: AppBar(title: const Text('Domiciliarios')),
      body: domiciliarios.isEmpty
          ? const Center(child: Text('No hay domiciliarios registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: domiciliarios.length,
              itemBuilder: (_, index) {
                final domiciliario = domiciliarios[index];
                return Card(
                  child: ListTile(
                    leading: Icon(domiciliario.activo
                        ? Icons.delivery_dining
                        : Icons.person_off),
                    title: Text(domiciliario.nombre),
                    subtitle: Text(
                        '${domiciliario.correo}\n${domiciliario.activo ? 'Activo' : 'Inactivo'}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (opcion) {
                        if (opcion == 'editar') _formulario(domiciliario);
                        if (opcion == 'desactivar') {
                          Tienda.instancia
                              .desactivarDomiciliario(domiciliario.id);
                          setState(() {});
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'editar', child: Text('Editar')),
                        if (domiciliario.activo)
                          const PopupMenuItem(
                              value: 'desactivar', child: Text('Desactivar')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'admin-domiciliario-fab',
          onPressed: () => _formulario(),
          child: const Icon(Icons.add)),
    );
  }
}

class _DomiciliarioDialog extends StatefulWidget {
  final Domiciliario? domiciliario;
  const _DomiciliarioDialog({this.domiciliario});

  @override
  State<_DomiciliarioDialog> createState() => _DomiciliarioDialogState();
}

class _DomiciliarioDialogState extends State<_DomiciliarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _correo;
  late final TextEditingController _telefono;
  late final TextEditingController _clave;

  @override
  void initState() {
    super.initState();
    final d = widget.domiciliario;
    _nombre = TextEditingController(text: d?.nombre ?? '');
    _correo = TextEditingController(text: d?.correo ?? '');
    _telefono = TextEditingController(text: d?.telefono ?? '');
    _clave = TextEditingController();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final anterior = widget.domiciliario;
    Navigator.pop(
      context,
      Domiciliario(
        id: anterior?.id ?? 0,
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
        telefono: _telefono.text.trim(),
        hashClave: _clave.text.isEmpty && anterior != null
            ? anterior.hashClave
            : Tienda.hashAcademico(_clave.text),
        activo: anterior?.activo ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.domiciliario == null
          ? 'Nuevo domiciliario'
          : 'Editar domiciliario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: _obligatorio),
              TextFormField(
                  controller: _correo,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Correo inválido' : null),
              TextFormField(
                  controller: _telefono,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: _obligatorio),
              TextFormField(
                  controller: _clave,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: widget.domiciliario == null
                          ? 'Contraseña'
                          : 'Nueva contraseña (opcional)'),
                  validator: (v) =>
                      widget.domiciliario == null && (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }

  String? _obligatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Campo obligatorio' : null;
}
