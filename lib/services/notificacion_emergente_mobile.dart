import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _notificacionesLocales = FlutterLocalNotificationsPlugin();
bool _inicializada = false;

Future<void> inicializarNotificacionEmergente() async {
  if (_inicializada) return;

  const ajustesAndroid = AndroidInitializationSettings('ic_launcher');
  final ajustesApple = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final ajustes = InitializationSettings(
    android: ajustesAndroid,
    iOS: ajustesApple,
  );

  await _notificacionesLocales.initialize(ajustes);
  await _notificacionesLocales
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await _notificacionesLocales
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
  _inicializada = true;
}

Future<void> mostrarNotificacionEmergente({
  required String titulo,
  required String cuerpo,
}) async {
  await inicializarNotificacionEmergente();
  final android = AndroidNotificationDetails(
    'actualizaciones_pedidos',
    'Actualizaciones de pedidos',
    channelDescription: 'Cambios de estado de los pedidos de FornoGO.',
    importance: Importance.max,
    priority: Priority.high,
    icon: 'ic_launcher',
  );
  const apple = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  final detalles = NotificationDetails(android: android, iOS: apple);
  final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  await _notificacionesLocales.show(id, titulo, cuerpo, detalles);
}
