import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/administrador.dart';
import '../models/categoria.dart';
import '../models/cliente.dart';
import '../models/domiciliario.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../models/producto_carrito.dart';
import '../models/sesion.dart';

///
/// Servicio centralizado de persistencia local con SharedPreferences.
///
/// Flujo al GUARDAR una lista:
///   objeto.toJson()  →  jsonEncode(lista)  →  setString(clave, texto)
///
/// Flujo al CARGAR una lista:
///   getString(clave)  →  jsonDecode(texto)  →  Modelo.fromJson(mapa)
///
/// Limitación académica: los datos quedan en ESTE dispositivo.
/// No se sincronizan entre varios celulares y no son una base de datos.
///
class Preferencias {
  Preferencias._();
  static final Preferencias instancia = Preferencias._();

  // Claves constantes para identificar cada colección guardada.
  static const String claveProductos = 'fornogo_productos';
  static const String claveCategorias = 'fornogo_categorias';
  static const String clavePedidos = 'fornogo_pedidos';
  static const String claveClientes = 'fornogo_clientes';
  static const String claveAdministradores = 'fornogo_administradores';
  static const String claveDomiciliarios = 'fornogo_domiciliarios';
  static const String claveCarrito = 'fornogo_carrito';
  static const String claveSesion = 'fornogo_sesion';
  static const String claveLogoRuta = 'fornogo_logo_ruta';
  static const String claveLogoEsAsset = 'fornogo_logo_es_asset';
  static const String claveInicializado = 'fornogo_inicializado';

  SharedPreferences? _prefs;

  /// Debe llamarse una vez al iniciar la app (ver main.dart).
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferences no está inicializado. Llame a Preferencias.instancia.init() en main().',
      );
    }
    return _prefs!;
  }

  bool yaInicializado() => _p.getBool(claveInicializado) ?? false;

  Future<void> marcarInicializado() async {
    await _p.setBool(claveInicializado, true);
  }

  // ----------------------------------------------------------
  // PRODUCTOS
  // ----------------------------------------------------------
  Future<void> guardarProductos(List<Producto> productos) async {
    // Cada producto se convierte a mapa y la lista se serializa a JSON.
    final texto = jsonEncode(productos.map((p) => p.toJson()).toList());
    await _p.setString(claveProductos, texto);
  }

  List<Producto> cargarProductos() {
    final texto = _p.getString(claveProductos);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Producto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // CATEGORÍAS
  // ----------------------------------------------------------
  Future<void> guardarCategorias(List<Categoria> categorias) async {
    final texto = jsonEncode(categorias.map((c) => c.toJson()).toList());
    await _p.setString(claveCategorias, texto);
  }

  List<Categoria> cargarCategorias() {
    final texto = _p.getString(claveCategorias);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Categoria.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // PEDIDOS
  // ----------------------------------------------------------
  Future<void> guardarPedidos(List<Pedido> pedidos) async {
    final texto = jsonEncode(pedidos.map((p) => p.toJson()).toList());
    await _p.setString(clavePedidos, texto);
  }

  List<Pedido> cargarPedidos() {
    final texto = _p.getString(clavePedidos);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Pedido.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // CLIENTES
  // ----------------------------------------------------------
  Future<void> guardarClientes(List<Cliente> clientes) async {
    final texto = jsonEncode(clientes.map((c) => c.toJson()).toList());
    await _p.setString(claveClientes, texto);
  }

  List<Cliente> cargarClientes() {
    final texto = _p.getString(claveClientes);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Cliente.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // ADMINISTRADORES
  // ----------------------------------------------------------
  Future<void> guardarAdministradores(
      List<Administrador> administradores) async {
    final texto = jsonEncode(administradores.map((a) => a.toJson()).toList());
    await _p.setString(claveAdministradores, texto);
  }

  List<Administrador> cargarAdministradores() {
    final texto = _p.getString(claveAdministradores);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Administrador.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // DOMICILIARIOS
  // ----------------------------------------------------------
  Future<void> guardarDomiciliarios(List<Domiciliario> domiciliarios) async {
    final texto = jsonEncode(domiciliarios.map((d) => d.toJson()).toList());
    await _p.setString(claveDomiciliarios, texto);
  }

  List<Domiciliario> cargarDomiciliarios() {
    final texto = _p.getString(claveDomiciliarios);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Domiciliario.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // CARRITO
  // ----------------------------------------------------------
  Future<void> guardarCarrito(List<ProductoCarrito> carrito) async {
    final texto = jsonEncode(carrito.map((i) => i.toJson()).toList());
    await _p.setString(claveCarrito, texto);
  }

  List<ProductoCarrito> cargarCarrito() {
    final texto = _p.getString(claveCarrito);
    if (texto == null || texto.isEmpty) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => ProductoCarrito.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ----------------------------------------------------------
  // SESIÓN
  // ----------------------------------------------------------
  Future<void> guardarSesion(Sesion? sesion) async {
    if (sesion == null) {
      await _p.remove(claveSesion);
      return;
    }
    await _p.setString(claveSesion, jsonEncode(sesion.toJson()));
  }

  Sesion? cargarSesion() {
    final texto = _p.getString(claveSesion);
    if (texto == null || texto.isEmpty) return null;
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    return Sesion.fromJson(mapa);
  }

  // ----------------------------------------------------------
  // LOGO (solo se guarda la RUTA, no el archivo de imagen)
  // ----------------------------------------------------------
  Future<void> guardarLogo({
    required String ruta,
    required bool esAsset,
  }) async {
    await _p.setString(claveLogoRuta, ruta);
    await _p.setBool(claveLogoEsAsset, esAsset);
  }

  String cargarLogoRuta() {
    return _p.getString(claveLogoRuta) ?? 'assets/images/logo.png';
  }

  bool cargarLogoEsAsset() {
    return _p.getBool(claveLogoEsAsset) ?? true;
  }
}
