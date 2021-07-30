import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';

const shift = (0xFF << 24);

const ImageFormat = {0: "RGB", 1: "BGR", 2: "YUV", 3: "Grayscale"};

class ImageCapability {
  final int width;
  final int height;
  final int format;
  imglib.Image? thumb;
  CameraImage? image;
  ImageCapability({this.width = 224, this.height = 224, this.format = 0}) {
    print("Created ImageCapability [$width,$height,${ImageFormat[format]}]");
  }

  Uint8List? processCameraImage(CameraImage image, int rotation) {
    return Platform.isAndroid
        ? processCameraImageAndroid(image, rotation)
        : processCameraImageIOS(image, rotation);
  }

  Uint8List? processLibLibrary(Uint8List imageBytes) {
    final img = imglib.decodeImage((imageBytes).toList());
    print("${img.width} ${img.height}");
    return reFormat(img);
  }

  Future<Uint8List>? processCameraImageFromLibrary(
      PickedFile image, int rotation) async {
    final img = imglib.decodeImage((await image.readAsBytes()).toList());
    print("${img.width} ${img.height}");
    imglib.Image thumbnail = imglib.copyResizeCropSquare(img, width);
    print("${thumbnail.width} ${thumbnail.height}");
    return Uint8List.fromList(
        imglib.encodePng(imglib.copyRotate(thumbnail, rotation)));
  }

  Uint8List? bytesRGBtoPNG(List<int> bytes) {
    final img = imglib.Image(width, height);

    imglib.Image outImage = imglib.copyResizeCropSquare(img, width);
    for (var i = 0; i < bytes.length; i += 3) {
      int pos = (i / 3).round();
      outImage.data[pos] = Uint32List.view(
          new Uint8List.fromList([bytes[i], bytes[i + 1], bytes[i + 2], 255])
              .buffer)[0];
    }
    return Uint8List.fromList(imglib.encodePng(outImage));
  }

  Uint8List? processCameraImageAndroid(CameraImage image, int rotation) {
    int imgWidth = image.width;
    int imgHeight = image.height;
    final img = imglib.Image(imgWidth, imgHeight); // Create Image buffer
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < imgWidth; x++) {
      for (int y = 0; y < imgHeight; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * imgWidth + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = shift | (b << 16) | (g << 8) | r;
      }
    }

    return reFormat(imglib.copyRotate(img, rotation));
  }

  Uint8List getThumb() {
    if (thumb != null) {
      return Uint8List.fromList(imglib.encodePng(thumb));
    }
    return Uint8List.fromList([]);
  }

  Uint8List reFormat(imglib.Image img) {
    imglib.Image thumbnail = imglib.copyResizeCropSquare(img, width);
    if (format >= 2) {
      thumbnail = imglib.grayscale(thumbnail);
      thumb = thumbnail;
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
      thumb = thumbnail;
      List<int> theBytes = [];
      for (var i = 0; i < p.length; i += 4) {
        int pos = (i / 4).round();
        if (theBytes.length > pos * 3) {
          theBytes[pos * 3] = p[i + 2];
          theBytes[pos * 3 + 1] = p[i + 1];
          theBytes[pos * 3 + 2] = p[i];
        } else {
          theBytes.add(p[i + 2]);
          theBytes.add(p[i + 1]);
          theBytes.add(p[i + 0]);
        }
      }
      return Uint8List.fromList(theBytes);
    }
    final p = thumbnail.getBytes();
    thumb = thumbnail;

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

  Uint8List processCameraImageIOS(CameraImage image, int rotation) {
    final img = imglib.Image.fromBytes(
      image.width,
      image.height,
      image.planes[0].bytes,
      format: imglib.Format.bgra,
    ); // Create Image buffer

    // rsize/crop/grayscale
    return reFormat(imglib.copyRotate(img, rotation));
  }
}
