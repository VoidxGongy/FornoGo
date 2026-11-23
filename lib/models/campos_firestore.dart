import 'package:cloud_firestore/cloud_firestore.dart';

/// El catálogo histórico usa IDs numéricos como nombres de documentos.
int idCatalogoDesdeDocumento(String documentoId, Object? idGuardado) {
  final id = int.tryParse(documentoId);
  if (id == null ||
      id <= 0 ||
      id.toString() != documentoId ||
      (idGuardado != null && idGuardado != id)) {
    throw FormatException('ID de catálogo inválido ($documentoId).');
  }
  return id;
}

/// Un timestamp puede faltar mientras el servidor resuelve la escritura.
DateTime? fechaDesdeFirestore(Object? valor) {
  if (valor == null) return null;
  if (valor is Timestamp) return valor.toDate().toUtc();
  throw const FormatException('Se esperaba un Timestamp de Firestore.');
}
