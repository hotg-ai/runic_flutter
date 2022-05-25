import 'dart:typed_data';

import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';

class ImageCap extends RawCap {
  @override
  int type = CapabilitiesIds["ImageCapability"]!;
  bool loading = false;
  Uint8List? thumb;
}
