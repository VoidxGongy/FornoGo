// ============================================
// SIMULACIÓN DE UNA API
// ============================================

// Simulamos la respuesta que podría entregar
// una API REST.

List<Map<String, dynamic>> respuestaCursosAPI = [
  {
    'id': 1,
    'nombre': 'Programación Móvil',
    'descripcion': 'Desarrollo de aplicaciones móviles',
  },
  {
    'id': 2,
    'nombre': 'Programación Web',
    'descripcion': 'Desarrollo de aplicaciones web',
  },
  {
    'id': 3,
    'nombre': 'Bases de Datos',
    'descripcion': 'Diseño y administración de bases de datos',
  },
];

List<Map<String, dynamic>> respuestaEstudiantesAPI = [
  {
    'id': 1,
    'nombre': 'Carlos Pérez',
    'correo': 'carlos@gmail.com',
    'cursoId': 1,
  },
  {
    'id': 2,
    'nombre': 'Ana Gómez',
    'correo': 'ana@gmail.com',
    'cursoId': 2,
  },
  {
    'id': 3,
    'nombre': 'Juan Rodríguez',
    'correo': 'juan@gmail.com',
    'cursoId': 1,
  },
];
