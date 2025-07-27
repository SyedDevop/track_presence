import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

imglib.Image convertToImage(CameraImage image) {
  try {
    print('[Info] image.format.group=> ${image.format.group}');
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.nv21) {
      return nv21ToRgb(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    print("ERROR:$e");
  }
  throw Exception('Image format not supported');
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
    format: imglib.Format.uint8,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width: width, height: height);
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.setPixelRgb(x, y, r, g, b);
    }
  }

  return img;
}

imglib.Image nv21ToRgb(CameraImage image) {
  int width = image.width;
  int height = image.height;
  int frameSize = width * height;
  var img = imglib.Image(width: width, height: height); // RGB output

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      // Y plane (first width*height bytes)
      int yIndex = y * width + x;
      int Y = image.planes[0].bytes[yIndex] & 0xFF; // Y component

      // UV plane (after the Y plane, interleaved UV)
      int uvIndex = frameSize + (y >> 1) * width + (x & ~1);
      int V = image.planes[0].bytes[uvIndex] & 0xFF; // V component
      int U = image.planes[0].bytes[uvIndex + 1] & 0xFF; // U component

      // Adjust U and V
      U -= 128;
      V -= 128;

      // YUV to RGB conversion
      int R = (Y + 1.402 * V).round().clamp(0, 255);
      int G = (Y - 0.344136 * U - 0.714136 * V).round().clamp(0, 255);
      int B = (Y + 1.772 * U).round().clamp(0, 255);
      img.setPixelRgba(x, y, R, G, B, 255);
    }
  }

  return img;
}
