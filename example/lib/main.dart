// Import necessary Flutter packages and libraries
import 'dart:ui' as ui;
import 'package:easy_qr_code/easy_qr_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Entry point of the application
void main() {
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy QR Code Demo',
      theme: _buildThemeData(),
      home: const HomePage(),
    );
  }

  // Theme configuration for the application
  ThemeData _buildThemeData() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.grey.shade700, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade500, width: 2),
        ),
      ),
    );
  }
}

// Main page widget for QR code operations
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _qrCodeResult;
  final TextEditingController _textController = TextEditingController();
  final EasyQRCodeGenerator _qrGenerator = EasyQRCodeGenerator();
  final ImagePicker _picker = ImagePicker();
  Widget? _resultWidget;
  Uint8List? _imageBytes;

  // Builds the UI for the home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Easy QR Code',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.teal.shade300,
    );
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_qrCodeResult != null) _buildQRCodeResultText(),
              ElevatedButton(
                onPressed: _pickImageAndDecodeQRCode,
                child: const Text('Pick Image and Scan QR Code'),
              ),
              const SizedBox(height: 20),
              _buildInputField(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateQRCode,
                child: const Text('Generate QR Code'),
              ),
              const SizedBox(height: 20),
              _buildQRCodeDisplay(),
              const SizedBox(height: 20),
              if (_imageBytes != null) _buildSaveShareButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Displays QR code decoding result
  Widget _buildQRCodeResultText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'QR Code Result: $_qrCodeResult',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Builds the input field for QR code data
  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      decoration: const InputDecoration(
        labelText: 'Enter data for QR Code',
      ),
    );
  }

  // Displays generated QR code and image
  Widget _buildQRCodeDisplay() {
    return Row(
      children: [
        if (_resultWidget != null)
          Column(
            children: [
              const Text('Generated QR Code:'),
              _resultWidget!,
            ],
          ),
        const SizedBox(width: 10),
        if (_imageBytes != null)
          Column(
            children: [
              const Text('Generated QR Code Image:'),
              Image.memory(_imageBytes!),
            ],
          ),
      ],
    );
  }

  // Buttons for saving and sharing QR code
  Widget _buildSaveShareButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(
          icon: Icons.save,
          tooltip: 'Save QR Code',
          onPressed: _saveQRCodeImage,
        ),
        const SizedBox(width: 20),
        _buildIconButton(
          icon: Icons.share,
          tooltip: 'Share QR Code',
          onPressed: _shareQRCodeImage,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade300,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        iconSize: 25,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  // Handles image selection and QR code decoding
  Future<void> _pickImageAndDecodeQRCode() async {
    try {
      final imageFile = await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) return;

      final bytes = await imageFile.readAsBytes();
      final decodedResult = await EasyQRCodeReader().decode(bytes);

      setState(() {
        _qrCodeResult = decodedResult ?? 'No QR code found.';
      });
    } catch (e) {
      _handleError(e);
    }
  }

  // Generates QR code based on input text
  Future<void> _generateQRCode() async {
    final data = _textController.text;
    if (data.isNotEmpty) {
      final qrWidget = await _qrGenerator.generateQRCodeWidget(data: data);
      final image = await _qrGenerator.generateQRCodeImage(data: data);
      final bytes = await _convertImageToBytes(image);
      setState(() {
        _resultWidget = qrWidget;
        _imageBytes = bytes;
      });
    }
  }

  // Saves QR code image
  Future<void> _saveQRCodeImage() async {
    _qrGenerator.saveQRCodeFromBytes(qrBytes: _imageBytes!);
  }

  // Shares QR code image
  Future<void> _shareQRCodeImage() async {
    _qrGenerator.shareQRCodeFromBytes(qrBytes: _imageBytes!);
  }

  // Converts an image to bytes
  Future<Uint8List?> _convertImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // Handles errors gracefully
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('Error processing QR code: $error');
    }
    setState(() {
      _qrCodeResult = 'Error decoding QR code.';
    });
  }
}
