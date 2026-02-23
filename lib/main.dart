import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook Rina',
      debugShowCheckedModeBanner: false,
      
      // Pengaturan tema global aplikasi (Material 3)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        
        // Konsistensi style untuk AppBar di seluruh aplikasi
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
      ),
      
      // Halaman pertama yang muncul adalah Onboarding
      home: const OnboardingView(),
    );
  }
}