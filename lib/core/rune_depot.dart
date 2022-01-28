import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

//not implemented yet
const maxRunes = 100;

class RuneDepot {
  static Box? runeDB;
  static Box? dataDB;
  static List<Map<String, dynamic>>? runes = [];

  static check() async {
    if (runeDB == null) {
      if (!kIsWeb) {
        var path = (await getApplicationDocumentsDirectory()).path;
        Hive..init(path);
      }

      runeDB = await Hive.openBox('runes');
    }
    if (dataDB == null) {
      dataDB = await Hive.openBox('runeBytes');
    }
  }

  static Future<void> getRunes() async {
    await check();
    List<String> keys = List<String>.from(runeDB!.keys);
    runes = [];
    for (String key in keys) {
      runes!.add(Map<String, dynamic>.from(runeDB!.get(key)!));
    }
  }

  static Future<void> deleteRune(Map<String, dynamic> rune) async {
    await check();
    await dataDB!.delete(rune["uuid"]);
    await runeDB!.delete(rune["uuid"]);
  }

  static Future<Uint8List?> getRune(String uuid) async {
    return dataDB!.get(uuid);
  }

  static Future<bool> checkCache(List<dynamic> meta) async {
    await check();
    List<String> keys = List<String>.from(runeDB!.keys);
    print("keys: $keys");
    for (dynamic rune in meta) {
      String uuid = "${rune["name"]}_${rune["version"]}";
      rune["cached"] = keys.contains(uuid);
      print("$uuid ${rune["cached"]}");
    }

    return false;
  }

  static Future<void> addRune(Uint8List bytes, Map<String, dynamic> meta,
      {String? uuid}) async {
    await check();
    meta["uuid"] = uuid == null ? Uuid().v4() : uuid;
    var now = DateTime.now().toLocal();
    meta["timestamp"] =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    if (!meta.containsKey("name")) meta["name"] = "Rune_${meta["uuid"]}";
    await runeDB!.put(meta["uuid"], meta);
    await dataDB!.put(meta["uuid"], bytes);
  }
}
