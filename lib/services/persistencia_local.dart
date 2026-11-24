import 'package:shared_preferences/shared_preferences.dart';

/// Guarda únicamente datos no sensibles de la última sesión autenticada.
class PersistenciaLocal {
  PersistenciaLocal._();

  static final instancia = PersistenciaLocal._();
  SharedPreferences? _preferencias;

  Future<void> inicializar() async {
    _preferencias ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _obtener() async {
    await inicializar();
    return _preferencias!;
  }

  Future<void> guardarSesion(String uid, String rol) async {
    final preferencias = await _obtener();
    await preferencias.setString('ultima_sesion_uid', uid);
    await preferencias.setString('ultima_sesion_rol', rol);
  }

  Future<void> limpiarSesion() async {
    final preferencias = await _obtener();
    await preferencias.remove('ultima_sesion_uid');
    await preferencias.remove('ultima_sesion_rol');
  }
}
