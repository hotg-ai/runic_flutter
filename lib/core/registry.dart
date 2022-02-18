import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:runic_flutter/core/logs.dart';
import 'dart:convert';

import 'package:runic_flutter/core/rune_depot.dart';

class Registry {
  static List<dynamic> runes = [];
  static Function onUpdate = (int bytesIn, int totalBytes) {
    //print("Received $bytesIn/$totalBytes");
  };
  static Future<Uint8List?> downloadWASM(String urlString, [Logs? logs]) async {
    try {
      final decoded = Uri.decodeFull(urlString);
      List<String> parts = decoded.split("#project_id=");
      if (parts.length == 2) {
        urlString = parts[0];
        int? projectID = int.tryParse(parts[1]);
        if (projectID != null) logs?.init(projectID, urlString);
      } else {
        List<String> parts = urlString.split("&project_id=");
        if (parts.length == 2) {
          urlString = parts[0];
          int? projectID = int.tryParse(parts[1]);
          if (projectID != null) logs?.init(projectID, urlString);
        }
      }
      final url = Uri.parse(urlString.trim());
      final client = http.Client();
      final request = http.Request('GET', url);
      logs?.sendTelemetryToSocket({"type": "rune/fetch/started"});
      int startTime = DateTime.now().millisecondsSinceEpoch;
      final response = await client.send(request);
      if (response.statusCode != 200) {
        int totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
        logs?.sendTelemetryToSocket({
          "type": "rune/fetch/failed",
          "error": response.reasonPhrase,
          "message": response.reasonPhrase,
          "milliseconds": totalTime.toString(),
        });
      }
      if (response.contentLength! > 50000000) {
        return await response.stream.toBytes();
      }
      final stream = response.stream;
      List<int> runeBytes = [];
      await for (var data in stream) {
        runeBytes.addAll(data);
        onUpdate(runeBytes.length, response.contentLength);
      }
      client.close();
      int totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
      logs?.sendTelemetryToSocket({
        "type": "rune/fetch/succeeded",
        "milliseconds": totalTime.toString(),
      });
      return new Uint8List.fromList(runeBytes);
    } catch (e) {
      return null;
    }
  }

  static Future<void> fetchRegistry({bool? force: false}) async {
    if (runes.length == 0 || force == true) {
      final url =
          Uri.parse("https://rune-registry.web.app/registry/runes.json");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        runes = List<dynamic>.from(jsonDecode(response.body));
        //filter on runes with web compatibility
        if (kIsWeb) {
          runes = runes.where((element) => element["web"] == true).toList();
        } else {
          runes = runes.where((element) => element["display"] == true).toList();
        }

        await RuneDepot.checkCache(runes);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.

        throw Exception('Failed to load registry');
      }
    }
  }
}
