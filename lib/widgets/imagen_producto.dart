import 'dart:io';

import 'package:flutter/material.dart';

/// Muestra la foto de un producto: recurso de assets o archivo copiado en el dispositivo.
class ImagenProducto extends StatelessWidget {
  const ImagenProducto({
    super.key,
    required this.ruta,
    required this.esAsset,
    this.width = 72,
    this.height = 72,
    this.borderRadius = 8,
  });

  final String ruta;
  final bool esAsset;
  final double width;
  final double height;
  final double borderRadius;

  static const String placeholder = 'assets/images/placeholder.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _imagen(),
      ),
    );
  }

  Widget _imagen() {
    if (ruta.isEmpty) return _fallback();

    if (esAsset) {
      return Image.asset(
        ruta,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final archivo = File(ruta);
    if (!archivo.existsSync()) return _fallback();

    return Image.file(
      archivo,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  /// Si el archivo no existe o falla la carga, se muestra una imagen de reemplazo.
  Widget _fallback() {
    return Image.asset(
      placeholder,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return ColoredBox(
          color: const Color(0xFFEEEEEE),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: const Color(0xFF9E9E9E),
            size: width * 0.4,
          ),
        );
      },
    );
  }
}
