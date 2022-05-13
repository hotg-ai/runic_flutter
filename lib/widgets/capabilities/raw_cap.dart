import 'dart:convert';
import 'dart:typed_data';

import 'package:runevm_fl/runevm_fl.dart';

const CapabilitiesIds = {
  "RandCapability": 1,
  "AudioCapability": 2,
  "AccelCapability": 3,
  "ImageCapability": 4,
  "RawCapability": 5
};

class RawCap {
  int type = CapabilitiesIds["RawCapability"]!;

  dynamic parameters;
  Tensor inputTensor = new Tensor(Uint8List(0), [], TensorType.U8, 0);

  static String dataToString(Uint8List raw, String type) {
    try {
      if (type == "UTF8") {
        return utf8.decode(raw);
      }
      if (type == "ASCII") {
        return ascii.decode(raw);
      }
      if (type == "U8") {
        return raw.toString();
      }
      if (type == "F32") {
        return Float32List.view(raw.buffer).toString();
      }
    } catch (e) {
      return "Error parsing data $e";
    }
    return "Error parsing data to string";
  }

  static Uint8List stringToData(String text, String type) {
    try {
      if (type == "UTF8") {
        return Uint8List.fromList(utf8.encode(text));
      }
      if (type == "ASCII") {
        return Uint8List.fromList(ascii.encode(text));
      }
      if (type == "U8") {
        return Uint8List.fromList(List<int>.from(jsonDecode(text)));
      }
      if (type == "F32") {
        return Uint8List.view(
            Float32List.fromList(List<double>.from(jsonDecode(text))).buffer);
      }
    } catch (e) {
      return Uint8List(0);
    }
    return Uint8List(0);
  }

  prepData() {
    if (!parameters.containsKey("length")) {
      parameters["length"] = 100;
    }
    if (type == CapabilitiesIds["RawCapability"]) {
      final bytesBuilder = BytesBuilder();
      if (inputTensor.bytes!.length > parameters["length"]) {
        bytesBuilder.add(inputTensor.bytes!.sublist(0, parameters["length"]));
      } else {
        bytesBuilder.add(inputTensor.bytes!);
        while (bytesBuilder.length < parameters["length"]) {
          bytesBuilder.addByte(0);
        }
      }
      inputTensor.bytes = bytesBuilder.toBytes();
    }
  }
}
