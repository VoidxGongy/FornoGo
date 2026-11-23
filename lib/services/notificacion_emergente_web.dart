import 'dart:html' as html;

Future<void> inicializarNotificacionEmergente() async {
  if (html.Notification.permission == 'default') {
    await html.Notification.requestPermission();
  }
}

Future<void> mostrarNotificacionEmergente({
  required String titulo,
  required String cuerpo,
}) async {
  await inicializarNotificacionEmergente();
  if (html.Notification.permission != 'granted') return;

  html.Notification(
    titulo,
    body: cuerpo,
    icon: '/icons/Icon-192.png',
  );
}
