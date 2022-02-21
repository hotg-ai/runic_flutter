import 'dart:typed_data';

import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RandCap extends RawCap {
  @override
  Uint8List? raw = new Uint8List(0);
  @override
  int type = CapabilitiesIds["RandCapability"]!;

  @override
  prepData() {
    super.prepData();
    this.raw = new Uint8List(parameters["length"]);
  }
}
