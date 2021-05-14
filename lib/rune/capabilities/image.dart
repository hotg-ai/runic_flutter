import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

const shift = (0xFF << 24);

class ImageCapability {
  Uint8List? processCameraImage(CameraImage image) {
    return Platform.isAndroid
        ? processCameraImageAndroid(image)
        : processCameraImageIOS(image);
  }

  Uint8List? processCameraImageAndroid(CameraImage image) {
    int width = image.width;
    int height = image.height;
    final img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int index = y * width + x;
        final pixelColor = image.planes[0].bytes[index];
        img.data[y * width + x] =
            (0xFF << 24) | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
      }
    }

    // rsize/crop/grayscale
    final thumbnail = imglib.copyResizeCropSquare(img, 224);
    //final thumbnail =
    //    imglib.grayscale(imglib.copyResize(img, width: 96, height: 96));

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
    int width = image.width;
    int height = image.height;
    final img = imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    ); // Create Image buffer

    // rsize/crop/grayscale
    final thumbnail = imglib.copyResizeCropSquare(img, 224);
    //final thumbnail =
    //    imglib.grayscale(imglib.copyResize(img, width: 96, height: 96));

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

  Uint8List processCameraImageIOS_person(CameraImage image) {
    int width = image.width;
    int height = image.height;
    final img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        //final int uvIndex =
        //    uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final r = image.planes[0].bytes[index * 4 + 1];
        final g = image.planes[0].bytes[index * 4 + 2];
        final b = image.planes[0].bytes[index * 4];
        img.data[index] = shift | (b << 16) | (g << 8) | r;
      }
    }

    // rsize/crop/grayscale
    final thumbnail = imglib.grayscale(imglib.copyResizeCropSquare(img, 96));
    //final thumbnail =
    //    imglib.grayscale(imglib.copyResize(img, width: 96, height: 96));

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
}
