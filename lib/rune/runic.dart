import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'dart:convert' show utf8;

const capabilitiesDefinition = {
  "1": "hmr::CAPABILITY::RAND",
  "2": "hmr::CAPABILITY::AUDIO",
  "3": "hmr::CAPABILITY::ACCEL",
  "4": "hmr::CAPABILITY::IMAGE",
  "5": "hmr::CAPABILITY::RAW"
};

const outputsDefinition = {
  "SERIAL": "hmr::OUTPUT::SERIAL",
  "BLE": "hmr::OUPTPUT::BLE"
};

class Runic {
  static dynamic inputData;
  static List<dynamic> runes = [
    {
      "name": "hotg-ai/sine",
      "description": "Sine prediction rune from random input"
    },
  ];

  static Future<void> fetchRegistry() async {
    final url = Uri.parse("https://rune-registry.web.app/registry/runes.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      runes = List<dynamic>.from(jsonDecode(response.body));
      //only show the ones with display == true;
      runes = runes.where((element) => element["display"] == true).toList();
      print("Rune registry loaded:\n$runes");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load registry');
    }
  }

  List<Map<String, Object>>? output;
  Map capabilities = {};
  Map parameters = {};
  String? modelOutput;
  String rawOutput = "";
  int wasmSize = 0;
  bool loading = false;

  Future<void> deployWASM(
      String name, String version, Function setState) async {
    //download
    loading = true;
    setState();
    String fileName = "${name.replaceAll("/", "-")}-$version.rune";
    final directory = await getTemporaryDirectory();
    String fileURL = "${directory.path}/$fileName";
    print(">>>>$fileURL");
    Uint8List wasmBytes = await downloadWASM(
        'https://rune-registry.web.app/registry/' + name + '/app.rune');
    await RunevmFl.load(wasmBytes);
    wasmSize = wasmBytes.length;
    loading = false;
    setState();
  }

  Future<void> deployWASMFromURL(String urlString, Function setState) async {
    //download
    loading = true;
    setState();
    Uint8List wasmBytes = await downloadWASM('$urlString');
    await RunevmFl.load(wasmBytes);
    wasmSize = wasmBytes.length;
    loading = false;
    setState();
  }

  Future<Uint8List> downloadWASM(String urlString) async {
    runTimes = [];
    final url = Uri.parse(urlString);
    final client = http.Client();
    final request = http.Request('GET', url);
    final response = await client.send(request);
    final stream = response.stream;
    List<int> wasmBytes = [];
    await for (var data in stream) {
      wasmBytes.addAll(data);
    }
    client.close();
    elements = [];
    output = [];
    return Uint8List.fromList(wasmBytes);
  }

  int millisecondsPerRun = 0;
  List<int> runTimes = [];
  Future<void> runRune({dynamic inputBytes}) async {
    if (inputBytes == null) {
      inputBytes = Runic.inputData;
    }
    //no data ready for model, feeding empty array
    if (inputBytes == null) {
      inputBytes = new Uint8List.fromList([]);
    }
    double input = 0;

    if (capabilities.containsKey("5")) {
      //if input is raw, generate f32 and send it as uint8list input
      Random rand = Random();
      input = (rand.nextDouble() * 2) * pi;
      Uint8List randomBytes = Uint8List(4)
        ..buffer.asByteData().setFloat32(0, input, Endian.little);
      inputBytes = randomBytes;
      print(inputBytes);
    }
    print("Running with inputBytes length: ${inputBytes.length}");
    dynamic result = "\"<MISSING>\"";
    int count = 0;
    int startMillisecond = new DateTime.now().millisecondsSinceEpoch;
    while (count < 1 && result == "\"<MISSING>\"") {
      result = await RunevmFl.runRune(inputBytes);

      try {
        final outJson = json.decode(result);
        if (outJson.runtimeType.toString() == "List<dynamic>") {
          //need to add more type checks
          if (outJson.length == 2) {
            elements = [];
            List<dynamic> labels = outJson[0]["elements"];
            List<dynamic> scores = outJson[1]["elements"]; 
            for (int i = 0; i < labels.length; i++) {
              elements.add({"label": labels[i], "score": scores[i] / 1000});
            }
            
            elements.sort((b, a) => a["score"].compareTo(b["score"]));
            rawOutput = elements.toString();
          } else {
            rawOutput = "Raw output: $result";
          }
        } else if (outJson.containsKey("string")) {
          rawOutput = "Result: ${outJson["string"]}";
        } else if (outJson.containsKey("elements")) {
          rawOutput = "Result: ${outJson["elements"]}";
        } else {
          rawOutput = "Raw output: $result";
        }
      } catch (e) {
        rawOutput = "Raw output: $result";
      }
      count++;
      print("retrying:$count |$result| ${result == "\"<MISSING>\""}");
    }
    print("output: $result ${result.runtimeType.toString()}");
    int millisecs =
        new DateTime.now().millisecondsSinceEpoch - startMillisecond;
    millisecondsPerRun = max(millisecs, 1);
    runTimes.add(millisecondsPerRun);
    if (capabilities.containsKey("5")) {
      var out = jsonDecode(result);
      elements.add({"in": input, "out": out[0]});
      if (capabilities.containsKey("5")) {
        elements.sort((a, b) => a["in"].compareTo(b["in"]));
      }
    }
  }

  Future<int> getManifest(String input) async {
    elements = [];
    capabilities = {};
    try {
      dynamic output = await RunevmFl.manifest;
      if (Platform.isIOS) {
        output = utf8.decode(List<int>.from(output));
        print("mainfest output: $output");
      }
      output = json.decode(output);

      if (output.length > 0) {
        int capability = output[0]["capability"];
        capabilities["$capability"] = capabilitiesDefinition["$capability"];
        if (output[0].containsKey("parameters")) {
          parameters["$capability"] = {};
          for (dynamic parameter in output[0]["parameters"]) {
            parameters["$capability"][parameter["key"]] = parameter["value"];
          }
        }
        print("Capability found: $capability ${capabilities["$capability"]}");
        print("with parameters: ${parameters["$capability"]}");
        modelOutput = "SERIAL";
        return capability;
      }
    } catch (e) {
      print("Error reading manifest: $e");
      return -1;
    }

    return 0;
  }

  List<dynamic> elements = [];
}
