import 'dart:convert';
import 'dart:typed_data';

const CapabilitiesIds = {
  "RandCapability": 1,
  "AudioCapability": 2,
  "AccelCapability": 3,
  "ImageCapability": 4,
  "RawCapability": 5
};

class RawCap {
  int type = CapabilitiesIds["RawCapability"]!;
  Uint8List? raw;
  dynamic parameters;

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
      if (raw!.length > parameters["length"]) {
        bytesBuilder.add(raw!.sublist(0, parameters["length"]));
      } else {
        bytesBuilder.add(raw!);
        while (bytesBuilder.length < parameters["length"]) {
          bytesBuilder.addByte(0);
        }
      }
      raw = bytesBuilder.toBytes();
      print(raw);
    }
  }
}
