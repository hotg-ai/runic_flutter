import 'dart:typed_data';

const CapabilitiesIds = {
  "RandCapability": 1,
  "AudioCapability": 2,
  "AccelCapability": 3,
  "ImageCapability": 4,
  "RawCapability": 5
};

class RawCap {
  int type = CapabilitiesIds["RawCapability"]!;
  Uint8List? raw;
  dynamic parameters;

  prepData() {}
}
