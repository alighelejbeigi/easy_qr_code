import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A custom painter for rendering a QR code with a white background.
class QrPainterWithBackground extends CustomPainter {
  /// The [QrCode] object to be painted.
  final QrCode qrCode;

  /// Constructor for [QrPainterWithBackground].
  QrPainterWithBackground({required this.qrCode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a white background.
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw the QR code.
    final qrPainter = QrPainter.withQr(qr: qrCode);
    qrPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}