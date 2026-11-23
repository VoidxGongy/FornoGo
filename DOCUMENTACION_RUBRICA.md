# Documentación de FornoGO

## Persistencia

FornoGO utiliza Firebase Authentication para las credenciales y Cloud Firestore como fuente de datos para Android y la web. `Tienda` mantiene las listas en memoria para la interfaz y las actualiza al recibir instantáneas de Firestore.

| Colección | Datos |
| --- | --- |
| `usuarios` | Perfiles de clientes, administradores y domiciliarios, identificados por UID. |
| `categorias` y `productos` | Catálogo y fotografías. Cada producto contiene el ID de su categoría. |
| `pedidos` | Comprador, domiciliario asignado, datos de entrega, ítems históricos y estado. |
| `inventario` | Existencias, umbral de stock bajo y movimientos de cada producto. |
| `usuarios/{uid}/carrito` | Cantidades seleccionadas por el cliente, sincronizadas entre dispositivos. |

El cliente envía el carrito como un pedido pendiente y lo vacía con una sola transacción. El administrador acepta el pedido después de validar los precios y las existencias. Firestore registra el movimiento de inventario junto con el cambio de estado. El domiciliario consulta sus pedidos asignados y confirma las entregas en camino.

Para configurar los roles y publicar la web, consulta el [README](README.md).
