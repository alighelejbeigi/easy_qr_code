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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy QR Code Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _qrCodeResult; // Stores the decoded QR code result
  final TextEditingController _textController =
      TextEditingController(); // Controller for text input
  final EasyQRCodeGenerator qrGenerator =
      EasyQRCodeGenerator(); // QR code generator instance
  Widget? result; // Stores the generated QR code widget
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  Uint8List? imageBytes; // Stores the image bytes for generated QR code

  // Method to pick an image and decode the QR code
  Future<void> _pickImageAndDecodeQRCode() async {
    try {
      final imageFile = await _picker.pickImage(
          source: ImageSource.gallery); // Open image picker
      if (imageFile == null) return;

      // Read image as byte data (Uint8List)
      final bytes = await imageFile.readAsBytes();
      final qrReader = EasyQRCodeReader();
      final decodedResult =
          await qrReader.decode(bytes); // Decode QR code from image

      setState(() {
        _qrCodeResult =
            decodedResult ?? 'No QR code found.'; // Update the result
      });
    } catch (e) {
      _handleError(e); // Handle error in QR code processing
    }
  }

  // Method to save generated QR code image
  Future<void> saveQRCodeImage() async {
    qrGenerator.saveQRCodeFromBytes(qrBytes: imageBytes!);
  }

  // Method to share generated QR code image
  Future<void> shareQRCodeImage() async {
    qrGenerator.shareQRCodeFromBytes(qrBytes: imageBytes!);
  }

  // Method to convert image to byte array (Uint8List)
  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Method to handle errors during QR code decoding
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('Error processing QR code: $error');
    }
    setState(() {
      _qrCodeResult = 'Error decoding QR code.';
    });
  }

  // Method to generate QR code from the text input
  Future<void> _generateQRCode() async {
    final data = _textController.text;
    if (data.isNotEmpty) {
      final qrWidget = await qrGenerator.generateQRCodeWidget(
          data: data); // Generate QR widget
      final image = await qrGenerator.generateQRCodeImage(
          data: data); // Generate QR image
      final bytes =
          await convertImageToBytes(image); // Convert image to byte data
      setState(() {
        result = qrWidget; // Update QR widget to display
        imageBytes = bytes; // Store the image bytes
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
            children: [
              // QR Code result display
              _buildQRCodeResult(),

              const SizedBox(height: 20),

              // Button to pick image and scan QR code
              _buildPickImageButton(),

              const SizedBox(height: 20),

              // TextField for QR code data input
              _buildTextField(),

              const SizedBox(height: 16),

              // Button to generate QR code from input
              _buildGenerateQRCodeButton(),

              // Display generated QR code widget and image
              _buildQRCodeDisplay(),

              // Save and Share buttons for the generated QR code
              _buildSaveAndShareButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display the decoded QR code result
  Widget _buildQRCodeResult() {
    return _qrCodeResult != null
        ? Text('QR Code Result: $_qrCodeResult',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        : const SizedBox();
  }

  // Button to pick an image and scan for a QR code
  Widget _buildPickImageButton() {
    return ElevatedButton(
      onPressed: _pickImageAndDecodeQRCode,
      child: const Text('Pick Image and Scan QR Code'),
    );
  }

  // TextField for entering QR code data
  Widget _buildTextField() {
    return TextField(
      controller: _textController,
      decoration: const InputDecoration(
        labelText: 'Enter data for QR Code',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
    );
  }

  // Button to generate a QR code from the input text
  Widget _buildGenerateQRCodeButton() {
    return ElevatedButton(
      onPressed: _generateQRCode,
      child: const Text('Generate QR Code'),
    );
  }

  // Display the generated QR code widget or image
  Widget _buildQRCodeDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            if (result != null) ...[
              const Text('Generated QR Code:'),
              result!,
            ],
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            if (imageBytes != null) ...[
              const Text('Generated QR Code Image:'),
              Image.memory(imageBytes!),
            ]
          ],
        ),
      ],
    );
  }

  // Save and Share buttons for the generated QR code
  Widget _buildSaveAndShareButtons() {
    if (imageBytes == null) {
      return const SizedBox(); // Only show buttons if image is generated
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: saveQRCodeImage,
            icon: const Icon(Icons.save),
            tooltip: 'Save QR Code',
          ),
          IconButton(
            onPressed: shareQRCodeImage,
            icon: const Icon(Icons.share),
            tooltip: 'Share QR Code',
          ),
        ],
      );
    }
  }
}
