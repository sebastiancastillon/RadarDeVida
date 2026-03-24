import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:radardevida/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mensajeStatus = "Escaneando área...";
  String _hospitalCercano = "";
  bool _hayEmergencia = false;

  // --- BASE DE DATOS DE HOSPITALES ---
  // Tip: Busca en Google Maps "Hospital" y copia su Latitud y Longitud
  final List<Map<String, dynamic>> _baseDatosHospitales = [
    {
      "nombre": "Hospital Regional Universitario",
      "lat": 19.2433, 
      "lng": -103.725
    },
    {
      "nombre": "Clínica 1 IMSS",
      "lat": 19.2490, 
      "lng": -103.733
    },
    {
      "nombre": "Hospital Civil",
      "lat": 19.2550,
      "lng": -103.715
    }
  ];

  Future<void> _escanearArea() async {
    setState(() {
      _mensajeStatus = "Obteniendo tu ubicación...";
      _hayEmergencia = false;
    });

    try {
      // 1. Obtener posición real del usuario
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      double menorDistancia = 999999;
      String nombreHosp = "";

      // 2. Comparar con cada hospital
      for (var hospital in _baseDatosHospitales) {
        double distancia = Geolocator.distanceBetween(
          position.latitude, 
          position.longitude, 
          hospital['lat'], 
          hospital['lng']
        );

        // 3. Verificar si está dentro del radio de 2km (2000 metros)
        if (distancia <= 2000) {
          if (distancia < menorDistancia) {
            menorDistancia = distancia;
            nombreHosp = hospital['nombre'];
          }
        }
      }

      setState(() {
        if (nombreHosp.isNotEmpty) {
          _hayEmergencia = true;
          _hospitalCercano = nombreHosp;
          _mensajeStatus = "¡ALERTA! El $nombreHosp está a ${menorDistancia.toStringAsFixed(0)}m y necesita donadores.";
        } else {
          _hayEmergencia = false;
          _mensajeStatus = "No hay solicitudes de sangre en tu radio de 2km.";
        }
      });
    } catch (e) {
      setState(() => _mensajeStatus = "Error: Asegúrate de tener el GPS encendido.");
    }
  }

  @override
  void initState() {
    super.initState();
    _escanearArea();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radar de Vida")),
      drawer: const AppDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono animado según el estado
            Stack(
              alignment: Alignment.center,
              children: [
                if (_hayEmergencia)
                  const CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                Icon(
                  _hayEmergencia ? Icons.warning_amber_rounded : Icons.radar,
                  size: 120,
                  color: _hayEmergencia ? Colors.red : Colors.blueGrey,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              _mensajeStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: _hayEmergencia ? FontWeight.bold : FontWeight.normal,
                color: _hayEmergencia ? Colors.red.shade900 : Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _escanearArea,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: _hayEmergencia ? Colors.red : Colors.grey.shade200,
                foregroundColor: _hayEmergencia ? Colors.white : Colors.black,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text("VOLVER A ESCANEAR"),
            ),
          ],
        ),
      ),
    );
  }
}