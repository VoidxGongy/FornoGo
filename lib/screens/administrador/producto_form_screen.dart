import 'package:flutter/material.dart';

import '../../data/imagenes_productos.dart';
import '../../models/producto.dart';
import '../../services/tienda.dart';
import '../../widgets/imagen_producto.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  int? _categoriaId;
  bool _disponible = true;
  late String _rutaImagen;

  @override
  void initState() {
    super.initState();
    final producto = widget.producto;
    _nombre = TextEditingController(text: producto?.nombre ?? '');
    _descripcion = TextEditingController(text: producto?.descripcion ?? '');
    _precio = TextEditingController(
        text: producto == null ? '' : producto.precio.toStringAsFixed(0));
    _categoriaId = producto?.categoriaId ??
        (Tienda.instancia.categoriasActivas().isEmpty
            ? null
            : Tienda.instancia.categoriasActivas().first.id);
    _disponible = producto?.disponible ?? true;
    _rutaImagen = producto?.rutaImagen.isNotEmpty == true
        ? producto!.rutaImagen
        : ImagenesProductos.placeholder;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate() || _categoriaId == null) return;
    final anterior = widget.producto;
    final producto = Producto(
      id: anterior?.id ?? 0,
      nombre: _nombre.text.trim(),
      descripcion: _descripcion.text.trim(),
      precio: double.parse(_precio.text.replaceAll(',', '.')),
      categoriaId: _categoriaId!,
      rutaImagen: _rutaImagen,
      esAsset: true,
      disponible: _disponible,
    );
    if (anterior == null) {
      Tienda.instancia.agregarProducto(producto);
    } else {
      Tienda.instancia.editarProducto(producto);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = Tienda.instancia.categoriasActivas();
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.producto == null ? 'Nuevo producto' : 'Editar producto')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Center(
              child: ImagenProducto(
                  ruta: _rutaImagen,
                  esAsset: true,
                  nombreProducto:
                      _nombre.text.isEmpty ? 'Vista previa' : _nombre.text,
                  width: 150,
                  height: 150,
                  borderRadius: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
              initialValue: ImagenesProductos.opciones
                      .any((opcion) => opcion['ruta'] == _rutaImagen)
                  ? _rutaImagen
                  : null,
              decoration:
                  const InputDecoration(labelText: 'Fotografía del producto'),
              items: ImagenesProductos.opciones
                  .map((opcion) => DropdownMenuItem(
                      value: opcion['ruta'], child: Text(opcion['nombre']!)))
                  .toList(),
              onChanged: (ruta) {
                if (ruta != null) setState(() => _rutaImagen = ruta);
              },
              validator: (v) => v == null ? 'Selecciona una imagen' : null),
          TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'El nombre es obligatorio'
                  : null),
          TextFormField(
              controller: _descripcion,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'La descripción es obligatoria'
                  : null),
          TextFormField(
              controller: _precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
              validator: (v) {
                final precio = double.tryParse((v ?? '').replaceAll(',', '.'));
                return precio == null || precio <= 0
                    ? 'Ingresa un precio mayor que cero'
                    : null;
              }),
          DropdownButtonFormField<int>(
              initialValue: _categoriaId,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categorias
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                  .toList(),
              onChanged: (v) => setState(() => _categoriaId = v),
              validator: (v) => v == null ? 'Selecciona una categoría' : null),
          SwitchListTile(
              title: const Text('Producto disponible'),
              value: _disponible,
              onChanged: (v) => setState(() => _disponible = v)),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: _guardar, child: const Text('Guardar producto')),
        ]),
      ),
    );
  }
}
