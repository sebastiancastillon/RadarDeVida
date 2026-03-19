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

  @override
  void initState() {
    super.initState();
    _determinarPosicion();
  }

  Future<void> _determinarPosicion() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _ubicacionActual = LatLng(position.latitude, position.longitude);
    });
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
                // 1. Capa de diseño del mapa (OpenStreetMap)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.radardevida.app',
                ),
                
                // 2. Radio de 1 KM (Geocerca)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _ubicacionActual!,
                      radius: 1000, // 1000 metros = 1 KM
                      useRadiusInMeter: true,
                      color: Colors.red.withOpacity(0.2),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

                // 3. Marcador de tu posición
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