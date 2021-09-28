import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

class Registry {
  static List<dynamic> runes = [];
  static Future<Uint8List> downloadWASM(String urlString) async {
    final url = Uri.parse(urlString);
    final client = http.Client();
    final request = http.Request('GET', url);
    final response = await client.send(request);
    final stream = response.stream;
    List<int> runeBytes = [];
    await for (var data in stream) {
      runeBytes.addAll(data);
    }
    client.close();
    return new Uint8List.fromList(runeBytes);
  }

  static Future<void> fetchRegistry() async {
    if (runes.length == 0) {
      final url =
          Uri.parse("https://rune-registry.web.app/registry/runes.json");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        runes = List<dynamic>.from(jsonDecode(response.body));
        //filter on runes with web compatibility
        //runes = runes.where((element) => element["web"] == true).toList();
        //print(runes);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load registry');
      }
    }
  }
}
