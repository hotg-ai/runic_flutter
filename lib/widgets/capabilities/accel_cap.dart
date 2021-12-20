import 'dart:typed_data';

import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelCap extends RawCap {
  @override
  int type = CapabilitiesIds["AccelCapability"]!;
  final int length;
  Uint8List? raw;
  List<double> xAxis = [];
  List<double> yAxis = [];
  List<double> zAxis = [];
  dynamic parameters;
  Function update = () {};

  AccelCap([this.length = 1000]) {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      //add zeros to get the desired length
      while (xAxis.length < length) xAxis.add(0.0);
      while (yAxis.length < length) yAxis.add(0.0);
      while (zAxis.length < length) zAxis.add(0.0);
      //add event coordinates
      xAxis.add(event.x);
      yAxis.add(event.y);
      zAxis.add(event.z);
      //remove oldest coordinates
      if (xAxis.length > length) xAxis.removeAt(0);
      if (yAxis.length > length) yAxis.removeAt(0);
      if (zAxis.length > length) zAxis.removeAt(0);
      raw = getUint8List();
      update();
    });
  }

  Uint8List getUint8List() {
    List<int> outBytes = [];
    for (int i = 0; i < length; i++) {
      var buffer = new Int8List(4).buffer;
      var bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, xAxis[i]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);
      buffer = new Int8List(4).buffer;
      bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, yAxis[i]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);
      buffer = new Int8List(4).buffer;
      bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, zAxis[i]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);
    }
    return Uint8List.fromList(outBytes);
  }
}
