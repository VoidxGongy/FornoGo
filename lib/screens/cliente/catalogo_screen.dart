import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/tienda.dart';
<<<<<<< HEAD
=======
import '../../theme/tema_fornogo.dart';
>>>>>>> 4e4b37b (Mejora del menu y detelles)
import '../../widgets/imagen_producto.dart';
import '../../widgets/logo_forno.dart';
import '../../utils/formato_moneda.dart';
import '../inicio/login_screen.dart';
import 'producto_detalle_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  int? _categoriaSeleccionada;
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    final categorias = tienda.categoriasActivas();
    final productosBase = _categoriaSeleccionada == null
        ? tienda.productos.where((p) => p.disponible).toList()
        : tienda.productosPorCategoria(_categoriaSeleccionada!);
    final termino = _busqueda.trim().toLowerCase();
    final productos = termino.isEmpty
        ? productosBase
        : productosBase
            .where((p) =>
                p.nombre.toLowerCase().contains(termino) ||
                p.descripcion.toLowerCase().contains(termino) ||
                (tienda
                        .buscarCategoriaPorId(p.categoriaId)
                        ?.nombre
                        .toLowerCase()
                        .contains(termino) ??
                    false))
            .toList();

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
=======
        backgroundColor: TemaFornoGO.rojo,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
>>>>>>> 4e4b37b (Mejora del menu y detelles)
        leading: const Padding(
          padding: EdgeInsets.all(6),
          child: LogoForno(size: 36, soloIcono: true),
        ),
<<<<<<< HEAD
        title: const Text('FornoGO'),
=======
        title: const Text(
          'FornoGO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
>>>>>>> 4e4b37b (Mejora del menu y detelles)
        actions: [
          IconButton(
            tooltip: 'Salir',
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '¿Qué quieres pedir hoy?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                  controller: _busquedaController,
                  onChanged: (valor) => setState(() => _busqueda = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar pizzas, bebidas o postres',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _busqueda = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ))),
          _filtro(categorias),
          Expanded(
            child: productos.isEmpty
                ? const Center(child: Text('No hay productos disponibles.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: productos.length,
                    itemBuilder: (_, index) {
                      final producto = productos[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProductoDetalleScreen(
                                      producto: producto))),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              Hero(
                                  tag: 'producto-${producto.id}',
                                  child: ImagenProducto(
                                      ruta: producto.rutaImagen,
                                      esAsset: producto.esAsset,
                                      nombreProducto: producto.nombre,
                                      width: 104,
                                      height: 104,
                                      borderRadius: 14)),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(producto.nombre,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text(producto.descripcion,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Color(0xFF756767))),
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              formatoPesosColombianos(
                                                  producto.precio),
                                              style: const TextStyle(
                                                  color: Color(0xFFD32F2F),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          IconButton.filled(
                                              style: IconButton.styleFrom(
                                                minimumSize: const Size(40, 40),
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () {
                                                tienda.agregarAlCarrito(
                                                    producto, 1);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            '${producto.nombre} agregado al carrito')));
                                              },
                                              icon: const Icon(
                                                  Icons.add_shopping_cart,
                                                  size: 20),
                                              tooltip: 'Agregar al carrito'),
                                        ]),
                                  ])),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion(BuildContext context) {
    Tienda.instancia.cerrarSesion();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _filtro(List<Categoria> categorias) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          ChoiceChip(
              label: const Text('Todos'),
              selected: _categoriaSeleccionada == null,
              onSelected: (_) => setState(() => _categoriaSeleccionada = null)),
          ...categorias.map((categoria) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(categoria.nombre),
                  selected: _categoriaSeleccionada == categoria.id,
                  onSelected: (_) =>
                      setState(() => _categoriaSeleccionada = categoria.id),
                ),
              )),
        ],
      ),
    );
  }
}
