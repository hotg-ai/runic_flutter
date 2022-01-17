import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:device_info_plus/device_info_plus.dart';

class Logs {
  static String socketIOUrl = "https://dev-socket.hotg.ai";
  static IO.Socket? socket;
  static String? deviceId;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  static init() async {
    deviceId = await getDeviceID();
    if (socket == null) {
      socket = IO.io(
          socketIOUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setPath("/socket.io")
              .build());
    }
    if (socket!.disconnected) {
      socket!.onConnect((_) {
        print('connect');
        socket!.emit('msg', ['mobile app', 'Connected']);
      });
      socket!.on('event', (data) => print(data));
      socket!.onDisconnect((_) => print('disconnect'));
      socket!.on('fromServer', (_) => print(_));
      print('SocketIO connecting from device $deviceId to $socketIOUrl');
      socket!.connect();
    }
  }

  static sendToSocket(dynamic data) {
    if (socket == null) {
      return;
    }
    if (socket!.connected) {
      socket!.emit('msg', [data]);
    }
  }

  static Future<String> getDeviceID() async {
    String _deviceID = "unknown";

    try {
      if (kIsWeb) {
        _deviceID = (await deviceInfoPlugin.webBrowserInfo).platform!;
      } else {
        if (Platform.isAndroid) {
          _deviceID = (await deviceInfoPlugin.androidInfo).id!;
        } else if (Platform.isIOS) {
          _deviceID = (await deviceInfoPlugin.iosInfo).name!;
        }
      }
    } on PlatformException {
      _deviceID = 'Failed to get platform version.';
    }
    return _deviceID;
  }
}
