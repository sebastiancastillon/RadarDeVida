import 'package:flutter/material.dart';
import 'package:radardevida/home_screen.dart';
import 'package:radardevida/registro_screen.dart';
import 'package:radardevida/mapa_screen.dart';

void main() {
  runApp(const RadarDeVidaApp());
}

class RadarDeVidaApp extends StatelessWidget {
  const RadarDeVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radar de Vida',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C), // Rojo Sangre
          primary: const Color(0xFFB71C1C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/registro': (context) => const RegistroScreen(),
        '/mapa': (context) => const MapaScreen(),
      },
    );
  }
}