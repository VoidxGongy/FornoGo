'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { notificarCambio } = require('./pedidos');

const app = initializeApp();

exports.notificarCambioEstadoPedido = onDocumentUpdated(
  { document: 'pedidos/{pedidoId}', region: 'southamerica-west1', retry: true },
  (evento) => notificarCambio(evento, getFirestore(app), getMessaging(app)),
);
