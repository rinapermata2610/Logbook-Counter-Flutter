import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_view.dart'; // Pastikan path benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LogBook Rina',
      theme: ThemeData(
        // Tema Pink Soft Natural
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF06292),
          primary: const Color(0xFFF06292),
        ),
        useMaterial3: true,
      ),
      home: const OnboardingView(), // Mulai dari Onboarding
    );
  }
}