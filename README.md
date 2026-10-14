# FornoGO

<<<<<<< HEAD
# FornoGO — aplicación móvil Flutter

Aplicación móvil para gestionar productos, clientes, pedidos y domicilios de una pizzería. El alcance de este proyecto es local y académico: no utiliza Firebase, backend ni base de datos externa.

## Ejecución móvil
=======
Aplicación móvil Flutter para administrar el catálogo, clientes, pedidos y domicilios de una pizzería. Es un proyecto local y académico: no utiliza Firebase, backend ni una base de datos externa.

## Ejecución
>>>>>>> 4e4b37b (Mejora del menu y detelles)

```bash
flutter pub get
flutter run
```

<<<<<<< HEAD
El proyecto está preparado para demostrarse en Android mediante Flutter. Las pantallas web no forman parte del alcance de la aplicación.

## Usuarios de demostración

- Administrador: `admin@fornogo.com` / `admin123`
- Cliente: `maria@gmail.com` / `cliente123`
- Domiciliario: `juan@fornogo.com` / `domi123`

Para ver cada módulo, inicia sesión con el usuario correspondiente. El administrador verá productos, categorías, pedidos y domiciliarios. El domiciliario verá sus entregas asignadas.

El botón de WhatsApp para comprobantes abre el número móvil `3118965528` en formato internacional `+57 311 896 5528`.

## Uso de `List`

Las listas principales están declaradas en [lib/services/tienda.dart](lib/services/tienda.dart):
=======
El flujo principal está pensado para Android. La información se conserva en el dispositivo mediante `SharedPreferences` y no se sincroniza entre teléfonos.

## Usuarios de demostración

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | `admin@fornogo.com` | `admin123` |
| Cliente | `maria@gmail.com` | `cliente123` |
| Domiciliario | `juan@fornogo.com` | `domi123` |

## Funcionalidades

- Cliente: registro, inicio de sesión, catálogo, búsqueda, filtros por categoría, carrito, confirmación de pedido, métodos de pago e historial.
- Administrador: gestión de productos, categorías, pedidos, estados y domiciliarios.
- Domiciliario: consulta de entregas asignadas y confirmación de entregas.
- Comprobantes: el botón de WhatsApp abre el número `+57 311 896 5528`.
- Diseño: encabezados rojos con texto blanco, logo de FornoGO y navegación inferior por rol.

## Arquitectura local

Las listas principales viven en [`lib/services/tienda.dart`](lib/services/tienda.dart):
>>>>>>> 4e4b37b (Mejora del menu y detelles)

- `List<Producto> productos`
- `List<Categoria> categorias`
- `List<Pedido> pedidos`
- `List<Domiciliario> domiciliarios`
- `List<Cliente> clientes`
<<<<<<< HEAD
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
=======
- `List<Administrador> administradores`
- `List<ProductoCarrito> carrito`

La persistencia está centralizada en [`lib/services/preferencias.dart`](lib/services/preferencias.dart). Los modelos se convierten a JSON mediante `toJson()`, se guardan con `SharedPreferences` y se reconstruyen con `fromJson()` al iniciar la aplicación.

La inicialización se realiza desde [`lib/screens/inicio/splash_screen.dart`](lib/screens/inicio/splash_screen.dart). [`lib/services/tienda.dart`](lib/services/tienda.dart) también migra rutas antiguas de imágenes para que los productos y las miniaturas del carrito utilicen los assets actuales.

## Imágenes y branding

Los recursos están en [`assets/images/`](assets/images/) y se registran en [`pubspec.yaml`](pubspec.yaml). Las rutas del catálogo están centralizadas en [`lib/data/imagenes_productos.dart`](lib/data/imagenes_productos.dart):

- Pizza Margarita → `pizza_margarita.png`
- Pizza Pepperoni → `pizza_pepperoni.png`
- Pizza Hawaiana → `pizza_hawaiana.png`
- Pizza Cuatro Quesos → `pizza_cuatro_quesos.png`
- Bebidas y postres → sus respectivos PNG locales

[`lib/widgets/imagen_producto.dart`](lib/widgets/imagen_producto.dart) muestra cada imagen y utiliza `placeholder.png` si el archivo no existe. [`lib/widgets/logo_forno.dart`](lib/widgets/logo_forno.dart) carga el logo principal o el icono de FornoGO.

El tema visual global se define en [`lib/theme/tema_fornogo.dart`](lib/theme/tema_fornogo.dart), incluyendo el color rojo de los encabezados, el contraste blanco y los estilos de tarjetas, campos y navegación.

## Limitaciones

Los datos quedan únicamente en el dispositivo y la autenticación es académica; no debe considerarse segura para producción. El proyecto no incluye sincronización remota ni servicios de backend.
>>>>>>> 4e4b37b (Mejora del menu y detelles)
