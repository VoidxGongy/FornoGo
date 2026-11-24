import 'package:get/get.dart';

import '../models/sesion.dart';
import '../services/tienda.dart';

/// Puente GetX para el estado global que administra Tienda.
class TiendaController extends GetxController {
  final sesion = Rxn<Sesion>();

  void _sincronizar() => sesion.value = Tienda.instancia.sesion;

  @override
  void onInit() {
    super.onInit();
    Tienda.instancia.addListener(_sincronizar);
    _sincronizar();
  }

  @override
  void onClose() {
    Tienda.instancia.removeListener(_sincronizar);
    super.onClose();
  }
}
