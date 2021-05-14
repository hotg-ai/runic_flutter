import 'dart:async';

import 'package:mic_stream/mic_stream.dart';
import 'dart:typed_data';

class Audio {
  final int bufferLength;
  final int stepSize;
  int stepCounter = 0;
  int bits = 16;
  List _streamSubscriptions = [];
  List<int> _buffer = [];
  List<int> _stepBuffer = [];

  Audio({this.bufferLength = 1280, this.stepSize = 24000});

  Function onStep = (List<int> buffer) {};

  Stream<List<int>>? stream;
  initRecord() async {
    stream = await MicStream.microphone(
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);
  }

  List<int> getBuffer() {
    return _buffer;
  }

  Int16List to16bit(List<int> input) {
    Int16List out = Uint8List.fromList(input).buffer.asInt16List();
    return out;
  }

  startRecording() async {
    bits = await MicStream.bitDepth;
    print("Start recording");
    _streamSubscriptions.add(stream?.listen((List<int> samples) {
      Int16List stream = to16bit(samples);
      stepCounter++;
      _buffer.addAll(stream);
      _stepBuffer.addAll(samples);
      while (_stepBuffer.length > this.stepSize) {
        _stepBuffer.removeAt(0);
      }
      while (_buffer.length > this.bufferLength) {
        _buffer.removeAt(0);
      }

      if (_stepBuffer.length == this.stepSize) {
        onStep(_stepBuffer);
        _stepBuffer = [];
      } else {
        if (_buffer.length == this.bufferLength) {
          onStep(null);
        }
      }
    }));
  }

  stopRecording() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    onStep = (List buffer) {
      //empty function
    };
  }

  clearBuffer() {}
}
