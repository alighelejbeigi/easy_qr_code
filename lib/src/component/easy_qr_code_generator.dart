import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class EasyQRCodeGenerator {
  /// Generates and returns a QR code as a Widget with a white background.
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
          painter: QrPainterWithBackground(qrCode: qrCode),
        ),
      );
    } catch (e) {
      // Log the error if QR code generation fails.
      debugPrint('Error generating QR Code widget: $e');

      // Return an error message widget in case of failure.
      return const Text('Error generating QR Code');
    }
  }

  /// Generates and returns a QR code as an image with a white background.
  Future<ui.Image> generateQRCodeImage({
    required String data,
    double size = 200.0,
  }) async {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw a white background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

    // Draw the QR code
    final painter = QrPainterWithBackground(qrCode: qrCode);
    painter.paint(canvas, Size(size, size));

    final picture = recorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  Future<void> saveQRCodeImage(ui.Image image) async {
    const uuid = Uuid();
    // Convert the image to ByteData
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      String filePath =
          '/storage/emulated/0/Download/easyQrCode${uuid.v4()}.jpg';

      // Write the ByteData to a file
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (kDebugMode) {
        print('QR Code saved to $filePath');
      }
    }
  }
}

class QrPainterWithBackground extends CustomPainter {
  final QrCode qrCode;

  QrPainterWithBackground({required this.qrCode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a white background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw the QR code
    final qrPainter = QrPainter.withQr(qr: qrCode);
    qrPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
