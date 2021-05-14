import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:runevm_fl/runevm_fl.dart';

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
    final url =
        Uri.parse("https://rune-registry.web.app/registry/registry.json");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(">${response.body}<");
      runes = List<dynamic>.from(jsonDecode(response.body));
      print("Rune registry loaded:\n$runes");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load registry');
    }
  }

  List<Map<String, Object>>? output;
  Map capabilities = {};
  String? modelOutput;
  String rawOutput = "";
  int wasmSize = 0;

  Future<void> deployWASM(String urlString) async {
    //download
    Uint8List wasmBytes = await downloadWASM(
        'https://rune-registry.web.app/registry/' + urlString + '/app.rune');
    await RunevmFl.loadWASM(wasmBytes);
    wasmSize = wasmBytes.length;
  }

  Future<Uint8List> downloadWASM(String urlString) async {
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
    while (count < 42 && result == "\"<MISSING>\"") {
      result = await RunevmFl.runRune(inputBytes);
      count++;
      print("retrying:$count |$result| ${result == "\"<MISSING>\""}");
    }
    print("output: $result ${result.runtimeType.toString()}");
    int millisecs =
        new DateTime.now().millisecondsSinceEpoch - startMillisecond;
    millisecondsPerRun = max(millisecs, 1);
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
    final dynamic output = await RunevmFl.manifest;
    if (output[0] is int) {
      int capability = output[0];
      capabilities["$capability"] = capabilitiesDefinition["$capability"];
      print("Capability found: $capability ${capabilities["$capability"]}");
      modelOutput = "SERIAL";
      return capability;
    }

    return 0;
  }

  List<dynamic> elements = [];
}
