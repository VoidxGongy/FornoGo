import 'dart:async';
import 'dart:convert';

import '../models/administrador.dart';
import '../models/categoria.dart';
import '../models/cliente.dart';
import '../models/domiciliario.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../models/producto_carrito.dart';
import '../models/sesion.dart';
import 'preferencias.dart';

/// Costo fijo de domicilio usado en el prototipo.
const double kCostoDomicilio = 5000;

///
/// Tienda: punto único donde viven las LISTAS de Dart de FornoGO.
///
/// Las listas viven en memoria y se persisten con Preferencias
/// (SharedPreferences + jsonEncode / jsonDecode).
///
class Tienda {
  Tienda._();
  static final Tienda instancia = Tienda._();

  // ----------------------------------------------------------
  // LISTAS PRINCIPALES (aquí se declara cada colección)
  // ----------------------------------------------------------
  List<Producto> productos = [];
  List<Categoria> categorias = [];
  List<Pedido> pedidos = [];
  List<Domiciliario> domiciliarios = [];
  List<Cliente> clientes = [];
  List<Administrador> administradores = [];
  List<ProductoCarrito> carrito = [];

  Sesion? sesion;
  String rutaLogo = 'assets/images/logo.png';
  bool logoEsAsset = true;

  int _siguienteProducto = 1;
  int _siguienteCategoria = 1;
  int _siguientePedido = 1;
  int _siguienteDomiciliario = 1;
  int _siguienteCliente = 1;
  int _siguienteAdministrador = 1;

  /// Aviso académico: esto NO es autenticación segura de producción.
  /// Solo evita guardar la clave exactamente como la escribió el usuario.
  static String hashAcademico(String clave) {
    return base64Encode(utf8.encode('fornogo|$clave'));
  }

  void _actualizarContadores() {
    _siguienteProducto = _maxId(productos.map((p) => p.id)) + 1;
    _siguienteCategoria = _maxId(categorias.map((c) => c.id)) + 1;
    _siguientePedido = _maxId(pedidos.map((p) => p.id)) + 1;
    _siguienteDomiciliario = _maxId(domiciliarios.map((d) => d.id)) + 1;
    _siguienteCliente = _maxId(clientes.map((c) => c.id)) + 1;
    _siguienteAdministrador = _maxId(administradores.map((a) => a.id)) + 1;
  }

  int _maxId(Iterable<int> ids) {
    var maximo = 0;
    for (final id in ids) {
      if (id > maximo) maximo = id;
    }
    return maximo;
  }

  /// Recupera las listas desde SharedPreferences.
  /// Si es la primera ejecución, carga la semilla y la guarda.
  Future<void> cargarPersistencia() async {
    final prefs = Preferencias.instancia;
    productos = prefs.cargarProductos();
    categorias = prefs.cargarCategorias();
    pedidos = prefs.cargarPedidos();
    clientes = prefs.cargarClientes();
    administradores = prefs.cargarAdministradores();
    domiciliarios = prefs.cargarDomiciliarios();
    carrito = prefs.cargarCarrito();
    sesion = prefs.cargarSesion();
    rutaLogo = prefs.cargarLogoRuta();
    logoEsAsset = prefs.cargarLogoEsAsset();

    if (!prefs.yaInicializado()) {
      cargarSemillaSiVacia();
      await guardarCambios();
      await prefs.marcarInicializado();
    } else {
      _actualizarContadores();
    }
  }

  /// Guarda TODAS las listas actuales. Usar después de agregar, editar o eliminar.
  Future<void> guardarCambios() async {
    final prefs = Preferencias.instancia;
    await prefs.guardarProductos(productos);
    await prefs.guardarCategorias(categorias);
    await prefs.guardarPedidos(pedidos);
    await prefs.guardarClientes(clientes);
    await prefs.guardarAdministradores(administradores);
    await prefs.guardarDomiciliarios(domiciliarios);
    await prefs.guardarCarrito(carrito);
    await prefs.guardarSesion(sesion);
    await prefs.guardarLogo(ruta: rutaLogo, esAsset: logoEsAsset);
  }

  /// No espera el guardado para no volver asíncronos todos los métodos CRUD.
  void _persistir() {
    unawaited(guardarCambios());
  }

  // ----------------------------------------------------------
  // SEMILLA DE DEMOSTRACIÓN (llena las listas la primera vez)
  // ----------------------------------------------------------
  void cargarSemillaSiVacia() {
    if (categorias.isNotEmpty || productos.isNotEmpty) {
      _actualizarContadores();
      return;
    }

    // AGREGAR categorías iniciales a la lista.
    categorias.addAll([
      Categoria(id: _siguienteCategoria++, nombre: 'Pizzas'),
      Categoria(id: _siguienteCategoria++, nombre: 'Bebidas'),
      Categoria(id: _siguienteCategoria++, nombre: 'Postres'),
    ]);

    // AGREGAR productos de ejemplo (las fotos reales se declaran en la Etapa 4).
    productos.addAll([
      Producto(
        id: _siguienteProducto++,
        nombre: 'Pizza Margarita',
        descripcion: 'Tomate, mozzarella, albahaca',
        precio: 28000,
        categoriaId: 1,
        rutaImagen: 'assets/images/pizza_margarita.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Pizza Pepperoni',
        descripcion: 'Salsa de tomate, pepperoni, queso',
        precio: 32000,
        categoriaId: 1,
        rutaImagen: 'assets/images/pizza_pepperoni.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Pizza Hawaiana',
        descripcion: 'Jamón, piña y mozzarella',
        precio: 30000,
        categoriaId: 1,
        rutaImagen: 'assets/images/pizza_hawaiana.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Pizza Cuatro Quesos',
        descripcion: 'Mozzarella, cheddar, gouda, parmesano',
        precio: 35000,
        categoriaId: 1,
        rutaImagen: 'assets/images/pizza_cuatro_quesos.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Gaseosa 350ml',
        descripcion: 'Coca-Cola, Pepsi o Sprite',
        precio: 4000,
        categoriaId: 2,
        rutaImagen: 'assets/images/gaseosa.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Agua Mineral 500ml',
        descripcion: 'Con o sin gas',
        precio: 3000,
        categoriaId: 2,
        rutaImagen: 'assets/images/agua.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Brownie de Chocolate',
        descripcion: 'Con helado de vainilla',
        precio: 12000,
        categoriaId: 3,
        rutaImagen: 'assets/images/brownie.png',
      ),
      Producto(
        id: _siguienteProducto++,
        nombre: 'Tiramisú',
        descripcion: 'Postre italiano con mascarpone',
        precio: 14000,
        categoriaId: 3,
        rutaImagen: 'assets/images/tiramisu.png',
      ),
    ]);

    administradores.add(
      Administrador(
        id: _siguienteAdministrador++,
        nombre: 'Administrador FornoGO',
        correo: 'admin@fornogo.com',
        hashClave: hashAcademico('admin123'),
      ),
    );

    // Domiciliarios de la semilla (el admin puede desactivarlos después).
    domiciliarios.addAll([
      Domiciliario(
        id: _siguienteDomiciliario++,
        nombre: 'Juan Pérez',
        correo: 'juan@fornogo.com',
        telefono: '3101112233',
        hashClave: hashAcademico('domi123'),
      ),
      Domiciliario(
        id: _siguienteDomiciliario++,
        nombre: 'Luis Morales',
        correo: 'luis@fornogo.com',
        telefono: '3102223344',
        hashClave: hashAcademico('domi123'),
      ),
      Domiciliario(
        id: _siguienteDomiciliario++,
        nombre: 'Diana Ramírez',
        correo: 'diana@fornogo.com',
        telefono: '3103334455',
        hashClave: hashAcademico('domi123'),
      ),
      Domiciliario(
        id: _siguienteDomiciliario++,
        nombre: 'Camilo Ortega',
        correo: 'camilo@fornogo.com',
        telefono: '3104445566',
        hashClave: hashAcademico('domi123'),
      ),
    ]);

    clientes.add(
      Cliente(
        id: _siguienteCliente++,
        nombre: 'María García',
        correo: 'maria@correo.com',
        telefono: '3104567890',
        hashClave: hashAcademico('cliente123'),
        direccionPredeterminada: 'Cra 15 #45-30, Apto 302',
      ),
    );
  }

  // ----------------------------------------------------------
  // CATEGORÍAS
  // ----------------------------------------------------------
  Categoria? buscarCategoriaPorId(int id) {
    for (final categoria in categorias) {
      if (categoria.id == id) return categoria;
    }
    return null;
  }

  void agregarCategoria(Categoria categoria) {
    categoria.id = _siguienteCategoria++;
    categorias.add(categoria);
    _persistir();
  }

  bool editarCategoria(Categoria actualizada) {
    for (var i = 0; i < categorias.length; i++) {
      if (categorias[i].id == actualizada.id) {
        categorias[i] = actualizada;
        _persistir();
        return true;
      }
    }
    return false;
  }

  bool eliminarCategoria(int id) {
    // No se elimina si todavía hay productos que la usan.
    for (final producto in productos) {
      if (producto.categoriaId == id) return false;
    }
    final antes = categorias.length;
    categorias.removeWhere((categoria) => categoria.id == id);
    final eliminada = categorias.length < antes;
    if (eliminada) _persistir();
    return eliminada;
  }

  List<Categoria> categoriasActivas() {
    final resultado = <Categoria>[];
    for (final categoria in categorias) {
      if (categoria.activa) resultado.add(categoria);
    }
    return resultado;
  }

  // ----------------------------------------------------------
  // PRODUCTOS
  // ----------------------------------------------------------
  Producto? buscarProductoPorId(int id) {
    for (final producto in productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }

  void agregarProducto(Producto producto) {
    producto.id = _siguienteProducto++;
    productos.add(producto);
    _persistir();
  }

  bool editarProducto(Producto actualizado) {
    for (var i = 0; i < productos.length; i++) {
      if (productos[i].id == actualizado.id) {
        productos[i] = actualizado;
        _persistir();
        return true;
      }
    }
    return false;
  }

  bool eliminarProducto(int id) {
    final antes = productos.length;
    productos.removeWhere((producto) => producto.id == id);
    final eliminado = productos.length < antes;
    if (eliminado) _persistir();
    return eliminado;
  }

  List<Producto> productosPorCategoria(int categoriaId) {
    final resultado = <Producto>[];
    for (final producto in productos) {
      if (producto.categoriaId == categoriaId && producto.disponible) {
        resultado.add(producto);
      }
    }
    return resultado;
  }

  // ----------------------------------------------------------
  // CLIENTES
  // ----------------------------------------------------------
  Cliente? buscarClientePorId(int id) {
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  Cliente? buscarClientePorCorreo(String correo) {
    final buscado = correo.trim().toLowerCase();
    for (final cliente in clientes) {
      if (cliente.correo.toLowerCase() == buscado) return cliente;
    }
    return null;
  }

  void agregarCliente(Cliente cliente) {
    cliente.id = _siguienteCliente++;
    clientes.add(cliente);
    _persistir();
  }

  bool editarCliente(Cliente actualizado) {
    for (var i = 0; i < clientes.length; i++) {
      if (clientes[i].id == actualizado.id) {
        clientes[i] = actualizado;
        _persistir();
        return true;
      }
    }
    return false;
  }

  // ----------------------------------------------------------
  // ADMINISTRADORES Y DOMICILIARIOS
  // ----------------------------------------------------------
  Administrador? buscarAdministradorPorCorreo(String correo) {
    final buscado = correo.trim().toLowerCase();
    for (final admin in administradores) {
      if (admin.correo.toLowerCase() == buscado) return admin;
    }
    return null;
  }

  Domiciliario? buscarDomiciliarioPorId(int id) {
    for (final domiciliario in domiciliarios) {
      if (domiciliario.id == id) return domiciliario;
    }
    return null;
  }

  Domiciliario? buscarDomiciliarioPorCorreo(String correo) {
    final buscado = correo.trim().toLowerCase();
    for (final domiciliario in domiciliarios) {
      if (domiciliario.correo.toLowerCase() == buscado) return domiciliario;
    }
    return null;
  }

  void agregarDomiciliario(Domiciliario domiciliario) {
    domiciliario.id = _siguienteDomiciliario++;
    domiciliarios.add(domiciliario);
    _persistir();
  }

  bool editarDomiciliario(Domiciliario actualizado) {
    for (var i = 0; i < domiciliarios.length; i++) {
      if (domiciliarios[i].id == actualizado.id) {
        domiciliarios[i] = actualizado;
        _persistir();
        return true;
      }
    }
    return false;
  }

  bool desactivarDomiciliario(int id) {
    final domiciliario = buscarDomiciliarioPorId(id);
    if (domiciliario == null) return false;
    domiciliario.activo = false;
    _persistir();
    return true;
  }

  List<Domiciliario> domiciliariosActivos() {
    final resultado = <Domiciliario>[];
    for (final domiciliario in domiciliarios) {
      if (domiciliario.activo) resultado.add(domiciliario);
    }
    return resultado;
  }

  // ----------------------------------------------------------
  // CARRITO (List<ProductoCarrito>)
  // ----------------------------------------------------------
  void agregarAlCarrito(Producto producto, int cantidad) {
    if (cantidad < 1) return;
    for (final item in carrito) {
      if (item.productoId == producto.id) {
        item.cantidad += cantidad;
        _persistir();
        return;
      }
    }
    carrito.add(
      ProductoCarrito(
        productoId: producto.id,
        nombre: producto.nombre,
        precioUnitario: producto.precio,
        cantidad: cantidad,
        rutaImagen: producto.rutaImagen,
        esAsset: producto.esAsset,
      ),
    );
    _persistir();
  }

  void cambiarCantidadCarrito(int productoId, int cantidad) {
    if (cantidad < 1) {
      eliminarDelCarrito(productoId);
      return;
    }
    for (final item in carrito) {
      if (item.productoId == productoId) {
        item.cantidad = cantidad;
        _persistir();
        return;
      }
    }
  }

  void eliminarDelCarrito(int productoId) {
    carrito.removeWhere((item) => item.productoId == productoId);
    _persistir();
  }

  void vaciarCarrito() {
    carrito.clear();
    _persistir();
  }

  double subtotalCarrito() {
    var total = 0.0;
    for (final item in carrito) {
      total += item.subtotal;
    }
    return total;
  }

  double totalCarrito() => subtotalCarrito() + kCostoDomicilio;

  // ----------------------------------------------------------
  // PEDIDOS
  // ----------------------------------------------------------
  Pedido? buscarPedidoPorId(int id) {
    for (final pedido in pedidos) {
      if (pedido.id == id) return pedido;
    }
    return null;
  }

  Pedido confirmarPedido({
    required Cliente cliente,
    required String direccion,
    String referencias = '',
    required String metodoPago,
  }) {
    final items = <ItemPedido>[];
    for (final item in carrito) {
      items.add(
        ItemPedido(
          productoId: item.productoId,
          nombre: item.nombre,
          precioUnitario: item.precioUnitario,
          cantidad: item.cantidad,
        ),
      );
    }

    final pedido = Pedido(
      id: _siguientePedido++,
      clienteId: cliente.id,
      nombreCliente: cliente.nombre,
      telefono: cliente.telefono,
      direccion: direccion,
      referencias: referencias,
      items: items,
      subtotal: subtotalCarrito(),
      domicilio: kCostoDomicilio,
      total: totalCarrito(),
      metodoPago: metodoPago,
      fecha: DateTime.now(),
    );

    pedidos.add(pedido);
    vaciarCarrito();
    return pedido;
  }

  bool actualizarEstadoPedido(int id, String nuevoEstado) {
    final pedido = buscarPedidoPorId(id);
    if (pedido == null) return false;
    pedido.estado = nuevoEstado;
    _persistir();
    return true;
  }

  bool asignarDomiciliario(int pedidoId, int domiciliarioId) {
    final pedido = buscarPedidoPorId(pedidoId);
    final domiciliario = buscarDomiciliarioPorId(domiciliarioId);
    if (pedido == null || domiciliario == null || !domiciliario.activo) {
      return false;
    }
    pedido.domiciliarioId = domiciliarioId;
    if (pedido.estado == EstadoPedido.listo ||
        pedido.estado == EstadoPedido.enPreparacion ||
        pedido.estado == EstadoPedido.aceptado) {
      pedido.estado = EstadoPedido.listo;
    }
    _persistir();
    return true;
  }

  bool confirmarEntrega({
    required int pedidoId,
    required String metodoPago,
    double? montoRecibido,
  }) {
    final pedido = buscarPedidoPorId(pedidoId);
    if (pedido == null) return false;
    pedido.metodoPago = metodoPago;
    pedido.montoRecibido = montoRecibido;
    pedido.estado = EstadoPedido.entregado;
    _persistir();
    return true;
  }

  List<Pedido> pedidosDeCliente(int clienteId) {
    final resultado = <Pedido>[];
    for (final pedido in pedidos) {
      if (pedido.clienteId == clienteId) resultado.add(pedido);
    }
    return resultado;
  }

  List<Pedido> pedidosAsignadosA(int domiciliarioId) {
    final resultado = <Pedido>[];
    for (final pedido in pedidos) {
      if (pedido.domiciliarioId == domiciliarioId &&
          pedido.estado != EstadoPedido.entregado &&
          pedido.estado != EstadoPedido.rechazado) {
        resultado.add(pedido);
      }
    }
    return resultado;
  }

  List<Pedido> pedidosPorEstado(String estado) {
    if (estado == 'Todos') return List<Pedido>.from(pedidos);
    final resultado = <Pedido>[];
    for (final pedido in pedidos) {
      if (pedido.estado == estado) resultado.add(pedido);
    }
    return resultado;
  }

  // ----------------------------------------------------------
  // SESIÓN
  // ----------------------------------------------------------
  bool iniciarSesion(String correo, String clave) {
    final hash = hashAcademico(clave);

    final admin = buscarAdministradorPorCorreo(correo);
    if (admin != null && admin.hashClave == hash) {
      sesion = Sesion(rol: Rol.administrador, usuarioId: admin.id);
      _persistir();
      return true;
    }

    final domiciliario = buscarDomiciliarioPorCorreo(correo);
    if (domiciliario != null &&
        domiciliario.activo &&
        domiciliario.hashClave == hash) {
      sesion = Sesion(rol: Rol.domiciliario, usuarioId: domiciliario.id);
      _persistir();
      return true;
    }

    final cliente = buscarClientePorCorreo(correo);
    if (cliente != null && cliente.hashClave == hash) {
      sesion = Sesion(rol: Rol.cliente, usuarioId: cliente.id);
      _persistir();
      return true;
    }

    return false;
  }

  void cerrarSesion() {
    sesion = null;
    vaciarCarrito();
  }
}
