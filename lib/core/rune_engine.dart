import 'dart:convert';
import 'dart:typed_data';

import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';

class RuneEngine {
  static Uint8List runeBytes = new Uint8List(0);
  static dynamic runeMeta = {};
  static Map<String, dynamic> output = {"type": "none", "output": "-"};
  //Rune
  static List<dynamic> manifest = [];
  static List<ImageCap> capabilities = [];

  static load() async {
    await RunevmFl.load(RuneEngine.runeBytes);
    manifest = jsonDecode(await RunevmFl.manifest);
    capabilities = [];
    for (dynamic _cap in manifest) {
      ImageCap imageCap = new ImageCap();
      imageCap.parameters = _cap;
      capabilities.add(imageCap);
    }
  }

  static Future<Map<String, dynamic>> run() async {
    List<int> lengths = [];
    var bytes = BytesBuilder();
    for (ImageCap cap in capabilities) {
      lengths.add(cap.raw!.length);

      bytes.add(cap.raw!);
    }
    dynamic runeOutput = await RunevmFl.runRune(bytes.toBytes(), lengths);
    RuneEngine.output = {
      "type": "String",
      "output": "no valid output type detected"
    };
    if (runeOutput is String) {
      RuneEngine.output = {"type": "String", "output": "$runeOutput"};
      if (RuneEngine.output["type"] == "String") {
        if (json.decode(RuneEngine.output["output"]).containsKey("elements")) {
          RuneEngine.output["output"] =
              "${json.decode(RuneEngine.output["output"])["elements"]}";
        }
      }
    } else if (runeOutput is List) {
      RuneEngine.output = {
        "type": "Image",
        "output": ImageUtils.bytesRGBtoPNG(runeOutput)
      };
    }
    return RuneEngine.output;
  }
}
