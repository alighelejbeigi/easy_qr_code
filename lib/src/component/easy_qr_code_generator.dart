import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/qr_painter_with_background.dart';

/// A utility class for generating, saving, and sharing QR codes.
///
/// This class provides methods to create QR codes as widgets, images,
/// save them to storage, and share them directly.
class EasyQRCodeGenerator {
  /// Generates and returns a QR code as a Widget with a white background.
  ///
  /// [data] is the content to encode into the QR code.
  /// [size] specifies the size of the generated QR code widget (default is 200.0).
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
  ///
  /// [data] is the content to encode into the QR code.
  /// [size] specifies the dimensions of the QR code image (default is 200.0).
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

    // Draw a white background.
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);

    // Draw the QR code.
    final painter = QrPainterWithBackground(qrCode: qrCode);
    painter.paint(canvas, Size(size, size));

    final picture = recorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  /// Saves the QR code image from a given Uint8List to the device storage.
  ///
  /// [qrBytes] is the byte data of the QR code image.
  Future<void> saveQRCodeFromBytes({required Uint8List qrBytes}) async {
    try {
      const uuid = Uuid();
      String filePath =
          '/storage/emulated/0/Download/easyQrCode${uuid.v4()}.png';

      // Write the bytes to a file.
      final file = File(filePath);
      await file.writeAsBytes(qrBytes);

      if (kDebugMode) {
        print('QR Code saved to $filePath');
      }
    } catch (e) {
      debugPrint('Error saving QR Code: $e');
    }
  }

  /// Shares the QR code directly from a Uint8List without regenerating it.
  ///
  /// [qrBytes] is the byte data of the QR code image.
  /// [name] (optional) specifies the name of the shared file.
  Future<void> shareQRCodeFromBytes({
    required Uint8List qrBytes,
    String? name,
  }) async {
    try {
      // Create an XFile from the bytes for sharing.
      final xFile = XFile.fromData(
        qrBytes,
        mimeType: 'image/png',
        name: name,
      );

      // Share the file using share_plus.
      await Share.shareXFiles([xFile], text: 'Here is your QR Code!');
    } catch (e) {
      debugPrint('Error sharing QR Code: $e');
    }
  }
}
