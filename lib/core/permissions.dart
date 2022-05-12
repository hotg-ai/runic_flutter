import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> requestPhotos() async {
    if (!kIsWeb) {
      if (await Permission.photos.request().isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  static Future<bool> requestMicrophone() async {
    if (!kIsWeb) {
      if (await Permission.microphone.request().isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}
