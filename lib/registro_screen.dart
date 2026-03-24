import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:radardevida/app_drawer.dart'; 
import 'dart:convert'; 
import 'package:http/http.dart' as http; 

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
  
  List<CameraDescription> _cameras = [];
  int _camaraActual = 1; // 1 = Frontal, 0 = Trasera por lo general

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Buscar la cámara frontal para iniciar
    _camaraActual = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    if (_camaraActual == -1) _camaraActual = 0; // Si no hay frontal, usa la que haya

    _iniciarControladorCamara(_cameras[_camaraActual]);
  }

  // --- FUNCIÓN PARA CAMBIAR ENTRE CÁMARAS ---
  void _cambiarCamara() {
    if (_cameras.length < 2) return; // Si solo hay 1 cámara, no hace nada
    
    _camaraActual = _camaraActual == 0 ? 1 : 0;
    _iniciarControladorCamara(_cameras[_camaraActual]);
  }

  Future<void> _iniciarControladorCamara(CameraDescription cameraDescription) async {
    _controller = CameraController(
      cameraDescription,
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
                            return Stack(
                              children: [
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _controller!.value.previewSize!.height,
                                      height: _controller!.value.previewSize!.width,
                                      child: CameraPreview(_controller!),
                                    ),
                                  ),
                                ),
                                // BOTÓN PARA CAMBIAR CÁMARA
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                                      onPressed: _cambiarCamara,
                                    ),
                                  ),
                                ),
                              ],
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
                  icon: const Icon(Icons.camera),
                  label: const Text("Tomar Foto"),
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

            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (val) => setState(() {}),
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
              onPressed: (_imageFile == null || _nombreController.text.isEmpty)
                  ? null
                  : () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enviando a Panel de Administración...")),
                      );

                      try {
                        final bytes = await File(_imageFile!.path).readAsBytes();
                        String base64Image = "data:image/png;base64,${base64Encode(bytes)}";

                        final url = Uri.parse('https://radar-de-vida-sebastiancastillons-projects.vercel.app/api/donadores');

                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "nombre": _nombreController.text,
                            "tipo_sangre": _tipoSangre,
                            "foto": base64Image,
                          }),
                        );

                        if (response.statusCode == 201 || response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ ¡Donante registrado con éxito!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // AHORA EL FORMULARIO SE LIMPIA DESPUÉS DE SUBIR
                          setState(() {
                            _imageFile = null;
                            _nombreController.clear(); 
                            _tipoSangre = "O+"; // Lo regresamos al valor por defecto
                          });
                        } else {
                          throw Exception('Error del servidor');
                        }
                      } catch (e) {
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