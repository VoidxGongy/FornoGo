'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { notificarCambio, prepararAviso } = require('./pedidos');

const anterior = { usuarioId: 'cliente-a', estado: 'aceptado' };
const actual = { usuarioId: 'cliente-a', estado: 'enCamino' };

test('El aviso corresponde al comprador y omite sus datos de entrega', () => {
  const aviso = prepararAviso(anterior, { ...actual, direccion: 'dato privado' }, 'p1', 'e1');
  assert.equal(aviso.notification.body, 'Tu pedido va en camino.');
  assert.equal(aviso.data.usuarioId, 'cliente-a');
  assert.equal(aviso.webpush.notification.tag, aviso.android.notification.tag);
  assert.ok(!JSON.stringify(aviso).includes('dato privado'));
});

test('Ignora una asignación sin cambio de estado y los pedidos de demostración', () => {
  assert.equal(prepararAviso(actual, { ...actual, domiciliarioId: 'd1' }, 'p1', 'e1'), null);
  assert.equal(prepararAviso(anterior, { ...actual, esDemo: true }, 'p1', 'e1'), null);
});

test('Un evento repetido avisa solo a los dispositivos del comprador', async () => {
  const recibos = new Map();
  const id = 'abcdefghijklmnopqrstuv';
  const desconectado = { id: 'abcdefghijklmno1234567',
    ref: { get: async () => ({ exists: false }) } };
  const dispositivo = { id, ref: { get: async () => ({ exists: true }) } };
  const pedido = {
    id: 'p1',
    get: async () => ({ data: () => actual }),
    collection: () => ({ doc: (id) => id }),
  };

  const db = {
    collection: (nombre) => {
      assert.equal(nombre, 'usuarios');
      return { doc: (uid) => {
        assert.equal(uid, 'cliente-a');
        return { get: async () => ({
          data: () => ({ activo: true, rol: 'cliente' }),
          ref: { collection: (ruta) => {
            assert.equal(ruta, 'dispositivos_push');
            return { get: async () => ({ docs: [dispositivo, desconectado] }) };
          } },
        }) };
      } };
    },
    runTransaction: async (accion) => accion({
      get: async (recibo) => ({ data: () => recibos.get(recibo) }),
      set: (recibo, valor) => recibos.set(recibo, valor),
      delete: (recibo) => recibos.delete(recibo),
    }),
  };
  const enviados = [];
  const mensajeria = { send: async (aviso) => enviados.push(aviso) };
  const evento = {
    id: 'e1',
    data: { before: { data: () => anterior }, after: { data: () => actual, ref: pedido } },
  };
  await notificarCambio(evento, db, mensajeria);
  await notificarCambio(evento, db, mensajeria);
  assert.equal(enviados.length, 1);
  assert.equal(enviados[0].fid, id);
});

test('Conserva los avisos de asignación y extravío para el domiciliario', () => {
  const asignado = prepararAviso(anterior, { ...actual, estado: 'asignado' },
    'p1', 'e1', 'domiciliario-b');
  const extraviado = prepararAviso(actual, { ...actual, estado: 'extraviado' },
    'p1', 'e2', 'domiciliario-b');
  assert.equal(asignado.data.usuarioId, 'domiciliario-b');
  assert.equal(asignado.notification.body, 'Se te asignó un pedido.');
  assert.equal(extraviado.notification.body, 'El pedido se marcó como extraviado.');
});
