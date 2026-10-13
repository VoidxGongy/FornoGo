// ============================================
// MODELO: CURSO
// ============================================

class Curso {
  int id;
  String nombre;
  String descripcion;

  Curso({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  // Método propio de la clase
  String mostrarInfo() {
    return 'Curso #$id - $nombre\nDescripción: $descripcion';
  }

  @override
  String toString() {
    return 'Curso{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }
}
