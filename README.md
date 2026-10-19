# FornoGO

Aplicación móvil Flutter para administrar el catálogo, clientes, pedidos y domicilios de una pizzería. El proyecto funciona de forma local y académica, sin Firebase, backend ni base de datos externa.

## Ejecución

```bash
flutter pub get
flutter run
```

La información se conserva en el dispositivo mediante `SharedPreferences`.

## Funcionalidades

- Cliente: registro, inicio de sesión, catálogo, filtros, carrito, confirmación de pedido e historial.
- Administrador: gestión de productos, categorías, pedidos, estados y domiciliarios.
- Domiciliario: consulta de entregas asignadas y confirmación de entregas.
- Fotografías: el administrador adjunta la imagen del producto desde el dispositivo al crear o editar un producto.
- Comprobantes: el botón de WhatsApp abre el número `+57 311 896 5528`.

## Arquitectura local

Las listas principales viven en [`lib/services/tienda.dart`](lib/services/tienda.dart):

- `List<Producto> productos`
- `List<Categoria> categorias`
- `List<Pedido> pedidos`
- `List<Domiciliario> domiciliarios`
- `List<Cliente> clientes`
- `List<Administrador> administradores`
- `List<ProductoCarrito> carrito`

La persistencia está centralizada en [`lib/services/preferencias.dart`](lib/services/preferencias.dart). Los modelos se convierten a JSON, se guardan localmente y se reconstruyen al iniciar la aplicación desde [`lib/screens/inicio/splash_screen.dart`](lib/screens/inicio/splash_screen.dart).

El punto de entrada es [`lib/main.dart`](lib/main.dart). La navegación se determina según el rol guardado en la sesión.

## Imágenes y branding

El logo y la imagen de reemplazo se encuentran en [`assets/images/`](assets/images/). [`lib/widgets/imagen_producto.dart`](lib/widgets/imagen_producto.dart) muestra la fotografía adjuntada por el administrador y utiliza el placeholder cuando no existe o no puede cargarse.

## Administrador inicial

- Correo: `admin@fornogo.com`
- Contraseña: `admin123`

Los clientes y domiciliarios se registran manualmente desde la aplicación.

## Limitaciones

- Los datos permanecen únicamente en el dispositivo actual.
- No existe sincronización entre teléfonos.
- El pago es simulado.
- La autenticación incluida es académica y no debe utilizarse como seguridad de producción.
