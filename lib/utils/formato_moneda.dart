/// Formatea valores en pesos colombianos sin agregar dependencias externas.
String formatoPesosColombianos(num valor) {
  final texto = valor.round().toString();
  final grupos = <String>[];
  for (var fin = texto.length; fin > 0; fin -= 3) {
    final inicio = fin - 3 < 0 ? 0 : fin - 3;
    grupos.insert(0, texto.substring(inicio, fin));
  }
  return '\$${grupos.join('.')}';
}
