import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notificacion_emergente.dart';

class Notificaciones {
  Notificaciones._();

  static final _mensajeria = FirebaseMessaging.instance;
  static StreamSubscription<String>? _cambiosToken;
  static StreamSubscription<RemoteMessage>? _mensajes;
  static String? _usuarioId;

  static Future<void> iniciar(String usuarioId) async {
    await detener();
    _usuarioId = usuarioId;

    final permiso = await _mensajeria.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (permiso.authorizationStatus != AuthorizationStatus.authorized &&
        permiso.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    await inicializarNotificacionEmergente();

    const claveVapid = String.fromEnvironment('FCM_WEB_VAPID_KEY');
    final token = await _mensajeria.getToken(
      vapidKey: kIsWeb && claveVapid.isNotEmpty ? claveVapid : null,
    );
    if (token != null) await _guardarToken(token);
    _cambiosToken = _mensajeria.onTokenRefresh.listen(_guardarToken);
    _mensajes = FirebaseMessaging.onMessage.listen((mensaje) async {
      final titulo = mensaje.notification?.title ?? 'Pedido actualizado';
      final cuerpo = mensaje.notification?.body ??
          'El estado de tu pedido cambió. Revisa los detalles en FornoGO.';
      try {
        await mostrarNotificacionEmergente(titulo: titulo, cuerpo: cuerpo);
      } catch (error) {
        debugPrint('FornoGO: no se pudo mostrar la notificación: $error');
      }
    });
  }

  static Future<void> detener() async {
    await _cambiosToken?.cancel();
    await _mensajes?.cancel();
    _cambiosToken = null;
    _mensajes = null;
    _usuarioId = null;
  }

  static Future<void> _guardarToken(String token) async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return;
    final documento = Uri.encodeComponent(token);
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioId)
        .collection('notificaciones')
        .doc(documento)
        .set({
      'token': token,
      'plataforma': kIsWeb ? 'web' : 'android',
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }
}
