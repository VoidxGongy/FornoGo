import 'package:flutter/material.dart';

/// Identidad visual compartida por todas las pantallas móviles.
class TemaFornoGO {
  static const rojo = Color(0xFFD92D2D);
  static const rojoOscuro = Color(0xFFB91C1C);
  static const naranja = Color(0xFFF97316);
  static const amarillo = Color(0xFFFBBF24);
  static const fondo = Color(0xFFFFF8F5);
  static const superficie = Color(0xFFFFFFFF);
  static const texto = Color(0xFF2B2020);
  static const textoSecundario = Color(0xFF746767);
  static const borde = Color(0xFFF0E4E0);
  static const verde = Color(0xFF2E7D32);

  static ThemeData get tema {
    final esquema = ColorScheme.fromSeed(
      seedColor: rojo,
      brightness: Brightness.light,
    ).copyWith(
      primary: rojo,
      onPrimary: Colors.white,
      secondary: naranja,
      onSecondary: Colors.white,
      surface: superficie,
      onSurface: texto,
      error: const Color(0xFFB3261E),
    );
    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      useMaterial3: true,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: fondo,
        surfaceTintColor: Colors.transparent,
        foregroundColor: texto,
        iconTheme: IconThemeData(color: texto),
        actionsIconTheme: IconThemeData(color: texto),
        titleTextStyle: TextStyle(
          color: texto,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 1.5,
        shadowColor: const Color(0x18000000),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFCFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: rojo, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: superficie,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFFFE2DE),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? rojoOscuro
                : textoSecundario,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: superficie,
        indicatorColor: const Color(0xFFFFE2DE),
        selectedIconTheme: const IconThemeData(color: rojoOscuro),
        unselectedIconTheme: const IconThemeData(color: textoSecundario),
        selectedLabelTextStyle: const TextStyle(
          color: rojoOscuro,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: textoSecundario,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: rojo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: texto,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
