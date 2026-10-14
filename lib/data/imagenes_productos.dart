/// Rutas locales oficiales del catálogo. No se generan imágenes por código.
class ImagenesProductos {
  static const String margarita = 'assets/images/pizza_margarita.png';
  static const String pepperoni = 'assets/images/pizza_pepperoni.png';
  static const String hawaiana = 'assets/images/pizza_hawaiana.png';
  static const String cuatroQuesos = 'assets/images/pizza_cuatro_quesos.png';
  static const String gaseosa = 'assets/images/gaseosa.png';
  static const String agua = 'assets/images/agua.png';
  static const String brownie = 'assets/images/brownie.png';
  static const String tiramisu = 'assets/images/tiramisu.png';
  static const String placeholder = 'assets/images/placeholder.png';

  static const List<Map<String, String>> opciones = [
    {'nombre': 'Pizza Margarita', 'ruta': margarita},
    {'nombre': 'Pizza Pepperoni', 'ruta': pepperoni},
    {'nombre': 'Pizza Hawaiana', 'ruta': hawaiana},
    {'nombre': 'Pizza Cuatro Quesos', 'ruta': cuatroQuesos},
    {'nombre': 'Gaseosa 350 ml', 'ruta': gaseosa},
    {'nombre': 'Agua Mineral 500 ml', 'ruta': agua},
    {'nombre': 'Brownie de Chocolate', 'ruta': brownie},
    {'nombre': 'Tiramisú', 'ruta': tiramisu},
    {'nombre': 'Imagen de reemplazo', 'ruta': placeholder},
  ];
}
