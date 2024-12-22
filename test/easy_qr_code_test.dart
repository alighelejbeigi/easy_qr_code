import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_qr_code/src/models/qr_painter_with_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_qr_code/easy_qr_code.dart';

void main() {
  group('EasyQRCodeGenerator Tests', () {
    testWidgets('should generate a QR code widget successfully',
        (WidgetTester tester) async {
      // Arrange
      final qrGenerator = EasyQRCodeGenerator();
      const testData = 'https://example.com';
      const expectedSize = 200.0;

      // Act
      final qrWidget = await qrGenerator.generateQRCodeWidget(
          data: testData, size: expectedSize);

      // Assert
      expect(qrWidget, isA<SizedBox>());
      final sizedBox = qrWidget as SizedBox;
      expect(sizedBox.width, expectedSize);
      expect(sizedBox.height, expectedSize);

      // Verify the child is a CustomPaint widget
      expect(sizedBox.child, isA<CustomPaint>());
      final customPaint = sizedBox.child as CustomPaint;
      expect(customPaint.painter, isA<QrPainterWithBackground>());
    });

    test('should generate a QR code image successfully', () async {
      // Arrange
      final qrGenerator = EasyQRCodeGenerator();
      const testData = 'https://example.com';
      const expectedSize = 200.0;

      // Act
      final qrImage = await qrGenerator.generateQRCodeImage(
          data: testData, size: expectedSize);

      // Assert
      expect(qrImage, isA<ui.Image>());
      expect(qrImage.width, expectedSize.toInt());
      expect(qrImage.height, expectedSize.toInt());
    });
  });

  group('EasyQRCodeReader Tests', () {
    test('should decode a valid QR code from image bytes', () async {
      // Arrange
      const testData = 'https://example.com';
      final qrGenerator = EasyQRCodeGenerator();

      // Generate the QR code image
      final qrImage = await qrGenerator.generateQRCodeImage(data: testData);
      final imageBytes = await _getImageBytesFromImage(qrImage);

      // Verify bytes are not empty
      expect(imageBytes.isNotEmpty, isTrue,
          reason: 'Image bytes should not be empty.');

      final qrReader = EasyQRCodeReader();

      // Act
      final decodedText = await qrReader.decode(Uint8List.fromList(imageBytes));

      // Assert
      expect(decodedText, testData);
    });

    test('should return null when the QR code image is invalid', () async {
      // Arrange
      final qrReader = EasyQRCodeReader();
      final invalidBytes = Uint8List(0);

      // Act
      final decodedText = await qrReader.decode(invalidBytes);

      // Assert
      expect(decodedText, isNull);
    });
  });
}

/// Helper method to convert a ui.Image to a byte array for testing
Future<List<int>> _getImageBytesFromImage(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null || byteData.lengthInBytes == 0) {
    throw Exception('Failed to convert ui.Image to byte data.');
  }
  return byteData.buffer.asUint8List();
}
