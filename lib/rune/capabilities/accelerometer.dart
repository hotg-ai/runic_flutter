import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:sensors/sensors.dart';

class AcceleroMeter {
  final int bufferLength;

  var _buffer = [];
  final int stepSize;
  int stepCounter = 0;
  List _streamSubscriptions = [];
  AcceleroMeter({this.bufferLength = 128, this.stepSize = 8});

  Function onStep = (List buffer) {};

  clearBuffer() {
    _buffer = [];
  }

  Uint8List getByteList() {
    List<int> outBytes = [];

    List<double> floatList = [];
    for (List<double> coord in _buffer) {
      var buffer = new Int8List(4).buffer;
      var bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, coord[0]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);
      buffer = new Int8List(4).buffer;
      bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, coord[1]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);
      buffer = new Int8List(4).buffer;
      bdata = new ByteData.view(buffer);
      bdata.setFloat32(0, coord[2]);
      outBytes.addAll(bdata.buffer.asInt8List().reversed);

      floatList.addAll(coord);
    }
    return Uint8List.fromList(outBytes);
  }

  String? getBufferJson() {
    print("Buffer Length: ${_buffer.length}");
    return (_buffer.length == bufferLength) ? jsonEncode(_buffer) : null;
  }

  List<double> getXBuffer() {
    List<double> out = [];
    for (List<double> coord in _buffer) {
      out.add(coord[0]);
    }
    return out;
  }

  List<double> getYBuffer() {
    List<double> out = [];
    for (List<double> coord in _buffer) {
      out.add(coord[1]);
    }
    return out;
  }

  List<double> getZBuffer() {
    List<double> out = [];
    for (List<double> coord in _buffer) {
      out.add(coord[2]);
    }
    return out;
  }

  startRecording() {
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      stepCounter++;

      _buffer.add([event.x, event.y, event.z]);
      if (_buffer.length > this.bufferLength) {
        _buffer.removeAt(0);
      }
      if (_buffer.length == this.bufferLength &&
          stepCounter % this.stepSize == 0) {
        onStep(_buffer);
      }
    }));
    // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
    /*
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      //print(event);
    });
    // [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

    gyroscopeEvents.listen((GyroscopeEvent event) {
      //print(event);
    });
    */

    // [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
  }

  stopRecording() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    onStep = (List buffer) {
      //empty function
    };
  }
}
