import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'dart:convert' show utf8;

import 'package:runic_mobile/rune/capabilities/image.dart';

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
  static List<Uint8List> inputData = [];
  static List<dynamic> runes = [
    {
      "name": "hotg-ai/sine",
      "description": "Sine prediction rune from random input"
    },
  ];

  static Future<void> fetchRegistry() async {
    final url = Uri.parse("https://rune-registry.web.app/registry/runes.json");
    final response = await http.get(url);
    final directory = await getTemporaryDirectory();
    String fileURL = "${directory.path}/runes.json";
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      runes = List<dynamic>.from(jsonDecode(response.body));
      //save list
      await File(fileURL).writeAsString(response.body);
      //only show the ones with display == true;
      runes = runes.where((element) => element["display"] == true).toList();
    } else {
      if (await File(fileURL).exists()) {
        runes =
            List<dynamic>.from(jsonDecode(await File(fileURL).readAsString()));
        //only show the ones with display == true;
        runes = runes.where((element) => element["display"] == true).toList();
      }
    }
  }

  List<Map<String, Object>>? output;

  //Make a list since more than one cap can exist with same id
  List capabilitiesList = [];

  Map capabilities = {};
  Map parameters = {};
  String? modelOutput;
  String rawOutput = "";
  dynamic outputData = [];
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

    if (await File(fileURL).exists()) {
      print("file in cache!");
      Uint8List wasmBytes = await File(fileURL).readAsBytes();
      await RunevmFl.load(wasmBytes);
      wasmSize = wasmBytes.length;
      loading = false;
    } else {
      Uint8List wasmBytes = await downloadWASM(
          'https://rune-registry.web.app/registry/' + name + '/app.rune');
      //write to cache dir
      await File(fileURL).writeAsBytes(wasmBytes);
      await RunevmFl.load(wasmBytes);
      wasmSize = wasmBytes.length;
      loading = false;
    }

    setState();
  }

  Uint8List? getImageOut() {
    if (outputData.length > 0) {
      List<int> out = [];
      for (double val in outputData) {
        out.add((val * 255).round());
      }
      ImageCapability cap =
          new ImageCapability(width: 384, height: 384, format: 0);
      return cap.bytesRGBtoPNG(out);
    } else {
      return null;
    }
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
  Future<void> runRune() async {
    List<int> inputBytes = [];
    List<int> lengths = [];
    for (int i = 0; i < Runic.inputData.length; i++) {
      print(
          "####### Sending CAP $i with start val ${Runic.inputData[i][0]} and length ${Runic.inputData[i].length}");
      inputBytes.addAll(List.from(Runic.inputData[i]));
      lengths.add(Runic.inputData[i].length);
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
      result = await RunevmFl.runRune(Uint8List.fromList(inputBytes), lengths);

      try {
        final outJson = json.decode(result);
        if (outJson.runtimeType.toString().contains("List")) {
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
          outputData = outJson["string"];
        } else if (outJson.containsKey("elements")) {
          rawOutput = "Result: ${outJson["elements"]}";
          outputData = outJson["elements"];
        } else {
          rawOutput = "Raw output: $result";
        }
      } catch (e) {
        rawOutput = "Raw output: $result";
      }
      count++;
      print("retrying:$count");
    }
    //print("output: $result ${result.runtimeType.toString()}");
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

  Future<List> getManifest(String input) async {
    elements = [];
    capabilities = {};
    capabilitiesList = [];
    try {
      dynamic output = await RunevmFl.manifest;
      if (Platform.isIOS) {
        output = utf8.decode(List<int>.from(output));
        print("mainfest output: $output");
      }
      output = json.decode(output);

      for (int i = 0; i < output.length; i++) {
        int capability = output[i]["capability"];
        Map cap = {
          "id": i,
          "capability": capability,
          "name": capabilitiesDefinition["$capability"],
          "parameters": {}
        };

        capabilities["$capability"] = capabilitiesDefinition["$capability"];
        if (output[i].containsKey("parameters")) {
          parameters["$capability"] = {};
          for (dynamic parameter in output[i]["parameters"]) {
            parameters["$capability"][parameter["key"]] = parameter["value"];
            cap["parameters"][parameter["key"]] = parameter["value"];
          }
        }
        print("Capability found: $capability ${capabilities["$capability"]}");
        print("with parameters: ${parameters["$capability"]}");
        capabilitiesList.add(cap);
        modelOutput = "SERIAL";
      }
    } catch (e) {
      print("Error reading manifest: $e");
      return [];
    }

    return capabilitiesList;
  }

  List<dynamic> elements = [];
}
