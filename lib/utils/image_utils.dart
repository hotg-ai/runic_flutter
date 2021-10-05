import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as ImageLib;

class ImageUtils {
  static Uint8List convertImage(
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

    return new Uint8List.fromList(input);
  }

  static Uint8List bytesRGBtoPNG(List bytes) {
    int size = sqrt(bytes.length / 3).round();
    print("image output size $size");
    print("${bytes.sublist(0, 10)}");
    final outImage = ImageLib.Image(size, size);
    for (var i = 0; i < bytes.length; i += 3) {
      int pos = (i / 3).round();

      outImage.data[pos] = Uint32List.view(new Uint8List.fromList([
        (bytes[i] * 255).round(),
        (bytes[i + 1] * 255).round(),
        (bytes[i + 2] * 255).round(),
        255
      ]).buffer)[0];
    }
    return Uint8List.fromList(ImageLib.encodePng(outImage));
  }
}
