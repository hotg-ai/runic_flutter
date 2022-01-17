import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:runic_flutter/core/logs.dart';

const maxLogs = 1000;

class Analytics {
  static Map<String, dynamic> history = {};
  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>> getHistory() async {
    String? out = await secureStorage.read(key: 'history');
    if (out != null) {
      history = jsonDecode(out);
      return history;
    }

    return history;
  }

  static addToHistory(String event) async {
    Logs.sendToSocket(event);
    if (kIsWeb) return;
    if (history.keys.length == 0) {
      await getHistory();
    }
    history["${DateTime.now().millisecondsSinceEpoch}"] = event;

    while (history.keys.length > maxLogs) {
      history.remove(history.keys.first);
    }

    await secureStorage.write(key: 'history', value: jsonEncode(history));
  }
}
