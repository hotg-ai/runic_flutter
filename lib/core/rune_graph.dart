import 'dart:convert';

import 'dart:typed_data';

class RuneGraph {
  bool parsed = false;
  final Uint8List bytes;
  dynamic json;
  List<int> runeGraphBytes = utf8.encode("rune_graph");
  List<int> openBytes = utf8.encode("{");
  List<int> closeBytes = utf8.encode("}");

  String runeName = "Unnamed rune";
  List<Capability> capabilities = [];
  List<Model> models = [];
  List<ProcBlock> procBlocks = [];
  List<Output> outputs = [];
  Map<String, Tensor> tensors = {};

  RuneGraph(this.bytes) {
    parsed = false;
    if (bytes.length > 1000 * 1000 * 50) {
      return;
    }

    for (int i = 0; i < bytes.length; i++) {
      if (parsed == false && i + runeGraphBytes.length < bytes.length) {
        int match = 0;
        for (int c = 0; c < runeGraphBytes.length; c++) {
          if (bytes[i + c] == runeGraphBytes[c]) {
            match++;
          }
        }
        if (match == runeGraphBytes.length) {
          int e = i + runeGraphBytes.length;
          int endPos = 0;
          int level = 0;
          while (e < bytes.length && level >= 0) {
            int matchOpen = 0;
            for (int s = 0; s < openBytes.length; s++) {
              if (bytes[e + s] == openBytes[s]) {
                matchOpen++;
              }
            }
            if (matchOpen == openBytes.length) {
              level++;
            }
            int matchClose = 0;
            for (int s = 0; s < closeBytes.length; s++) {
              if (bytes[e + s] == closeBytes[s]) {
                matchClose++;
              }
            }
            if (matchClose == closeBytes.length) {
              level--;
            }

            if (level == 0) {
              level = -1;
              endPos = e + closeBytes.length;
            }
            e++;
          }
          try {
            String s = new String.fromCharCodes(
                bytes.sublist(i + runeGraphBytes.length, endPos));
            print(s);
            print(s.length);

            json = jsonDecode(s);

            parsed = true;
          } on FormatException catch (e) {
            print('error ${e.toString()}');
          }
        }
      }
    }

    if (json != null) {
      populate(json);
    }
  }
  populate(dynamic json) {
    dynamic rune = parse(json, "rune");
    if (rune != null) {
      runeName = parse(json["rune"], "name");
    }
    dynamic capabilitiesObject = parse(json, "capabilities");
    if (capabilitiesObject != null) {
      for (String key in capabilitiesObject.keys) {
        Capability cap = new Capability();
        cap.name = key;
        cap.kind = parse(capabilitiesObject[key], "kind");
        cap.args = parse(capabilitiesObject[key], "args");
        cap.outputs =
            List<String>.from(parse(capabilitiesObject[key], "outputs"));
        capabilities.add(cap);
      }
    }
    dynamic modelsObject = parse(json, "models");
    if (modelsObject != null) {
      for (String key in modelsObject.keys) {
        Model model = new Model();
        model.name = key;
        model.file = parse(modelsObject[key], "file");
        model.inputs = List<String>.from(parse(modelsObject[key], "inputs"));
        model.outputs = List<String>.from(parse(modelsObject[key], "outputs"));
        models.add(model);
      }
    }
    dynamic procBlocksObject = parse(json, "proc-blocks");
    if (procBlocksObject != null) {
      for (String key in procBlocksObject.keys) {
        ProcBlock procBlock = new ProcBlock();
        procBlock.name = key;
        procBlock.path = parse(procBlocksObject[key], "path");
        procBlock.args = parse(procBlocksObject[key], "args");
        procBlock.inputs =
            List<String>.from(parse(procBlocksObject[key], "inputs"));
        procBlock.outputs =
            List<String>.from(parse(procBlocksObject[key], "outputs"));
        procBlocks.add(procBlock);
      }
    }
    dynamic outputsObject = parse(json, "outputs");
    if (outputsObject != null) {
      for (String key in outputsObject.keys) {
        Output output = new Output();
        output.name = key;
        output.kind = parse(outputsObject[key], "kind");
        output.inputs = List<String>.from(parse(outputsObject[key], "inputs"));
        outputs.add(output);
      }
    }
    dynamic tensorObject = parse(json, "tensors");
    if (tensorObject != null) {
      print(tensorObject);
      for (String key in tensorObject.keys) {
        Tensor tensor = new Tensor();
        tensor.name = key;
        tensor.elementType =
            parse(tensorObject[key], "element_type").toString();
        tensor.dimensions = parse(tensorObject[key], "dimensions");
        tensors[key] = tensor;
      }
    }
  }

  dynamic parse(dynamic data, String key) {
    if (data.containsKey(key)) {
      return data[key];
    }
    return null;
  }
}

class Capability {
  String? name;
  dynamic kind;
  Map<String, dynamic>? args;
  List<String>? inputs;
  List<String>? outputs;
}

class Model {
  String? name;
  String? file;
  List<String>? inputs;
  List<String>? outputs;
}

class ProcBlock {
  String? name;
  String? path;
  Map<String, dynamic>? args;
  List<String>? inputs;
  List<String>? outputs;
}

class Output {
  String? name;
  dynamic kind;
  List<String>? inputs;
  List<String>? outputs;
}

class Tensor {
  String? name;
  String? elementType;
  List<dynamic>? dimensions;
}
