import '../models/imagen.dart';
import '../models/usuario.dart';

class Memoria {
  static Usuario? usuario;

  static List<Imagen> imagenes = [
    Imagen(
      id: 1,
      titulo: 'Paisaje',
      descripcion: 'Hermoso paisaje natural',
      url: 'https://picsum.photos/id/10/600/400',
    ),
    Imagen(
      id: 2,
      titulo: 'Montaña',
      descripcion: 'Paisaje de montaña',
      url: 'https://picsum.photos/id/29/600/400',
    ),
    Imagen(
      id: 3,
      titulo: 'Ciudad',
      descripcion: 'Vista de una ciudad',
      url: 'https://picsum.photos/id/122/600/400',
    ),
  ];

  static int siguienteId = 4;
}
