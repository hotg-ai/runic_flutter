import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
  static String? url;
  static load() async {
    RuneEngine.output = {"type": "none", "output": "-"};
    //Rune
    await RunevmFl.load(RuneEngine.runeBytes);
    manifest = await RunevmFl.manifest;
    capabilities = [];
    print(manifest);
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
        dynamic out = json.decode(RuneEngine.output["output"]);
        print(out);
        if (out.containsKey("elements")) {
          if (out["elements"].length > 100) {
            RuneEngine.output["type"] = "Image";
            RuneEngine.output["output"] =
                ImageUtils.bytesRGBtoPNG(out["elements"]);
          } else {
            RuneEngine.output["output"] =
                "${json.decode(RuneEngine.output["output"])["elements"]}";
          }
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
