import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import '../widgets/custom_scaffold.dart';

class ManualLogPage extends StatefulWidget {
  const ManualLogPage({super.key});

  @override
  State<ManualLogPage> createState() => _ManualLogPageState();
}

class _ManualLogPageState extends State<ManualLogPage> {
  String _selectedStatus = 'fresh';
  final TextEditingController _confidenceController = TextEditingController();
  String? _imagePath;

  void _submitLog() async {
    final double? confidence = double.tryParse(_confidenceController.text);
    if (confidence == null || confidence < 0 || confidence > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid confidence (0–100).")),
      );
      return;
    }

    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    Map<String, dynamic> logData = {
      'status': _selectedStatus,
      'confidence': confidence,
      'timestamp': now,
      'batch': 'Manual-${now.microsecondsSinceEpoch}',
    };

    if (_imagePath != null) {
      logData['image_path'] = _imagePath;
    }

    await FirebaseFirestore.instance.collection('eggs').add(logData);

    final summaryRef =
        FirebaseFirestore.instance.collection('dailySummary').doc(formattedDate);
    final snapshot = await summaryRef.get();

    if (snapshot.exists) {
      await summaryRef.update({
        _selectedStatus: FieldValue.increment(1),
      });
    } else {
      await summaryRef.set({
        'fresh': _selectedStatus == 'fresh' ? 1 : 0,
        'rotten': _selectedStatus == 'rotten' ? 1 : 0,
        'date': now,
      });
    }

    _confidenceController.clear();
    setState(() {
      _imagePath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Egg log added successfully.")),
    );
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No cameras found on this device.")),
      );
      return;
    }

    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => TakePictureScreen(camera: cameras.first),
      ),
    );

    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Manual Logging',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'GreatVibes', 
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const Text(
                  'Log egg status and confidence manually',
                  style: TextStyle(color: Colors.brown),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Egg Status",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusButton("fresh", Colors.green),
                          const SizedBox(width: 10),
                          _buildStatusButton("rotten", Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text("Confidence (%)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confidenceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "e.g. 94",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.amber.shade50,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_imagePath != null)
                        Center(
                          child: Column(
                            children: [
                              Image.file(File(_imagePath!), height: 180),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _imagePath = null;
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text("Remove Photo"),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Open Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitLog,
                          icon: const Icon(Icons.add),
                          label: const Text("Submit Log"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String type, Color color) {
    final isSelected = _selectedStatus == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Text(
            type[0].toUpperCase() + type.substring(1),
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Camera screen widget:
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({super.key, required this.camera});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _takePicture() async {
    final image = await _controller.takePicture();

    // Save to app directory for permanence
    final directory = await getApplicationDocumentsDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final newPath = join(directory.path, '$name.png');
    final newImage = await File(image.path).copy(newPath);

    return newImage.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Take Picture'), backgroundColor: Colors.brown),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final imagePath = await _takePicture();
            if (!mounted) return;
            Navigator.pop(context, imagePath);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error taking picture: $e')),
            );
          }
        },
      ),
    );
  }
}
