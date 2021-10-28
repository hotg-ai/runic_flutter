import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as ImageLib;

class ImageUtils {
  static List<Uint8List> processCameraImage(
      CameraImage image, Map<String, dynamic> parameters) {
    return Platform.isAndroid
        ? processCameraImageAndroid(image, parameters)
        : processCameraImageIOS(image, parameters);
  }

  static List<Uint8List> processCameraImageAndroid(
      CameraImage image, Map<String, dynamic> parameters) {
    int width = image.width;
    int height = image.height;
    final img = ImageLib.Image(width, height); // Create Image buffer

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
    final thumbnail = ImageLib.copyResizeCropSquare(img, parameters["width"]);
    List<int> thumb = ImageLib.writePng(thumbnail);
    //final thumbnail =
    //    imglib.grayscale(imglib.copyResize(img, width: 96, height: 96));

    final p = thumbnail.getBytes();
    List<int> theBytes = [];
    if (parameters["pixel_format"] != 2) {
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
    } else {
      for (int c = 0; c < p.length; c += 4) {
        theBytes.add(((p[c] + p[c + 1] + p[c + 2]) / 3).round());
      }
    }
    return [Uint8List.fromList(theBytes), new Uint8List.fromList(thumb)];
  }

  static List<Uint8List> processCameraImageIOS(
      CameraImage image, Map<String, dynamic> parameters) {
    int width = image.width;
    int height = image.height;
    final img = ImageLib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: ImageLib.Format.bgra,
    ); // Create Image buffer

    // rsize/crop/grayscale
    final thumbnail = ImageLib.copyResizeCropSquare(img, parameters["width"]);
    List<int> thumb = ImageLib.writePng(thumbnail);
    //final thumbnail =
    //    imglib.grayscale(imglib.copyResize(img, width: 96, height: 96));

    final p = thumbnail.getBytes();
    List<int> theBytes = [];
    if (parameters["pixel_format"] != 2) {
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
    } else {
      for (int c = 0; c < p.length; c += 4) {
        theBytes.add(((p[c] + p[c + 1] + p[c + 2]) / 3).round());
      }
    }
    print("length of bvytes: ${theBytes.length}");
    return [Uint8List.fromList(theBytes), new Uint8List.fromList(thumb)];
  }

  static List<Uint8List> convertImage(
      Uint8List data, Map<String, dynamic> parameters) {
    ImageLib.Image decodedImage = ImageLib.copyResizeCropSquare(
        ImageLib.decodeImage(data)!, parameters["width"]);

    List<int> thumb = ImageLib.writePng(decodedImage);

    //remove alpha channel & int to float
    List<int> input = [];
    int c = 0;
    if (parameters["pixel_format"] == 2) {
      Uint8List bytes = decodedImage.getBytes();
      for (int c = 0; c < bytes.lengthInBytes; c += 4) {
        input.add(((bytes[c] + bytes[c + 1] + bytes[c + 2]) / 3).round());
      }
    } else {
      for (int b in decodedImage.getBytes()) {
        c++;
        if (c % 4 != 0) {
          input.add(b);
        }
      }
    }

    return [new Uint8List.fromList(input), new Uint8List.fromList(thumb)];
  }

  static Uint8List bytesRGBtoPNG(List bytes) {
    int size = sqrt(bytes.length / 3).round();
    final outImage = ImageLib.Image(size, size);
    for (var i = 0; i < bytes.length; i += 3) {
      int pos = (i / 3).round();
      List<double> pixel = [
        bytes[i].clamp(0.0, 1.0),
        bytes[i + 1].clamp(0.0, 1.0),
        bytes[i + 2].clamp(0.0, 1.0)
      ];
      outImage.data[pos] = Uint32List.view(new Uint8List.fromList([
        (pixel[0] * 255).round(),
        (pixel[1] * 255).round(),
        (pixel[2] * 255).round(),
        255
      ]).buffer)[0];
    }
    return Uint8List.fromList(ImageLib.encodePng(outImage));
  }
}
