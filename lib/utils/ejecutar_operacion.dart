import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

Future<bool> ejecutarOperacion(
  BuildContext context,
  Future<void> Function() accion,
) async {
  try {
    await accion();
    return true;
  } catch (error) {
    if (!context.mounted) return false;
    final mensaje = switch (error) {
      StateError() => error.message.toString(),
      FirebaseException(
        code: 'wrong-password' || 'invalid-credential' || 'user-not-found'
      ) =>
        'Correo o contraseña incorrectos.',
      FirebaseException(code: 'email-already-in-use') =>
        'Ese correo ya está registrado.',
      FirebaseException(
        code: 'operation-not-allowed' || 'configuration-not-found'
      ) =>
        'Firebase Authentication debe tener habilitado el acceso por correo.',
      FirebaseException(code: 'unavailable' || 'network-request-failed') =>
        'No hay conexión con Firebase. Vuelve a intentarlo.',
      FirebaseException(code: 'permission-denied') =>
        'Tu cuenta no tiene permiso para esta operación.',
      _ => 'No se pudo completar la operación.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
    return false;
  }
}
