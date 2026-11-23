# FornoGO

Aplicación Flutter para administrar el catálogo, los pedidos y las entregas de una pizzería. Android y web usan el mismo proyecto Firebase y los mismos datos.

## Ejecutar

```bash
flutter pub get
flutter run
```

- Firebase Authentication autentica las cuentas por correo y contraseña.
- Firestore guarda perfiles, categorías, productos, pedidos e inventario. El carrito se guarda en `usuarios/{uid}/carrito/actual`.
- Al confirmar el carrito, el cliente envía un pedido pendiente. Al aceptarlo, el administrador valida precios y stock y registra los movimientos en la misma transacción. La cancelación de un pedido aceptado devuelve las existencias.
- El administrador puede ajustar las existencias y el stock mínimo desde el menú de cada producto. Las fotos nuevas se guardan con el producto y se muestran en todos los dispositivos.

## Primera cuenta administrativa

En el proyecto `fornogo-pizzeria-2026`, habilita el proveedor de correo y contraseña en Firebase Authentication. Registra tu cuenta desde FornoGO, busca su UID en Authentication y cambia el campo `rol` a `administrador` en el documento `usuarios/{uid}` desde Firebase Console. Inicia sesión de nuevo para cargar el perfil administrativo. Las cuentas de clientes no pueden asignarse privilegios.

## Web

```bash
flutter build web
firebase deploy --only firestore:rules,hosting
```

Firebase Hosting sirve `build/web`. Las reglas limitan el acceso a cada perfil, carrito y pedido. Android usa las opciones registradas para `com.example.p23092026`.

El catálogo inicial e inventario residen en Firestore. Los datos que existían solo en instalaciones anteriores permanecen en esos dispositivos y deben revisarse antes de cualquier importación.
## Notificaciones de pedidos

El cliente y el domiciliario pueden activar las notificaciones en **Mi perfil**. La app registra el
dispositivo con FCM mediante su Firebase Installation ID y guarda el registro en
`usuarios/{uid}/dispositivos_push/{fid}`. Con la app abierta, muestra el aviso
dentro de FornoGO. Android y el service worker web reciben los avisos en segundo plano.

La compilación usa la clave VAPID pública del proyecto. Para cambiarla, genera la nueva clave en Configuración del proyecto → Cloud Messaging → Certificados de notificaciones web y reemplázala en las opciones de Firebase, o compila con `--dart-define=FCM_VAPID_KEY=CLAVE_PUBLICA`.

```bash
flutter build web
firebase deploy --only firestore:rules,hosting
```

Tras activar las notificaciones, usa **Cloud Messaging → Enviar mensaje de prueba**
con el FID del documento del dispositivo y pon la app en segundo plano.

Los avisos automáticos usan la función `notificarCambioEstadoPedido`. La función escucha los
cambios de estado de `pedidos` y envía al comprador y al domiciliario asignado mediante el Admin SDK y las
credenciales del entorno. Firebase requiere el plan Blaze para desplegarla.

```bash
cd functions
npm ci
npm test
cd ..
firebase deploy --only functions:notificarCambioEstadoPedido
```
