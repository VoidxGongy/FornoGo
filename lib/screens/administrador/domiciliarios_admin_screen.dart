import 'package:flutter/material.dart';

import '../../models/usuario.dart';
import '../../services/tienda.dart';
import '../../utils/ejecutar_operacion.dart';

class DomiciliariosAdminScreen extends StatelessWidget {
  const DomiciliariosAdminScreen({super.key});

  Future<void> _formulario(BuildContext context, [Usuario? usuario]) async {
    final nombre = TextEditingController(text: usuario?.nombre);
    final correo = TextEditingController(text: usuario?.correo);
    final telefono = TextEditingController(text: usuario?.telefono);
    final clave = TextEditingController();
    final formulario = GlobalKey<FormState>();
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => _FormularioDomiciliario(
          usuario: usuario,
          nombre: nombre,
          correo: correo,
          telefono: telefono,
          clave: clave,
          formulario: formulario,
        ),
      );
    } finally {
      nombre.dispose();
      correo.dispose();
      telefono.dispose();
      clave.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    return Scaffold(
      appBar: AppBar(title: const Text('Domiciliarios')),
      body: ListenableBuilder(
        listenable: tienda,
        builder: (context, _) => ListView(
          children: [
            for (final usuario in tienda.domiciliarios)
              ListTile(
                title: Text(usuario.nombre),
                subtitle: Text(
                    '${usuario.correo} · ${usuario.activo ? 'Activo' : 'Inactivo'}'),
                onTap: () => _formulario(context, usuario),
                trailing: usuario.activo
                    ? IconButton(
                        icon: const Icon(Icons.person_off_outlined),
                        tooltip: 'Desactivar',
                        onPressed: () => ejecutarOperacion(context,
                            () => tienda.desactivarDomiciliario(usuario.uid)),
                      )
                    : null,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formulario(context),
        tooltip: 'Crear domiciliario',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FormularioDomiciliario extends StatefulWidget {
  const _FormularioDomiciliario({
    required this.usuario,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.clave,
    required this.formulario,
  });

  final Usuario? usuario;
  final TextEditingController nombre, correo, telefono, clave;
  final GlobalKey<FormState> formulario;

  @override
  State<_FormularioDomiciliario> createState() =>
      _FormularioDomiciliarioState();
}

class _FormularioDomiciliarioState extends State<_FormularioDomiciliario> {
  bool _guardando = false;

  Future<void> _guardar() async {
    if (!widget.formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    final tienda = Tienda.instancia;
    final usuario = widget.usuario;
    final nombre = widget.nombre.text.trim();
    final telefono = widget.telefono.text.trim();
    final listo = await ejecutarOperacion(
        context,
        () => usuario == null
            ? tienda.agregarDomiciliario(
                nombre: nombre,
                correo: widget.correo.text.trim(),
                clave: widget.clave.text,
                telefono: telefono)
            : tienda.editarDomiciliario(usuario.uid, nombre, telefono));
    if (!mounted) return;
    setState(() => _guardando = false);
    if (listo) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String? requerido(String? texto) =>
        texto == null || texto.trim().isEmpty ? 'Campo obligatorio' : null;
    return AlertDialog(
      title: Text(widget.usuario == null
          ? 'Nuevo domiciliario'
          : 'Editar domiciliario'),
      content: Form(
        key: widget.formulario,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
                controller: widget.nombre,
                validator: requerido,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextFormField(
                controller: widget.telefono,
                validator: requerido,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono')),
            if (widget.usuario == null) ...[
              TextFormField(
                  controller: widget.correo,
                  keyboardType: TextInputType.emailAddress,
                  validator: requerido,
                  decoration: const InputDecoration(labelText: 'Correo')),
              TextFormField(
                  controller: widget.clave,
                  obscureText: true,
                  validator: (texto) => (texto?.length ?? 0) < 6
                      ? 'Usa al menos 6 caracteres'
                      : null,
                  decoration: const InputDecoration(labelText: 'Contraseña')),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _guardando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: const Text('Guardar')),
      ],
    );
  }
}
