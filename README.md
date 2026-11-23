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
