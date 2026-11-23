import 'package:flutter/material.dart';

class LogoForno extends StatelessWidget {
  const LogoForno({super.key, this.size = 72, this.soloIcono = false});

  final double size;
  final bool soloIcono;

  @override
  Widget build(BuildContext context) => Image.asset(
        soloIcono ? 'assets/images/logo_icon.png' : 'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.local_pizza, size: size),
      );
}
