import 'package:flutter/material.dart';
import 'cursos_screen.dart';
import 'estudiantes_screen.dart';

// ============================================
// PANTALLA: HOME (navegación principal)
// ============================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = const [
    CursosScreen(),
    EstudiantesScreen(),
  ];

  final List<String> _titulos = const [
    'Cursos',
    'Estudiantes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indiceActual]),
      ),
      body: _pantallas[_indiceActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (indice) {
          setState(() {
            _indiceActual = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Cursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Estudiantes',
          ),
        ],
      ),
    );
  }
}
