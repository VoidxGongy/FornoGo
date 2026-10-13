import 'dart:io';

import 'package:flutter/material.dart';

import '../services/tienda.dart';

/// Logo de FornoGO. Usa la ruta guardada en Tienda (asset o archivo local).
class LogoForno extends StatelessWidget {
  const LogoForno({
    super.key,
    this.size = 72,
    this.soloIcono = false,
  });

  final double size;
  final bool soloIcono;

  static const String assetLogo = 'assets/images/logo.png';
  static const String assetIcono = 'assets/images/logo_icon.png';

  @override
  Widget build(BuildContext context) {
    final tienda = Tienda.instancia;
    final ruta = soloIcono ? assetIcono : tienda.rutaLogo;
    final esAsset = soloIcono ? true : tienda.logoEsAsset;

    Widget imagen;
    if (esAsset) {
      imagen = Image.asset(
        ruta,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _reemplazo(),
      );
    } else {
      final archivo = File(ruta);
      if (!archivo.existsSync()) {
        imagen = _reemplazo();
      } else {
        imagen = Image.file(
          archivo,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _reemplazo(),
        );
      }
    }

    return SizedBox(width: size, height: size, child: imagen);
  }

  Widget _reemplazo() {
    return Image.asset(
      assetLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Icon(Icons.local_pizza, size: size * 0.7, color: const Color(0xFFD32F2F));
      },
    );
  }
}
