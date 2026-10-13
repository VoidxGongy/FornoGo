import 'package:flutter/material.dart';

import '../models/imagen.dart';

class ImagenCard extends StatelessWidget {
  final Imagen imagen;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ImagenCard({
    super.key,
    required this.imagen,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imagen.url,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Icon(Icons.broken_image, size: 60),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imagen.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(imagen.descripcion),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: onEliminar,
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
