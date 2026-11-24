# FornoGO

Aplicación Flutter para gestionar el catálogo, los pedidos, el inventario y las
entregas de una pizzería. Android y web utilizan el proyecto Firebase
`fornogo-pizzeria-2026`.

## Funcionalidades

### Cliente

- Registro e inicio de sesión con Firebase Authentication.
- Consulta, búsqueda y filtro del catálogo.
- Carrito persistido en Firestore.
- Creación y consulta de pedidos.
- Activación de notificaciones push.

### Administrador

- Gestión de categorías y productos.
- Ajuste de inventario y stock mínimo.
- Consulta y actualización transaccional de pedidos.
- Asignación de domiciliarios.
- Gestión de domiciliarios.

### Domiciliario

- Consulta de pedidos asignados.
- Confirmación de entregas.
- Consulta de entregas completadas.
- Activación de notificaciones push.

## Tecnologías

- Flutter y Dart.
- Firebase Authentication.
- Cloud Firestore.
- Firebase Cloud Messaging.
- Firebase Functions.
- Flutter Local Notifications.
- SharedPreferences para datos locales no sensibles.
- GetX para la inyección del controlador de sesión y la selección reactiva
  del flujo por rol.

El proyecto no utiliza Firebase Realtime Database ni Firebase Storage. Las
imágenes seleccionadas por el administrador se guardan como datos Base64 en el
documento del producto, con un límite de 700 KB.

## Arquitectura

La aplicación utiliza modelos Dart, pantallas Flutter, widgets reutilizables,
un servicio Singleton `Tienda` basado en `ChangeNotifier` y un
`TiendaController` de GetX que conecta el estado de sesión con la navegación
por roles.

```text
lib/
├── controllers/
├── models/
├── screens/
│   ├── administrador/
│   ├── cliente/
│   ├── domiciliario/
│   ├── inicio/
│   ├── navegacion/
│   └── compartidos/
├── services/
├── theme/
├── utils/
└── widgets/
```

## Colecciones Firestore

- `usuarios/{uid}`
- `usuarios/{uid}/carrito/actual`
- `usuarios/{uid}/dispositivos_push/{fid}`
- `categorias/{id}`
- `productos/{id}`
- `inventario/{productoId}`
- `inventario/{productoId}/movimientos/{movimientoId}`
- `pedidos/{id}`
- `pedidos/{id}/avisos_push/{avisoId}`

Los catálogos, perfiles, pedidos, carrito e inventario se sincronizan mediante
listeners `snapshots()` de Cloud Firestore.

## Instalación

Requisitos:

- Flutter 3.50.1 o compatible.
- Dart 3.14 o compatible.
- Android SDK para compilar Android.
- Firebase CLI.
- Un dispositivo Android o un navegador compatible para las pruebas.

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar:

```bash
flutter run
```

Crear la versión web:

```bash
flutter build web
firebase deploy --only firestore:rules,hosting
```

## Configuración de administrador

1. Registra una cuenta desde FornoGO.
2. Busca su UID en Firebase Authentication.
3. Crea o edita `usuarios/{uid}` en Firestore.
4. Establece `rol` en `administrador`.
5. Mantén `activo` en `true`.
6. Cierra e inicia sesión de nuevo.

## Notificaciones push

1. Inicia sesión como cliente o domiciliario.
2. Abre **Mi perfil**.
3. Pulsa **Activar notificaciones** y concede los permisos.
4. Verifica que aparezca `usuarios/{uid}/dispositivos_push/{fid}`.
5. Desde Firebase Console utiliza **Cloud Messaging → Enviar mensaje de
   prueba**.
6. Prueba con la aplicación abierta, en segundo plano y después de abrirla
   desde la notificación.

Las notificaciones automáticas de pedidos utilizan la función
`notificarCambioEstadoPedido`.

Desplegar Functions:

```bash
cd functions
npm ci
npm test
cd ..
firebase deploy --only functions:notificarCambioEstadoPedido
```

El despliegue de Functions puede requerir el plan Blaze.

## Pruebas

```bash
flutter analyze
flutter test
```

```bash
cd functions
npm test
```

Para validar el flujo completo se requiere un proyecto Firebase autorizado y
un dispositivo real. No se deben utilizar operaciones destructivas sobre datos
de producción.

## Seguridad

- Firebase Authentication administra las contraseñas.
- No se guardan contraseñas ni tokens administrativos en SharedPreferences.
- Las reglas de Firestore restringen perfiles, carritos, pedidos e inventario
  según el usuario y su rol.
- `firebase_options.dart` y `firebase.xml` contienen configuración pública de
  cliente, no credenciales administrativas.
- Las reglas desplegadas deben comprobarse también desde Firebase Console.

## Limitaciones conocidas

- La aplicación soporta oficialmente Android y web.
- iOS y Linux no forman parte del flujo soportado.
- La recuperación y verificación de correo aún no forman parte del flujo.
- Los pedidos no se eliminan físicamente; se actualizan o se marcan con un
  estado final.
