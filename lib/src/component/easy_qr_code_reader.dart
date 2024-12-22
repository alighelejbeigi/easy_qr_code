import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// A class for decoding QR codes from image data.
class EasyQRCodeReader {
  /// Decodes a QR code from the provided image bytes.
  ///
  /// [bytes] is the byte array representing the image to be decoded.
  /// Returns the decoded QR code text if successful, or null if decoding fails.
  Future<String?> decode(Uint8List bytes) async {
    try {
      // Decode the image from the provided byte data.
      final image = img.decodeImage(Uint8List.fromList(bytes));

      // Check if the image is valid (not null).
      if (image != null) {
        // Create a luminance source from the image, converting it to RGBA format.
        LuminanceSource source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4) // Convert image to RGBA format
              .getBytes(
                  order: img.ChannelOrder.abgr) // Get byte array in ABGR order
              .buffer
              .asInt32List(),
        );

        // Create a binary bitmap from the luminance source for QR code processing.
        var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

        // Initialize the QR code reader.
        var reader = QRCodeReader();

        // Decode the QR code from the bitmap and return the result text.
        var result = reader.decode(bitmap);
        return result.text;
      } else {
        // Log a message if the image could not be decoded.
        debugPrint(
            'Error: Image decoding failed. The input data may not be a valid image.');
        return null;
      }
    } catch (e) {
      // Log the exception details for debugging purposes.
      debugPrint('Exception during QR code decoding: $e');
      return null;
    }
  }
}
