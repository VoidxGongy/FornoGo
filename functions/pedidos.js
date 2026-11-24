'use strict';

const { createHash, randomUUID } = require('node:crypto');

const mensajes = {
  asignado: 'Asignamos un domiciliario a tu pedido.',
  extraviado: 'Tu pedido se marcó como extraviado.',
  aceptado: 'Aceptamos tu pedido.',
  enPreparacion: 'Estamos preparando tu pedido.',
  listo: 'Tu pedido está listo.',
  enCamino: 'Tu pedido va en camino.',
  entregado: 'Tu pedido fue entregado.',
  rechazado: 'No pudimos aceptar tu pedido.',
  cancelado: 'Tu pedido fue cancelado.',
};

const invalidos = new Set([
  'messaging/installation-id-not-registered',
  'messaging/invalid-registration-token',
  'messaging/registration-token-not-registered',
]);

const claveDe = (texto) => createHash('sha256').update(texto).digest('hex').slice(0, 32);

function prepararAviso(anterior, actual, pedidoId, eventoId, usuarioId = actual?.usuarioId) {
  if (!anterior || !actual || anterior.estado === actual.estado || actual.esDemo === true ||
      typeof usuarioId !== 'string' || !usuarioId || usuarioId.includes('/')) {
    return null;
  }
  if (!Object.hasOwn(mensajes, actual.estado)) return null;

  const tag = claveDe(pedidoId);
  const cuerpo = usuarioId === actual.usuarioId ? mensajes[actual.estado]
    : actual.estado === 'asignado' ? 'Se te asignó un pedido.'
      : 'El pedido se marcó como ' + ({
        aceptado: 'aceptado', enPreparacion: 'en preparación', listo: 'listo',
        enCamino: 'en camino', entregado: 'entregado', rechazado: 'rechazado',
        cancelado: 'cancelado', extraviado: 'extraviado',
      })[actual.estado] + '.';
  return {
    notification: { title: 'FornoGO', body: cuerpo },
    data: { usuarioId, pedidoId, avisoId: eventoId },
    android: { notification: { tag } },
    webpush: {
      notification: { tag, icon: '/icons/Icon-192.png' },
      fcmOptions: { link: 'https://fornogo-pizzeria-2026.web.app/' },
    },
  };
}

async function enviarUnaVez(db, mensajeria, pedido, dispositivo, aviso, eventoId) {
  const recibo = pedido.collection('avisos_push').doc(claveDe(eventoId + ':' + dispositivo.id));
  const intento = randomUUID();
  const inicio = Date.now();

  const pendiente = await db.runTransaction(async (tx) => {
    const estado = (await tx.get(recibo)).data();
    if (estado?.terminado === true) return false;
    if (estado?.vigenteHasta > inicio) throw new Error('El envío de este aviso está en curso.');
    tx.set(recibo, { intento, vigenteHasta: inicio + 120_000 });
    return true;
  });
  if (!pendiente) return;

  const finalizar = (exito) => db.runTransaction(async (tx) => {
    const estado = (await tx.get(recibo)).data();
    if (estado?.intento !== intento) return;
    if (exito) {
      tx.set(recibo, { terminado: true, registradoEn: new Date() });
    } else {
      tx.delete(recibo);
    }
  });

  try {
    // El registro pudo eliminarse al salir de la cuenta durante el disparo.
    if (!(await dispositivo.ref.get()).exists) {
      await finalizar(true);
      return;
    }

    try {
      await mensajeria.send({ ...aviso, token: dispositivo.id });
    } catch (error) {
      if (!invalidos.has(error.code)) throw error;
      const precondicion = { lastUpdateTime: dispositivo.updateTime };
      await dispositivo.ref.delete(precondicion).catch((borrado) => {
        // Un registro renovado después de la consulta conserva su nueva versión.
        if (borrado.code !== 9 && borrado.code !== 'failed-precondition') throw borrado;
      });
    }
    await finalizar(true);
  } catch (error) {
    await finalizar(false);
    throw error;
  }
}

async function notificarCambio(evento, db, mensajeria) {
  const cambio = evento.data;
  if (!cambio) return;
  const anterior = cambio.before.data();
  const actual = cambio.after.data();
  const pedido = cambio.after.ref;
  const avisoCliente = prepararAviso(anterior, actual, pedido.id, evento.id);
  if (!avisoCliente) return;

  const vigente = (await pedido.get()).data();
  if (vigente?.estado !== actual.estado || vigente?.usuarioId !== actual.usuarioId) return;

  const destinos = [{ rol: 'cliente', aviso: avisoCliente }];
  if (vigente.domiciliarioId && vigente.domiciliarioId === actual.domiciliarioId &&
      vigente.domiciliarioId !== actual.usuarioId) {
    const aviso = prepararAviso(anterior, actual, pedido.id, evento.id,
      vigente.domiciliarioId);
    if (aviso) destinos.push({ rol: 'domiciliario', aviso });
  }

  for (const { rol, aviso } of destinos) {
    const perfil = await db.collection('usuarios').doc(aviso.data.usuarioId).get();
    if (perfil.data()?.activo !== true || perfil.data()?.rol !== rol) continue;
    const dispositivos = (await perfil.ref.collection('dispositivos_push').get()).docs
      .filter((doc) => /^[A-Za-z0-9_-]{22}$/.test(doc.id));

    // Limita el paralelismo y reintenta solo los envíos pendientes.
    for (let i = 0; i < dispositivos.length; i += 20) {
      const resultados = await Promise.allSettled(dispositivos.slice(i, i + 20)
        .map((doc) => enviarUnaVez(db, mensajeria, pedido, doc, aviso, evento.id)));
      const fallo = resultados.find((resultado) => resultado.status === 'rejected');
      if (fallo) throw fallo.reason;
    }
  }
}

module.exports = { prepararAviso, notificarCambio };
