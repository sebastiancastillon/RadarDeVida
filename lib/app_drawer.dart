import 'package:flutter/material.dart';
import 'package:radardevida/home_screen.dart';
import 'package:radardevida/registro_screen.dart';
import 'package:radardevida/mapa_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView( 
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFB71C1C)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bloodtype, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text(
                  "RADAR DE VIDA",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFB71C1C)),
            title: const Text("Inicio"),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1, color: Color(0xFFB71C1C)),
            title: const Text("Nuevo Registro"),
            onTap: () => Navigator.pushReplacementNamed(context, '/registro'),
          ),
          ListTile(
            leading: const Icon(Icons.map_rounded, color: Color(0xFFB71C1C)),
            title: const Text("Mapa de Consulta"),
            onTap: () => Navigator.pushReplacementNamed(context, '/mapa'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Radio de búsqueda: 1 km", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}