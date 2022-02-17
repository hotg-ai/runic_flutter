import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

const heartBeatInterval = 500; //in ms

enum LogLevel {
  log,
  debug,
  info,
  warn,
  error,
  table,
  clear,
  time,
  timeEnd,
  count,
  asserting
}

class Logs {
  static String socketIOUrl = "https://dev-socket.hotg.ai";
  static IO.Socket? socket;
  static String? visitorID;
  static int? projectID = 0;
  static String? userName;

  static init(int newProjectID, String url) async {
    if (projectID == newProjectID) {
      return;
    } else {
      projectID = newProjectID;
      socketIOUrl = "https://socket.hotg.ai";
      if (url.contains("https://dev-")) {
        socketIOUrl = "https://dev-socket.hotg.ai";
      }
      if (url.contains("https://stg-")) {
        socketIOUrl = "https://stg-socket.hotg.ai";
      }
    }
    if (visitorID == null) {
      visitorID = await getVisitorID();
    }
    if (userName == null) {
      userName = Uuid().v4();
    }
    //if (Logs.socket == null) {
    print("building socket");
    socket = IO.io(
        socketIOUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath("/socket.io")
            .setQuery({"project_id": projectID})
            .disableAutoConnect()
            .setExtraHeaders({"secure": true})
            .build());
    print(" socket build");
    //}

    Logs.socket!
        .onConnectError((data) => {print("SocketIO connection Error $data")});
    Logs.socket!.onConnecting((data) => {print("SocketIO connecting  $data")});
    Logs.socket!
        .onConnectTimeout((data) => {print("SocketIO ConnectTimeout  $data")});
    Logs.socket!.on('event', (data) {
      print("DATA SEND>>>>>>>>>>>$data");
    });
    Logs.socket!.onDisconnect((_) => print('disconnect'));
    Logs.socket!.on('fromServer', (_) => print(_));
    if (Logs.socket!.disconnected) {
      print('trying to connect');
      Logs.socket!.onConnect((_) {
        Map<String, dynamic> deviceInfo = {
          "id": visitorID,
          "name": userName,
          "type": getDeviceType()
        };
        socket!.emit("register_device_$projectID", deviceInfo);
        print("Connected to server");
        print(deviceInfo);
        heartBeat(projectID!);
      });

      print('SocketIO connecting to $socketIOUrl $socket');
      socket!.connect();
    }
  }

  static heartBeat(int project) {
    if (socket!.connected && projectID == project) {
      socket!.emit("heartbeat_$projectID", {"deviceId": visitorID});
      new Future.delayed(const Duration(milliseconds: heartBeatInterval), () {
        heartBeat(project);
      });
    }
  }

  static sendTelemetryToSocket(dynamic data) {
    sendToSocket(jsonEncode(data), "Telemetry");
  }

  static sendToSocket(dynamic data, String level) {
    if (socket == null) {
      return;
    }
    if (socket!.connected && projectID! > 0) {
      print(
          "project_log_message_$projectID deviceId: $visitorID, method: $level, message: $data}");
      socket!.emit("project_log_message_$projectID",
          {"deviceId": visitorID, "method": level, "message": data});
      ;
    }
  }

  static Future<String> getVisitorID() async {
    if (kIsWeb) {
      return "${Browser().hashCode}";
    }
    return "${Platform.localHostname}";
  }

  static String getDeviceType() {
    return kIsWeb
        ? "${Browser().browserAgent}"
        : "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
  }

  static sendLogs() async {
    List<dynamic> logs = (await RuneEngine.getLogs()).toList();
    for (String log in logs) {
      List<String> fields = "$log".split("@@");

      if ("$log".contains("rune=")) {
        try {
          Map<dynamic, dynamic> jsonFields =
              jsonDecode("${log.split("rune=")[1]}");
          if (jsonFields.containsKey("message")) {
            fields = [
              jsonFields["level"],
              jsonFields["target"],
              jsonFields["message"]
            ];
            sendToSocket(jsonFields["message"], jsonFields["level"]);
          }
        } catch (e) {}
      }

      /*if (fields.length < 3) {
        try {
          Map<dynamic, dynamic> jsonFields = jsonDecode("${log}");
          if (jsonFields.containsKey("message")) {
            fields = [
              jsonFields["level"],
              jsonFields["target"],
              jsonFields["message"]
            ];
          }
        } catch (e) {}
      }*/
      LogLevel level = LogLevel.info;
      if (fields[0] == "Error") {
        sendToSocket(fields[2], fields[0]);
      }
    }
  }
}
