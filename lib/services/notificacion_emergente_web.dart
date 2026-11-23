import 'package:web/web.dart' as web;

Future<void> mostrarNotificacionEmergente({
  required String titulo,
  required String cuerpo,
}) async {
  if (web.Notification.permission != 'granted') return;
  web.Notification(
    titulo,
    web.NotificationOptions(body: cuerpo, icon: '/icons/Icon-192.png'),
  );
}
