import 'dart:ui' as ui;

import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Constructor for HomePage

  @override
  State<HomePage> createState() =>
      _HomePageState(); // Create state for HomePage
}

class _HomePageState extends State<HomePage> {
  String? _qrCodeResult; // Holds the result of QR code decoding
  final TextEditingController _textController =
      TextEditingController(); // Controller for the text input
  final EasyQRCodeGenerator qrGenerator =
      EasyQRCodeGenerator(); // QR code generator instance
  Widget? result; // Holds the generated QR code widget
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  Uint8List? imageBytes;

  // Method to pick an image from gallery and decode the QR code
  Future<void> _pickImageAndDecodeQRCode() async {
    try {
      final imageFile = await _picker.pickImage(
          source: ImageSource.gallery); // Pick image from gallery
      if (imageFile == null) return;

      // Read image as byte data (Uint8List)
      final bytes = await imageFile.readAsBytes();
      // Decode the QR code from the bytes
      final qrReader = EasyQRCodeReader();
      final decodedResult = await qrReader.decode(bytes);

      // Update the result on the screen
      setState(() {
        _qrCodeResult = decodedResult ?? 'No QR code found.';
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> saveQRCodeImage() async {
    final image =
        await qrGenerator.generateQRCodeImage(data: _textController.text);
    qrGenerator.saveQRCodeImage(image);
  }

  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Method to handle errors in QR code processing
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('Error processing QR code: $error');
    }
    setState(() {
      _qrCodeResult = 'Error decoding QR code.';
    });
  }

  // Method to generate a QR code widget based on text input
  Future<void> _generateQRCode() async {
    final data = _textController.text;
    if (data.isNotEmpty) {
      // Generate the QR code widget
      final qrWidget = await qrGenerator.generateQRCodeWidget(data: data);
      final image = await qrGenerator.generateQRCodeImage(data: data);
      final bytes = await convertImageToBytes(image);
      setState(() {
        result = qrWidget; // Update the result with the generated QR code
        imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner & Generator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Align widgets to the center
            children: [
              // Display QR code result if available
              _buildQRCodeResult(),

              const SizedBox(height: 20),

              // Button to pick image and scan QR code
              _buildPickImageButton(),

              const SizedBox(height: 20),

              // Input field for QR code data
              _buildTextField(),

              const SizedBox(height: 16),

              // Button to generate a QR code from the input
              _buildGenerateQRCodeButton(),

              // Display the generated QR code widget if available

              Row(
                children: [
                  Column(
                    children: [
                      result != null
                          ? const Text('widget show')
                          : const SizedBox(),
                      result != null ? result! : const SizedBox(),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      imageBytes != null
                          ? const Text('Image show')
                          : const SizedBox(),
                      imageBytes != null
                          ? Image.memory(imageBytes!)
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
              imageBytes != null
                  ? IconButton(
                      onPressed: saveQRCodeImage,
                      icon: const Icon(Icons.save),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the QR code result display widget
  Widget _buildQRCodeResult() {
    return _qrCodeResult != null
        ? Text('QR Code Result: $_qrCodeResult')
        : const SizedBox();
  }

  // Method to build the button for picking an image and decoding QR code
  Widget _buildPickImageButton() {
    return ElevatedButton(
      onPressed: _pickImageAndDecodeQRCode,
      child: const Text('Pick Image and Scan QR Code'),
    );
  }

  // Method to build the text field for entering QR code data
  Widget _buildTextField() {
    return TextField(
      controller: _textController,
      decoration: const InputDecoration(
        labelText: 'Enter data for QR Code',
        border: OutlineInputBorder(),
      ),
    );
  }

  // Method to build the button for generating QR code
  Widget _buildGenerateQRCodeButton() {
    return ElevatedButton(
      onPressed: _generateQRCode,
      child: const Text('Generate QR Code'),
    );
  }
}
