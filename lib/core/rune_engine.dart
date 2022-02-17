import 'dart:convert';

import 'dart:typed_data';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/core/analytics.dart';
import 'package:runic_flutter/core/logs.dart';
import 'package:runic_flutter/core/rune_graph.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/capabilities/audio_cap.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';
import 'package:runic_flutter/widgets/capabilities/rand_cap.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:runic_flutter/widgets/capabilities/accel_cap.dart';

class RuneEngine {
  static double executionTime = 0.0;
  static Uint8List runeBytes = new Uint8List(0);
  static RuneGraph? runeGraph;
  static Map<String, dynamic> runeMeta = {};
  static Map<String, dynamic> output = {"type": "none", "output": "-"};
  //Rune
  static List<dynamic> manifest = [];
  static List<RawCap> capabilities = [];
  static List<dynamic> objects = [];
  static List<dynamic> logs = [];
  static String? url;

  static Future<List<dynamic>> getLogs() async {
    dynamic logs = await RunevmFl.getLogs();
    return logs;
  }

  static bool isYoloModel() {
    if (runeGraph != null) {
      if (runeGraph!.parsed) {
        if (runeGraph!.json.containsKey("models")) {
          if (runeGraph!.json["models"].containsKey("yolo")) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static getMeta(Uint8List bytes) {
    //parse the runeGraph from raw bytes
    runeGraph = new RuneGraph(bytes);
    RuneEngine.runeMeta["name"] = runeGraph?.runeName;
  }

  static load() async {
    RuneEngine.executionTime = 0.0;
    RuneEngine.output = {"type": "none", "output": "-"};
    print("RunevmFl.load ${RuneEngine.runeBytes.length}");
    //Rune
    getMeta(RuneEngine.runeBytes);
    Logs.sendTelemetryToSocket({"type": "rune/load/started"});
    int startTime = DateTime.now().millisecondsSinceEpoch;
    try {
      await RunevmFl.load(RuneEngine.runeBytes);
    } catch (e) {
      int totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
      Logs.sendTelemetryToSocket({
        "type": "rune/load/failed",
        "error": e.toString(),
        "message": e.toString(),
        "milliseconds": totalTime.toString(),
      });
    }
    int totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
    Logs.sendTelemetryToSocket({
      "type": "rune/load/succeeded",
      "milliseconds": totalTime.toString(),
    });
    manifest = await RunevmFl.manifest;
    capabilities = [];
    print(manifest);

    for (dynamic cap in manifest) {
      print(cap);
      if (cap["type"] == "ImageCapability") {
        ImageCap imageCap = new ImageCap();
        imageCap.parameters = cap;
        capabilities.add(imageCap);
      } else if (cap["type"] == "RawCapability") {
        RawCap rawCap = new RawCap();
        rawCap.parameters = cap;
        capabilities.add(rawCap);
      } else if (cap["type"] == "RandCapability") {
        RandCap randCap = new RandCap();
        randCap.parameters = cap;
        capabilities.add(randCap);
      } else if (cap["type"] == "AccelCapability") {
        AccelCap accelCap = new AccelCap(
            cap.containsKey("sample_count") ? cap["sample_count"] : 1000);
        accelCap.parameters = cap;
        capabilities.add(accelCap);
      } else if (cap["type"] == "AudioCapability") {
        AudioCap audioCap = new AudioCap(
            hz: cap.containsKey("hz") ? cap["hz"] : 16000,
            ms: cap.containsKey("sample_duration_ms")
                ? cap["sample_duration_ms"]
                : 1000);
        audioCap.parameters = cap;
        capabilities.add(audioCap);
      }
    }
    Logs.sendLogs();
    Analytics.addToHistory("${runeMeta["name"]} deployed");
  }

  static Future<Map<String, dynamic>> run() async {
    try {
      //RuneEngine.executionTime = 0.0;
      List<int> lengths = [];
      var bytes = BytesBuilder();
      for (RawCap cap in capabilities) {
        cap.prepData();
        lengths.add(cap.raw!.length);
        print("Bytes added ${cap.raw!.length}");
        bytes.add(cap.raw!);
      }

      print("Bytes total ${bytes.length}");
      int start = DateTime.now().microsecondsSinceEpoch;
      Logs.sendTelemetryToSocket({"type": "rune/predict/started"});

      dynamic runeOutput = await RunevmFl.runRune(bytes.toBytes(), lengths);
      int time = DateTime.now().microsecondsSinceEpoch - start;
      if (runeOutput is String) {
        if (runeOutput.toLowerCase() == "error") {
          Logs.sendTelemetryToSocket({
            "type": "rune/predict/failed",
            "error": "error",
            "message": "error",
            "milliseconds": time.toString(),
          });
        } else {
          Logs.sendTelemetryToSocket({
            "type": "rune/predict/succeeded",
            "milliseconds": time.toString(),
          });
        }
      } else {}

      executionTime = time * 0.001;
      print("output generated");
      Analytics.addToHistory(
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

      if (runeOutput is String) {
        RuneEngine.output = {"type": "String", "output": runeOutput};
        if (RuneEngine.output["type"] == "String") {
          dynamic out = {};
          if (RuneEngine.output["output"] == "error") {
            out = {"elements": []};
          } else {
            out = json.decode(runeOutput);
          }
          if (out is List) {
            if (out.length == 2) {
              if (out[0].containsKey("elements") &&
                  out[1].containsKey("elements") &&
                  out[0]["type_name"] == "utf8") {
                RuneEngine.output["type"] = "Image";
                RuneEngine.output["output"] = ImageUtils.objectImage(
                    out[1]["elements"], out[0]["elements"]);
                RuneEngine.output["elements"] = out[0]["elements"];
                return RuneEngine.output;
                //image rec
              }
            }
          } else if (out.containsKey("elements")) {
            List<dynamic> outList = out["elements"];
            if (isYoloModel()) {
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
            } else if (out["elements"].length > 5000) {
              RuneEngine.output["type"] = "Image";
              RuneEngine.output["output"] =
                  ImageUtils.bytesRGBtoPNG(out["elements"]);
            } else {
              RuneEngine.output["output"] =
                  "${json.decode(RuneEngine.output["output"])["elements"]}";
              RuneEngine.output["output"] =
                  (RuneEngine.output["output"].length < 1001)
                      ? RuneEngine.output["output"]
                      : RuneEngine.output["output"].substring(0, 1000);
            }
          }
        }
      } else if (runeOutput is List) {
        if (isYoloModel()) {
          print("isYoloModel");
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
      Logs.sendLogs();
      return RuneEngine.output;
    } catch (e) {
      RuneEngine.output = {"type": "Error", "output": "Error ${e.toString()}"};
      Logs.sendLogs();
      return RuneEngine.output;
    }
  }
}
