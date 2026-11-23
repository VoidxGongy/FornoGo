import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/categoria.dart';
import '../models/producto.dart';

Future<({List<Categoria> categorias, List<Producto> productos})>
    cargarCatalogoFirestore() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: firebaseWebOptions);
  }

  final firestore = FirebaseFirestore.instance;
  const opciones = GetOptions(source: Source.server);
  final consultas = await Future.wait([
    firestore.collection('categorias').orderBy('id').get(opciones),
    firestore.collection('productos').orderBy('id').get(opciones),
  ]);
  try {
    return (
      categorias: consultas.first.docs
          .map((documento) => Categoria.fromMap(
                documento.data(),
                documentoId: documento.id,
              ))
          .toList(),
      productos: consultas.last.docs
          .map((documento) => Producto.fromMap(
                documento.data(),
                documentoId: documento.id,
              ))
          .toList(),
    );
  } on TypeError {
    throw const FormatException(
        'El catálogo de Firestore tiene campos inválidos.');
  }
}
