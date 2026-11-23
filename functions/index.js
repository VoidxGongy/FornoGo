const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');

initializeApp();

const db = getFirestore();

exports.notificarCambioEstadoPedido = onDocumentUpdated(
  'pedidos/{pedidoId}',
  async (event) => {
    const antes = event.data?.before.data();
    const despues = event.data?.after.data();
    if (!antes || !despues || antes.estado === despues.estado) return;

    const usuarios = [despues.usuarioId, despues.domiciliarioId]
      .filter(Boolean)
      .filter((uid, index, lista) => lista.indexOf(uid) === index);
    const estado = String(despues.estado);
    const pedidoId = event.params.pedidoId;

    for (const usuarioId of usuarios) {
      const registros = await db
        .collection('usuarios')
        .doc(usuarioId)
        .collection('notificaciones')
        .get();
      const tokens = registros.docs
        .map((registro) => registro.data().token)
        .filter((token) => typeof token === 'string' && token.length > 0);
      if (tokens.length === 0) continue;

      const respuesta = await getMessaging().sendEachForMulticast({
        tokens,
        notification: {
          title: 'Pedido actualizado',
          body: `El pedido #${pedidoId} ahora está: ${estado}.`,
        },
        data: {
          pedidoId,
          estado,
        },
      });

      const eliminar = [];
      respuesta.responses.forEach((resultado, index) => {
        const codigo = resultado.error?.code;
        if (codigo === 'messaging/registration-token-not-registered' ||
            codigo === 'messaging/invalid-registration-token') {
          eliminar.push(registros.docs[index].ref);
        }
      });
      if (eliminar.length > 0) {
        const lote = db.batch();
        eliminar.forEach((referencia) => lote.delete(referencia));
        await lote.commit();
      }
    }
  },
);
