import 'package:flutter/material.dart';
import 'data/repository.dart';
import 'screens/home_screen.dart';
import 'services/preferencias.dart';
import 'services/tienda.dart';

// ============================================
// PUNTO DE ENTRADA DE LA APP
// ============================================

Future<void> main() async {
  // Obligatorio antes de usar plugins como SharedPreferences.
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Abre el almacenamiento local.
  await Preferencias.instancia.init();
  // 2) Recupera las listas (o crea la semilla la primera vez).
  await Tienda.instancia.cargarPersistencia();

  // Datos del proyecto anterior (se reemplazarán en las pantallas de FornoGO).
  cargarCursos();
  cargarEstudiantes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cursos y Estudiantes',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
