
# FornoGO — aplicación móvil Flutter

Aplicación móvil para gestionar productos, clientes, pedidos y domicilios de una pizzería. El alcance de este proyecto es local y académico: no utiliza Firebase, backend ni base de datos externa.

## Ejecución móvil

```bash
flutter pub get
flutter run
```

El proyecto está preparado para demostrarse en Android mediante Flutter. Las pantallas web no forman parte del alcance de la aplicación.

## Usuarios de demostración

- Administrador: `admin@fornogo.com` / `admin123`
- Cliente: `maria@gmail.com` / `cliente123`
- Domiciliario: `juan@fornogo.com` / `domi123`

Para ver cada módulo, inicia sesión con el usuario correspondiente. El administrador verá productos, categorías, pedidos y domiciliarios. El domiciliario verá sus entregas asignadas.

El botón de WhatsApp para comprobantes abre el número móvil `3118965528` en formato internacional `+57 311 896 5528`.

## Uso de `List`

Las listas principales están declaradas en [lib/services/tienda.dart](lib/services/tienda.dart):

- `List<Producto> productos`
- `List<Categoria> categorias`
- `List<Pedido> pedidos`
- `List<Domiciliario> domiciliarios`
- `List<Cliente> clientes`
- `List<ProductoCarrito> carrito`

En ese servicio se agregan, buscan, recorren, editan y eliminan elementos. Las pantallas de cliente y administrador consumen esas mismas listas.

## Uso de `SharedPreferences`

La persistencia está centralizada en [lib/services/preferencias.dart](lib/services/preferencias.dart). Cada colección se convierte mediante `toJson()`, se serializa con `jsonEncode()` y se guarda con una clave constante. Al iniciar la aplicación se recupera con `jsonDecode()` y `fromJson()`.

La carga inicial se ejecuta desde [lib/screens/inicio/splash_screen.dart](lib/screens/inicio/splash_screen.dart), después de preparar Flutter en [lib/main.dart](lib/main.dart). Los datos permanecen en el dispositivo después de cerrar la aplicación, pero no se sincronizan entre teléfonos y no representan un sistema seguro de autenticación de producción.

## Flujos implementados

- Cliente: login, registro, catálogo, filtro por categoría, carrito, confirmación, métodos de pago e historial.
- Administrador: productos, categorías, pedidos, estados y domiciliarios.
- Domiciliario: entregas asignadas y confirmación de entrega.

Las imágenes incluidas se encuentran en [assets/images/](assets/images/) y se cargan con `Image.asset`. Las operaciones principales se realizan sin conexión a servicios externos.

En la administración de productos se puede seleccionar una de las fotografías PNG locales y observar su vista previa antes de guardar.
