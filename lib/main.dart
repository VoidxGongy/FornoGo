import 'package:flutter/material.dart';
import 'screens/inicio/splash_screen.dart';
import 'theme/tema_fornogo.dart';

// ============================================
// PUNTO DE ENTRADA DE LA APP
// ============================================

Future<void> main() async {
  // Obligatorio antes de usar plugins como SharedPreferences.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FornoGO',
      debugShowCheckedModeBanner: false,
      theme: TemaFornoGO.tema,
      home: const SplashScreen(),
    );
  }
}
