//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:ai_barcode_web/ai_barcode_web.dart';
import 'package:camera_web/camera_web.dart';
import 'package:flutter_secure_storage_web/flutter_secure_storage_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:platform_device_id_web/platform_device_id_web.dart';
import 'package:runevm_fl/runevm_fl_web.dart';
import 'package:sensors_plus_web/sensors_plus_web.dart';
import 'package:share_plus_web/share_plus_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  AiBarcodeWebPlugin.registerWith(registrar);
  CameraPlugin.registerWith(registrar);
  FlutterSecureStorageWeb.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  PlatformDeviceIdWebPlugin.registerWith(registrar);
  RunevmFlWeb.registerWith(registrar);
  SensorsPlugin.registerWith(registrar);
  SharePlusPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
