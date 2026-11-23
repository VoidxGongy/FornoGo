import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/inicio/splash_screen.dart';
import 'theme/tema_fornogo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('FornoGO está configurado para Android y web.');
    }
    await Firebase.initializeApp(
      options: kIsWeb ? firebaseWebOptions : firebaseAndroidOptions,
    );
    FirebaseFirestore.instance.settings =
        const Settings(persistenceEnabled: false);
    runApp(const MyApp());
  } catch (error) {
    debugPrint('Error al iniciar Firebase: $error');
    runApp(const MaterialApp(
        home: Scaffold(
            body: Center(
      child:
          Text('No se pudo iniciar Firebase. Cierra y vuelve a abrir FornoGO.'),
    ))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FornoGO',
        debugShowCheckedModeBanner: false,
        theme: TemaFornoGO.tema,
        home: const SplashScreen(),
      );
}
