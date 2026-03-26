import 'dart:async'; // Necesario para el Stream
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:radardevida/app_drawer.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _ubicacionActual;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream; // Suscripción en tiempo real

  @override
  void initState() {
    super.initState();
    _iniciarRastreo();
  }

  void _iniciarRastreo() async {
    // Verificamos permisos primero (Opcional pero recomendado)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // Escuchamos la ubicación todo el tiempo
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Se actualiza si te mueves 5 metros
      ),
    ).listen((Position position) {
      setState(() {
        _ubicacionActual = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Importante apagar el GPS al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Cobertura")),
      drawer: const AppDrawer(),
      body: _ubicacionActual == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _ubicacionActual!,
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.radardevida.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _ubicacionActual!,
                      radius: 8000, // Lo subimos a 8 KM como pediste antes
                      useRadiusInMeter: true,
                      color: Colors.red.withOpacity(0.2),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ubicacionActual!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_ubicacionActual != null) {
            _mapController.move(_ubicacionActual!, 14.5);
          }
        },
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }
}