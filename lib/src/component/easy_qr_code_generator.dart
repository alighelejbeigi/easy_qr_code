import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EasyQRCodeGenerator {
  /// Generates and returns a QR code as a Widget.
  ///
  /// [data] is the content to encode into the QR code.
  /// [size] is the size of the generated QR code widget (default is 200.0).
  Future<Widget> generateQRCodeWidget({
    required String data,
    double size = 200.0,
  }) async {
    try {
      // Create a QR code from the provided data with medium error correction level.
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      // Return the QR code as a custom painted widget within a SizedBox.
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: QrPainter.withQr(qr: qrCode),
        ),
      );
    } catch (e) {
      // Log the error if QR code generation fails.
      debugPrint('Error generating QR Code widget: $e');

      // Return an error message widget in case of failure.
      return const Text('Error generating QR Code');
    }
  }
}
