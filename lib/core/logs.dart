import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

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
  static init(int newProjectID) async {
    if (projectID == newProjectID) {
      return;
    } else {
      projectID = newProjectID;
    }
    if (visitorID == null) {
      visitorID = await getVisitorID();
    }
    if (userName == null) {
      userName = Uuid().v4();
    }
    if (Logs.socket == null) {
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
    }
    Logs.socket!
        .onConnectError((data) => {print("SocketIO connection Error $data")});
    Logs.socket!.onConnecting((data) => {print("SocketIO connecting  $data")});
    Logs.socket!
        .onConnectTimeout((data) => {print("SocketIO ConnectTimeout  $data")});
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
      });

      Logs.socket!.on('event', (data) => print(data));
      Logs.socket!.onDisconnect((_) => print('disconnect'));
      Logs.socket!.on('fromServer', (_) => print(_));
      print('SocketIO connecting to $socketIOUrl $socket');
      socket!.connect();
    }
  }

  static sendToSocket(dynamic data, LogLevel level) {
    if (socket == null) {
      return;
    }
    if (socket!.connected && projectID! > 0) {
      socket!.emit("project_log_message_$projectID",
          {"deviceId": visitorID, "method": level.toString(), "message": data});
      print(">>>>>>>>>>>>>emitting project_log_message_$projectID");
    }
  }

  static Future<String> getVisitorID() async {
    print(">>>>>>>>>>>>>>");
    if (kIsWeb) {
      return "${Browser().hashCode}";
    }
    return "${Platform.localHostname}";
  }

  static String getDeviceType() {
    print(">>>>>>>>>>>>>>");
    return kIsWeb
        ? "${Browser().browserAgent}"
        : "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
  }

  static sendLogs() async {
    print(">>>>>>>>>>>>>>");
    List<dynamic> logs = (await RuneEngine.getLogs()).toList();
    for (String log in logs) {
      List<String> fields = "$log".split("@@");
      LogLevel level = LogLevel.info;
      if (fields[0] == "Error") level = LogLevel.error;
      if (fields[0] == "Debug") level = LogLevel.debug;
      sendToSocket(log, level);
    }
  }
}
