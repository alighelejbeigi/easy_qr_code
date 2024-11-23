import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_qr_code/easy_qr_code.dart'; // Ensure this is the correct path
import 'package:qr_flutter/qr_flutter.dart';


void main() {
  group('QRGenerator Tests', () {
    test('should generate a QR code widget successfully', () async {
      // Arrange
      final qrGenerator = EasyQRCodeGenerator();
      const testData = 'https://example.com';
      const expectedSize = 200.0;

      // Act
      final qrWidget = await qrGenerator.generateQRCodeWidget(data: testData, size: expectedSize);

      // Assert
      expect(qrWidget, isA<SizedBox>());
      final sizedBox = qrWidget as SizedBox;
      expect(sizedBox.width, expectedSize);
      expect(sizedBox.height, expectedSize);

      // You can also check for a CustomPaint widget if needed:
      final customPaint = sizedBox.child as CustomPaint;
      expect(customPaint.painter, isA<QrPainter>());
    });
  });

  group('EasyQRCodeReader Tests', () {
    test('should decode a valid QR code from image bytes', () async {
      // Arrange: Generate a simple image from the string 'https://example.com'
      const testData = 'https://example.com';
      final qrGenerator = EasyQRCodeGenerator();

      // Generate the QR code widget (this will be used to get the image bytes)
      final qrWidget = await qrGenerator.generateQRCodeWidget(data: testData);
      final sizedBox = qrWidget as SizedBox;
      final customPaint = sizedBox.child as CustomPaint;
      final painter = customPaint.painter as QrPainter;

      // Convert the QR code to a byte array for testing the decoder
      final imageBytes = await _getImageBytes(painter);
      final qrReader = EasyQRCodeReader();

      // Act: Try decoding the QR code
      final decodedText = await qrReader.decode(Uint8List.fromList(imageBytes));

      // Assert: The decoded text should match the input string
      expect(decodedText, testData);
    });

    test('should return null when the QR code image is invalid', () async {
      // Arrange: Provide invalid bytes (empty data)
      final qrReader = EasyQRCodeReader();
      final invalidBytes = Uint8List(0);

      // Act: Attempt to decode the invalid QR code
      final decodedText = await qrReader.decode(invalidBytes);

      // Assert: The result should be null
      expect(decodedText, isNull);
    });
  });
}

/// Helper method to get image bytes from a QrPainter
Future<List<int>> _getImageBytes(QrPainter painter) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, const Size(200, 200)); // Assuming a 200x200 size for the QR code
  final picture = recorder.endRecording();
  final img = await picture.toImage(200, 200); // Same size as above
  final byteData = await img.toByteData(format: ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
