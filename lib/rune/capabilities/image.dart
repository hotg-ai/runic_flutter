import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

const shift = (0xFF << 24);

const ImageFormat = {0: "RGB", 1: "BGR", 2: "YUV", 3: "Grayscale"};

class ImageCapability {
  final int width;
  final int height;
  final int format;

  ImageCapability({this.width = 224, this.height = 224, this.format = 0}) {
    print("Created ImageCapability [$width,$height,${ImageFormat[format]}]");
  }

  Uint8List? processCameraImage(CameraImage image) {
    return Platform.isAndroid
        ? processCameraImageAndroid(image)
        : processCameraImageIOS(image);
  }

  Uint8List? processCameraImageAndroid(CameraImage image) {
    int imgWidth = image.width;
    int imgHeight = image.height;
    final img = imglib.Image(imgWidth, imgHeight); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < imgWidth; x++) {
      for (int y = 0; y < imgHeight; y++) {
        final int index = y * imgWidth + x;
        final pixelColor = image.planes[0].bytes[index];
        img.data[y * imgWidth + x] =
            (0xFF << 24) | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
      }
    }

    return reFormat(img);
  }

  Uint8List reFormat(imglib.Image img) {
    imglib.Image thumbnail = imglib.copyResizeCropSquare(img, width);
    if (format == 3) {
      thumbnail = imglib.grayscale(thumbnail);
      final p = thumbnail.getBytes();
      List<int> theBytes = [];
      for (var i = 0; i < p.length; i += 4) {
        int pos = (i / 4).round();
        if (theBytes.length > pos) {
          theBytes[pos] = p[i];
        } else {
          theBytes.add(p[i]);
        }
      }
      return Uint8List.fromList(theBytes);
    }
    if (format == 1) {
      final p = thumbnail.getBytes();
      List<int> theBytes = [];
      for (var i = 0; i < p.length; i += 4) {
        int pos = (i / 4).round();
        if (theBytes.length > pos * 3) {
          theBytes[pos * 3] = p[i];
          theBytes[pos * 3 + 1] = p[i + 1];
          theBytes[pos * 3 + 2] = p[i + 2];
        } else {
          theBytes.add(p[i + 2]);
          theBytes.add(p[i + 1]);
          theBytes.add(p[i + 0]);
        }
      }
      return Uint8List.fromList(theBytes);
    }
    final p = thumbnail.getBytes();
    List<int> theBytes = [];
    for (var i = 0; i < p.length; i += 4) {
      int pos = (i / 4).round();
      if (theBytes.length > pos * 3) {
        theBytes[pos * 3] = p[i];
        theBytes[pos * 3 + 1] = p[i + 1];
        theBytes[pos * 3 + 2] = p[i + 2];
      } else {
        theBytes.add(p[i]);
        theBytes.add(p[i + 1]);
        theBytes.add(p[i + 2]);
      }
    }
    return Uint8List.fromList(theBytes);
  }

  Uint8List processCameraImageIOS(CameraImage image) {
    final img = imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    ); // Create Image buffer

    // rsize/crop/grayscale
    return reFormat(img);
  }
}
