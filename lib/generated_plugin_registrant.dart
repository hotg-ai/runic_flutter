//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:camera_web/camera_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:runevm_fl/runevm_fl_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  CameraPlugin.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  RunevmFlWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
