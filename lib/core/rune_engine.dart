import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';

class RuneEngine {
  static double executionTime = 0.0;
  static Uint8List runeBytes = new Uint8List(0);
  static dynamic runeMeta = {};
  static Map<String, dynamic> output = {"type": "none", "output": "-"};
  //Rune
  static List<dynamic> manifest = [];
  static List<ImageCap> capabilities = [];
  static List<dynamic> objects = [];
  static String? url;
  static load() async {
    RuneEngine.executionTime = 0.0;
    RuneEngine.output = {"type": "none", "output": "-"};
    print("RunevmFl.load ${RuneEngine.runeBytes.length}");
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
    HFAuth.addToHistory("${runeMeta["name"]} deployed");
  }

  static Future<Map<String, dynamic>> run() async {
    //RuneEngine.executionTime = 0.0;
    List<int> lengths = [];
    var bytes = BytesBuilder();
    for (ImageCap cap in capabilities) {
      lengths.add(cap.raw!.length);

      bytes.add(cap.raw!);
    }
    int start = DateTime.now().microsecondsSinceEpoch;
    dynamic runeOutput = await RunevmFl.runRune(bytes.toBytes(), lengths);
    int time = DateTime.now().microsecondsSinceEpoch - start;
    executionTime = time * 0.001;
    HFAuth.addToHistory(
        "${runeMeta["name"]} executed in ${executionTime.round()} ms");
    RuneEngine.output = {
      "type": "String",
      "output": "no valid output type detected"
    };
    List<String> names = [
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic light',
      'fire hydrant',
      'stop sign',
      'parking meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports ball',
      'kite',
      'baseball bat',
      'baseball glove',
      'skateboard',
      'surfboard',
      'tennis racket',
      'bottle',
      'wine glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted plant',
      'bed',
      'dining table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy bear',
      'hair drier',
      'toothbrush'
    ];
    print(runeOutput);

    if (runeOutput is String) {
      RuneEngine.output = {"type": "String", "output": "$runeOutput"};
      if (RuneEngine.output["type"] == "String") {
        dynamic out = {};
        if (RuneEngine.output["output"] == "error") {
          out = {"elements": []};
        } else {
          out = json.decode(RuneEngine.output["output"]);
        }

        if (out.containsKey("elements")) {
          List<dynamic> outList = out["elements"];
          if (runeMeta["name"] == "hotg-ai/yolo_v5") {
            print("out[elements].length ${out["elements"].length}");
            RuneEngine.objects = [];
            for (int i = 0; i < outList.length; i += 6) {
              double confidence = outList[i + 4];
              objects.add({
                "conf": confidence,
                "name": names[(outList[i + 5]).round()],
                "x": outList[i],
                "y": outList[i + 1],
                "w": outList[i + 2],
                "h": outList[i + 3]
              });
            }
            RuneEngine.output["type"] = "Objects";
            RuneEngine.output["output"] = objects;
          } else if (out["elements"].length > 100) {
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
      if (runeMeta["name"] == "hotg-ai/yolo_v5") {
        RuneEngine.objects = [];
        for (int i = 0; i < runeOutput.length; i += 6) {
          double confidence = runeOutput[i + 4];
          objects.add({
            "conf": confidence,
            "name": names[(runeOutput[i + 5]).round()],
            "x": runeOutput[i],
            "y": runeOutput[i + 1],
            "w": runeOutput[i + 2],
            "h": runeOutput[i + 3]
          });
        }
        RuneEngine.output["type"] = "Objects";
        RuneEngine.output["output"] = objects;
      } else {
        RuneEngine.output = {
          "type": "Image",
          "output": ImageUtils.bytesRGBtoPNG(runeOutput)
        };
      }
    }
    return RuneEngine.output;
  }
}
