import 'package:runic_flutter/core/rune_graph.dart';

class YoloModel {
  static bool isYoloModel(RuneGraph? runeGraph) {
    print("#####isYoloModel ${runeGraph!.outputs}");
    if (runeGraph != null) {
      if (runeGraph.parsed) {
        if (runeGraph.runeName.toLowerCase().contains("yolo")) {
          return true;
        }
        if (runeGraph.json.containsKey("models")) {
          if (runeGraph.json["models"].containsKey("yolo")) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static List<dynamic> getObjects(List<dynamic> outList) {
    List<dynamic> objects = [];
    for (int i = 0; i < outList.length; i += 6) {
      double confidence = outList[i + 4];
      objects.add({
        "conf": confidence,
        "name": YoloModel.names[(outList[i + 5]).round()],
        "x": outList[i],
        "y": outList[i + 1],
        "w": outList[i + 2],
        "h": outList[i + 3]
      });
    }
    return objects;
  }

  static List<String> names = [
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
}
