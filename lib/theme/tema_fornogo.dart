import 'package:flutter/material.dart';

/// Identidad visual compartida por todas las pantallas móviles.
class TemaFornoGO {
  static const rojo = Color(0xFFD92D2D);
  static const rojoOscuro = Color(0xFFB91C1C);
  static const naranja = Color(0xFFF97316);
  static const amarillo = Color(0xFFFBBF24);
  static const fondo = Color(0xFFFFF9F6);
  static const superficie = Color(0xFFFFFFFF);
  static const texto = Color(0xFF2B2020);
  static const textoSecundario = Color(0xFF746767);
  static const borde = Color(0xFFF0E4E0);
  static const verde = Color(0xFF2E7D32);

  static ThemeData get tema {
    final esquema = ColorScheme.fromSeed(seedColor: rojo, primary: rojo);
    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: fondo,
        surfaceTintColor: Colors.transparent,
        foregroundColor: texto,
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borde),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: rojo, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: superficie,
        selectedColor: const Color(0xFFFFE0DC),
        side: const BorderSide(color: borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: textoSecundario),
        secondaryLabelStyle: const TextStyle(color: rojoOscuro),
      ),
    );
  }
}
