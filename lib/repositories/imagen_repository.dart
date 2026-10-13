import '../data/memoria.dart';
import '../models/imagen.dart';

class ImagenRepository {
  List<Imagen> obtenerImagenes() {
    return Memoria.imagenes;
  }

  void agregarImagen(Imagen imagen) {
    imagen.id = Memoria.siguienteId;
    Memoria.siguienteId++;
    Memoria.imagenes.add(imagen);
  }

  void actualizarImagen(Imagen imagenActualizada) {
    final index = Memoria.imagenes.indexWhere(
      (imagen) => imagen.id == imagenActualizada.id,
    );

    if (index != -1) {
      Memoria.imagenes[index] = imagenActualizada;
    }
  }

  void eliminarImagen(int id) {
    Memoria.imagenes.removeWhere(
      (imagen) => imagen.id == id,
    );
  }
}
