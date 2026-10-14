# Documentación de la rúbrica — FornoGO

FornoGO es una aplicación móvil Flutter/Dart para una pizzería. El alcance es local y académico: no utiliza Firebase, backend, base de datos externa, mapas, GPS ni servicios remotos de productos.

En Dart se utilizó `List<T>`, que cumple la función de una colección dinámica equivalente al `ArrayList` utilizado en otros lenguajes como Java.

## Alcance móvil

La aplicación se demuestra en Android mediante Flutter. Las carpetas web, Linux, macOS y Windows pertenecen a la plantilla multiplataforma generada por Flutter, pero no forman parte del alcance funcional de FornoGO.

## Uso de List

Las listas principales están centralizadas en `lib/services/tienda.dart`:

| Lista | Tipo | Archivo | Clase | Operaciones | Pantallas |
|---|---|---|---|---|---|
| productos | `List<Producto>` | `lib/services/tienda.dart` | `Tienda` | agregar, buscar, editar, eliminar, filtrar | Catálogo, detalle, administración |
| categorias | `List<Categoria>` | `lib/services/tienda.dart` | `Tienda` | agregar, buscar, editar, eliminar, filtrar activas | Catálogo, administración |
| pedidos | `List<Pedido>` | `lib/services/tienda.dart` | `Tienda` | crear, buscar, filtrar, asignar, actualizar estado | Cliente, administrador, domiciliario |
| domiciliarios | `List<Domiciliario>` | `lib/services/tienda.dart` | `Tienda` | registrar, buscar, editar, desactivar, filtrar activos | Administración, entregas |
| clientes | `List<Cliente>` | `lib/services/tienda.dart` | `Tienda` | registrar, buscar, editar | Registro, login, pedidos |
| administradores | `List<Administrador>` | `lib/services/tienda.dart` | `Tienda` | buscar por correo | Login |
| carrito | `List<ProductoCarrito>` | `lib/services/tienda.dart` | `Tienda` | agregar, aumentar, disminuir, eliminar, vaciar, calcular | Catálogo, carrito, confirmación |

### Operaciones demostrables

- `add` y `addAll`: semillas, productos, categorías, clientes, domiciliarios, carrito y pedidos.
- `map`: serialización de listas y conversión de productos/pedidos para las interfaces.
- `where`: productos disponibles, pedidos por cliente y productos por categoría.
- `indexWhere`: reemplazo de productos y categorías en edición.
- `removeWhere`: eliminación de productos, categorías y elementos del carrito.
- `fold`: no se utiliza actualmente; los totales se calculan recorriendo la lista con `for` para mantener el código introductorio.
- `sort`: no se utiliza actualmente; el historial invierte la lista de pedidos con `reversed`.
- `ListView.builder`: catálogo, carrito, historial, productos, pedidos y domiciliarios.

No existe una lista separada llamada `historialPedidos`; el historial se obtiene filtrando `pedidos` por `clienteId` mediante `pedidosDeCliente()`.

## SharedPreferences

El servicio centralizado es `lib/services/preferencias.dart`, utilizado por `lib/services/tienda.dart`.

| Información | Clave real | Guardar | Cargar | Archivo | Uso |
|---|---|---|---|---|---|
| Productos | `fornogo_productos` | `guardarProductos` | `cargarProductos` | `preferencias.dart` | Catálogo y CRUD |
| Categorías | `fornogo_categorias` | `guardarCategorias` | `cargarCategorias` | `preferencias.dart` | Menú y CRUD |
| Pedidos | `fornogo_pedidos` | `guardarPedidos` | `cargarPedidos` | `preferencias.dart` | Flujo completo |
| Clientes | `fornogo_clientes` | `guardarClientes` | `cargarClientes` | `preferencias.dart` | Registro y login |
| Administradores | `fornogo_administradores` | `guardarAdministradores` | `cargarAdministradores` | `preferencias.dart` | Login |
| Domiciliarios | `fornogo_domiciliarios` | `guardarDomiciliarios` | `cargarDomiciliarios` | `preferencias.dart` | Administración y entregas |
| Carrito | `fornogo_carrito` | `guardarCarrito` | `cargarCarrito` | `preferencias.dart` | Carrito persistente |
| Sesión | `fornogo_sesion` | `guardarSesion` | `cargarSesion` | `preferencias.dart` | Usuario actual |
| Logo | `fornogo_logo_ruta` | `guardarLogo` | `cargarLogoRuta` | `preferencias.dart` | Logo local |
| Inicialización | `fornogo_inicializado` | `marcarInicializado` | `yaInicializado` | `preferencias.dart` | Evitar sobrescribir datos |

### Flujo JSON

Para guardar una colección:

1. Cada modelo ejecuta `toJson()`.
2. La lista se transforma con `map(...).toList()`.
3. `jsonEncode()` genera una cadena JSON.
4. `SharedPreferences.setString()` guarda la cadena.

Para recuperar una colección:

1. `getString()` obtiene la cadena.
2. `jsonDecode()` la convierte a una lista de mapas.
3. `fromJson()` reconstruye cada modelo.
4. `Tienda.cargarPersistencia()` coloca los modelos en las listas de memoria.

La inicialización empieza en `lib/main.dart` con `WidgetsFlutterBinding.ensureInitialized()` y continúa en `lib/screens/inicio/splash_screen.dart`. Los datos iniciales solo se crean cuando `fornogo_inicializado` todavía no existe.

## CRUD implementado

| Entidad | Crear | Consultar | Editar | Eliminar o desactivar | Persistencia |
|---|---|---|---|---|---|
| Clientes | Sí, registro público | Sí | Sí, método disponible | No se elimina desde la interfaz | Sí |
| Domiciliarios | Sí | Sí | Sí | Sí, desactivar | Sí |
| Productos | Sí | Sí | Sí | Sí; se recomienda desactivar si tiene pedidos históricos | Sí |
| Categorías | Sí | Sí | Sí | Sí, si no tiene productos asociados | Sí |
| Pedidos | Sí, cliente | Sí | Sí, estado/asignación | No se elimina; conserva historial | Sí |
| Carrito | Sí | Sí | Sí, cantidades | Sí, eliminar/vaciar | Sí |

Cada operación de `Tienda` actualiza la lista y llama a `_persistir()`, que guarda todas las colecciones mediante `guardarCambios()`.

## Flujo integrado

1. El cliente inicia sesión desde `login_screen.dart`.
2. Consulta `CatalogoScreen` y abre `ProductoDetalleScreen`.
3. Agrega elementos a `List<ProductoCarrito>`.
4. Confirma dirección y método de pago en `ConfirmarPedidoScreen`.
5. `Tienda.confirmarPedido()` crea un `Pedido`, lo agrega a `List<Pedido>` y vacía el carrito.
6. El administrador consulta el pedido en `PedidosAdminScreen`.
7. Selecciona un domiciliario activo y cambia el estado.
8. El domiciliario consulta el pedido en `EntregasScreen`.
9. Actualiza el método de pago y confirma la entrega.
10. El cliente consulta el cambio en `PedidosClienteScreen`.
11. Al reiniciar, las listas se reconstruyen desde `SharedPreferences`.

## Pantallas funcionales

- Splash: `lib/screens/inicio/splash_screen.dart`.
- Login: `lib/screens/inicio/login_screen.dart`.
- Registro: `lib/screens/inicio/registro_cliente_screen.dart`.
- Menú por rol: `lib/screens/rol_home_screen.dart`.
- Catálogo: `lib/screens/cliente/catalogo_screen.dart`.
- Detalle de producto: `lib/screens/cliente/producto_detalle_screen.dart`.
- Carrito: `lib/screens/cliente/carrito_screen.dart`.
- Confirmación: `lib/screens/cliente/confirmar_pedido_screen.dart`.
- Historial: `lib/screens/cliente/pedidos_cliente_screen.dart`.
- Productos: `lib/screens/administrador/productos_admin_screen.dart`.
- Categorías: `lib/screens/administrador/categorias_admin_screen.dart`.
- Pedidos administrativos: `lib/screens/administrador/pedidos_admin_screen.dart`.
- Domiciliarios: `lib/screens/administrador/domiciliarios_admin_screen.dart`.
- Entregas: `lib/screens/domiciliario/entregas_screen.dart`.

El prototipo anterior de cursos y estudiantes se conserva en `lib/models/curso.dart` y sus pantallas, pero no está conectado a `main.dart` ni a la navegación de FornoGO.

## Imágenes y tema

Los recursos se declaran en `pubspec.yaml` con `assets/images/`. Los productos iniciales usan las imágenes locales existentes y `ImagenProducto` utiliza `Image.asset` con `placeholder.png` como reemplazo. La pantalla administrativa permite seleccionar una ruta de imagen local y muestra su vista previa. No se utiliza `Image.network`.

Los colores se centralizan en `lib/theme/tema_fornogo.dart`: rojo `#D32F2F`, naranja `#F57C00`, amarillo `#FFC107`, texto `#333333` y verde `#2E7D32`.

## Credenciales académicas

- Administrador: `admin@fornogo.com` / `admin123`.
- Domiciliario: `juan@fornogo.com` / `domi123`.
- Cliente: `maria@gmail.com` / `cliente123`.

Las credenciales se guardan localmente con un hash académico ilustrativo. Esto no reemplaza una autenticación segura de producción.

## Limitaciones

- Los datos solo permanecen en el dispositivo actual.
- No existe sincronización entre teléfonos.
- El pago es simulado; no se cobra en línea.
- WhatsApp se abre mediante `url_launcher` para el número `3118965528`.
- La selección se realiza entre los PNG incluidos en `assets/images/`; no se usa galería ni almacenamiento externo.

## Verificación

La revisión estática de `lib/` no reporta errores. `flutter analyze` no pudo ejecutarse en el entorno de desarrollo porque el SDK instalado en `/usr/share/flutter` requiere escribir en una ubicación de solo lectura. No se afirma que `flutter test` haya sido ejecutado.
