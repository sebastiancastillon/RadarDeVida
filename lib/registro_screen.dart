import 'package:flutter/material.dart';
import 'package:camera/camera.dart';import 'dart:io';
import 'package:camera/camera.dart';
import 'package:radardevida/app_drawer.dart'; // Corregido el path común
import 'dart:convert'; // Para convertir la imagen a Base64
import 'package:http/http.dart' as http; // Para enviar datos a internet

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;
  String _tipoSangre = "O+";
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // BUSCAR LA CÁMARA FRONTAL (SELFIE)
    final frontal = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontal,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      debugPrint("Error al tomar foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Donante")),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Captura tu identificación o Selfie",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // --- VISOR DE CÁMARA CORREGIDO (SIN ESTIRAR) ---
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _imageFile == null
                    ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                            // Aplicamos FittedBox + AspectRatio para evitar el estiramiento
                            return Center(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller!.value.previewSize!.height,
                                  height: _controller!.value.previewSize!.width,
                                  child: CameraPreview(_controller!),
                                ),
                              ),
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_front),
                  label: const Text("Tomar Selfie"),
                ),
                if (_imageFile != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _imageFile = null),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text("Repetir"),
                  ),
              ],
            ),

            const Divider(height: 40),

            // --- FORMULARIO DE DATOS ---
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (val) => setState(() {}), // Para refrescar el botón
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: _tipoSangre,
              decoration: const InputDecoration(
                labelText: "Tipo de Sangre",
                border: OutlineInputBorder(),
              ),
              items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _tipoSangre = val.toString()),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              // El botón solo se activa si hay foto Y nombre
              onPressed: (_imageFile == null || _nombreController.text.isEmpty)
                  ? null
                  : () async {
                      // 1. Mostrar mensaje de carga
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enviando a Panel de Administración...")),
                      );

                      try {
                        // 2. Preparar la imagen: Convertirla a Base64
                        final bytes = await File(_imageFile!.path).readAsBytes();
                        String base64Image = "data:image/png;base64,${base64Encode(bytes)}";

                        // 3. Tu URL de Vercel (Asegúrate de que incluya /api/donadores)
                        final url = Uri.parse('https://radar-de-vida-sebastiancastillons-projects.vercel.app/api/donadores');

                        // 4. Enviar la petición POST
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "nombre": _nombreController.text,
                            "tipo_sangre": _tipoSangre,
                            "foto": base64Image,
                          }),
                        );

                        // 5. Verificar si el servidor respondió bien
                        if (response.statusCode == 201 || response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ ¡Donante registrado con éxito!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Opcional: Limpiar el formulario después de subir
                          setState(() {
                            _imageFile = null;
                            _nombreController.clear();
                          });
                        } else {
                          throw Exception('Error del servidor: ${response.statusCode}');
                        }
                      } catch (e) {
                        // 6. Manejo de errores de conexión
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("❌ Error al enviar datos: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
              ),
              child: const Text("FINALIZAR Y SUBIR"),
            ),
          ],
        ),
      ),
    );
  }
}