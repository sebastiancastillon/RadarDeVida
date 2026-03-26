import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AlertaScreen extends StatefulWidget {
  const AlertaScreen({super.key});

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {
  bool _isLoading = true;
  bool _hayEmergencia = false;
  String _tipoSangre = "";
  String _hospital = "";

  @override
  void initState() {
    super.initState();
    _revisarEmergencias();
  }

  // 1. Preguntamos al servidor si hay una alerta activa
  Future<void> _revisarEmergencias() async {
    try {
      final url = Uri.parse('https://radar-de-vida-sebastiancastillons-projects.vercel.app/api/emergencias');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['activa'] == true) {
          setState(() {
            _hayEmergencia = true;
            _tipoSangre = data['tipo_sangre'];
            _hospital = data['hospital'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error verificando emergencias: $e");
    }
    
    setState(() {
      _hayEmergencia = false;
      _isLoading = false;
    });
  }

  // 2. El usuario presiona el botón rojo
  Future<void> _voyEnCamino() async {
    // A. Avisar al servidor para sumar +1 al contador web
    try {
      final url = Uri.parse('https://radar-de-vida-sebastiancastillons-projects.vercel.app/api/emergencias');
      await http.put(url); // Esto dispara el +1 en Vercel
    } catch (e) {
      debugPrint("Error sumando al contador: $e");
    }

    // B. Abrir Google Maps con la ruta al hospital
    // Codificamos el nombre del hospital para que sea una URL válida
    final String hospitalEncoded = Uri.encodeComponent(_hospital);
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$hospitalEncoded");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      
      // Cerramos la pantalla de alerta después de abrir el mapa
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir el mapa. Verifica tu conexión."))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Centro de Alertas"),
        backgroundColor: _hayEmergencia ? const Color(0xFFB71C1C) : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : !_hayEmergencia
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                    SizedBox(height: 20),
                    Text("Todo tranquilo por ahora", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text("No hay emergencias activas en tu zona.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFFFF5F5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_rounded, size: 120, color: Color(0xFFB71C1C)),
                    const SizedBox(height: 20),
                    const Text("¡SE REQUIERE DONADOR!", 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))
                    ),
                    const SizedBox(height: 10),
                    Text("Tipo de Sangre: $_tipoSangre", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("📍 Destino: $_hospital", 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.black87)
                    ),
                    const SizedBox(height: 40),
                    
                    // BOTÓN VOY EN CAMINO
                    ElevatedButton.icon(
                      onPressed: _voyEnCamino,
                      icon: const Icon(Icons.directions_car, size: 28),
                      label: const Text("¡VOY EN CAMINO!", style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(65),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // BOTÓN RECHAZAR
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("No puedo en este momento", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    )
                  ],
                ),
              ),
    );
  }
}