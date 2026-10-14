import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences {
    if (_preferences == null) {
      throw Exception(
        'SharedPreferences no ha sido inicializado. Ejecute init() primero.',
      );
    }

    return _preferences!;
  }

  Future<void> guardarUsuario({
    required String nombre,
    required String correo,
    required String usuario,
    required String password,
  }) async {
    await preferences.setString('nombre', nombre);
    await preferences.setString('correo', correo);
    await preferences.setString('usuario', usuario);
    await preferences.setString('password', password);
  }

  String? obtenerUsuario() => preferences.getString('usuario');

  String? obtenerPassword() => preferences.getString('password');

  String? obtenerNombre() => preferences.getString('nombre');

  String? obtenerCorreo() => preferences.getString('correo');

  bool existeUsuario() => preferences.containsKey('usuario');

  Future<void> iniciarSesion() async {
    await preferences.setBool('sesion_activa', true);
  }

  bool sesionActiva() => preferences.getBool('sesion_activa') ?? false;

  Future<void> cerrarSesion() async {
    await preferences.setBool('sesion_activa', false);
  }
}
