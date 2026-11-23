import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'notificacion_emergente.dart';

class NotificacionesForno extends ChangeNotifier {
  NotificacionesForno._();
  static final instancia = NotificacionesForno._();
  final mensajero = GlobalKey<ScaffoldMessengerState>();

  static const _vapid = String.fromEnvironment('FCM_VAPID_KEY',
      defaultValue: firebaseWebVapidKey);
  static const _esperaRegistro = Duration(seconds: 20);
  static const _esperaSalida = Duration(seconds: 4);

  final _mensajeria = FirebaseMessaging.instance;
  String? _uid;
  String? _fid;
  Future<void>? _registro;
  Future<void> _guardado = Future.value();
  StreamSubscription<String>? _registros;
  StreamSubscription<RemoteMessage>? _mensajes;

  String? get idInstalacion => _uid == null ? null : _fid;
  bool get activas => idInstalacion != null;
  bool get configurando => _registro != null;

  DocumentReference<Map<String, dynamic>> _dispositivo(
          String uid, String fid) =>
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('dispositivos_push')
          .doc(fid);

  void vincular(String uid) {
    _uid = uid;
    unawaited(_reanudar(uid));
  }

  Future<void> _reanudar(String uid) async {
    try {
      final permiso = await _mensajeria.getNotificationSettings();
      if (_uid == uid &&
          permiso.authorizationStatus == AuthorizationStatus.authorized) {
        await _registrar(uid);
      }
    } catch (error) {
      debugPrint('No se pudo reanudar FCM: $error');
    }
  }

  Future<void> activar() async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Inicia sesión para activar las notificaciones.');
    }
    final permisos = await _mensajeria.requestPermission();
    if (permisos.authorizationStatus != AuthorizationStatus.authorized) {
      throw StateError(
          'Habilita las notificaciones en la configuración del navegador o del dispositivo.');
    }
    if (_uid == uid) await _registrar(uid);
  }

  Future<void> _registrar(String uid) {
    final enCurso = _registro;
    if (enCurso != null) return enCurso;
    late final Future<void> intento;
    intento = _iniciarRegistro(uid).whenComplete(() {
      if (identical(_registro, intento)) {
        _registro = null;
        notifyListeners();
      }
    });
    _registro = intento;
    return intento;
  }

  Future<void> _iniciarRegistro(String uid) async {
    final primero = Completer<void>();
    await _registros?.cancel();
    if (_uid != uid) return;

    _mensajes ??= FirebaseMessaging.onMessage.listen((mensaje) async {
      if (_uid == null) return;
      // Los avisos generales de Firebase Console no incluyen usuarioId.
      final destinatario = mensaje.data['usuarioId'];
      if (destinatario != null && destinatario != _uid) return;
      final texto = mensaje.notification?.body;
      if (texto == null || texto.isEmpty) return;
      try {
        await mostrarNotificacionEmergente(
          titulo: mensaje.notification?.title ?? 'FornoGO',
          cuerpo: texto,
        );
      } catch (_) {
        mensajero.currentState?.showSnackBar(SnackBar(content: Text(texto)));
      }
    });
    _registros = _mensajeria.onRegistered.listen((fid) {
      if (_uid != uid) return;
      _guardado = _guardado.then((_) async {
        if (_uid != uid) return;
        try {
          await _guardarDispositivo(uid, fid);
          if (!primero.isCompleted) primero.complete();
        } catch (error, stackTrace) {
          if (!primero.isCompleted) {
            primero.completeError(error, stackTrace);
          } else {
            debugPrint('No se pudo actualizar el registro FCM: $error');
          }
        }
      });
    }, onError: (Object error, StackTrace stackTrace) {
      if (!primero.isCompleted) primero.completeError(error, stackTrace);
    });
    notifyListeners();
    await Future.wait<void>([
      primero.future.timeout(
        _esperaRegistro,
        onTimeout: () =>
            throw StateError('FCM no pudo registrar este dispositivo.'),
      ),
      _mensajeria.register(
        vapidKey: kIsWeb && _vapid.isNotEmpty ? _vapid : null,
      ),
    ], eagerError: true);
  }

  Future<void> _guardarDispositivo(String uid, String fid) async {
    final anterior = _fid;
    final db = FirebaseFirestore.instance;
    final lote = db.batch();
    lote.set(_dispositivo(uid, fid), {
      'plataforma': kIsWeb ? 'web' : 'android',
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
    if (anterior != null && anterior != fid) {
      lote.delete(_dispositivo(uid, anterior));
    }
    await lote.commit();
    if (_uid != uid) {
      await _dispositivo(uid, fid).delete();
      return;
    }
    _fid = fid;
    notifyListeners();
  }

  /// La baja se intenta antes de que Firebase Auth retire la sesión.
  Future<void> desvincular() async {
    final uid = _uid;
    if (uid == null) return;
    _uid = null;
    await _registros?.cancel();
    _registros = null;
    try {
      await _guardado.timeout(_esperaSalida);
      final fid = _fid;
      if (fid != null) {
        await _dispositivo(uid, fid).delete().timeout(_esperaSalida);
      }
    } catch (error) {
      debugPrint('No se pudo eliminar el registro de Firestore: $error');
      try {
        await _mensajeria.unregister().timeout(_esperaSalida);
      } catch (error) {
        debugPrint('No se pudo retirar el dispositivo de FCM: $error');
      }
    } finally {
      _fid = null;
      _registro = null;
      notifyListeners();
    }
  }
}
