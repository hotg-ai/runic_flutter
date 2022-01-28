import 'dart:async';
import 'dart:typed_data';

import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:mic_stream/mic_stream.dart';

const updateFrequency = 3;

class AudioCap extends RawCap {
  @override
  int type = CapabilitiesIds["AudioCapability"]!;
  int length = 1000;
  int sampleRate = 16000;
  final int hz;
  final int ms;
  final int stepSize = 24000;

  Uint8List? raw;
  List<int> _buffer = [];
  dynamic parameters;
  Function update = () {};
  Stream<List<int>>? stream;
  int bits = 16;
  List _streamSubscriptions = [];

  AudioCap({this.hz = 16000, this.ms = 1000}) {
    length = (this.hz / this.ms * 1000).round();
    initRecord();
  }

  initRecord() async {
    stream = await MicStream.microphone(
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);
    startRecording();
  }

  int bitcount = 0;
  int millisecondStarted = 0;
  int measurements = 0;

  startRecording() async {
    bits = await MicStream.bitDepth!;
    for (StreamSubscription<List<int>> streamSub in _streamSubscriptions) {
      await streamSub.cancel();
    }
    if (stream != null) {
      _streamSubscriptions.add(stream?.listen((List<int> samples) async {
        measurements++;

        if (millisecondStarted == 0) {
          millisecondStarted = DateTime.now().millisecondsSinceEpoch;
        }
        List<int> stream = to16bit(samples);
        bitcount += stream.length;

        double sampleRateCalc = bitcount /
            (DateTime.now().millisecondsSinceEpoch - millisecondStarted) *
            1000;
        double maxDifference = 100000;
        if ((sampleRateCalc - 16000).abs() < maxDifference) {
          maxDifference = (sampleRateCalc - 16000).abs();
          sampleRate = 16000;
        }
        if ((sampleRateCalc - 32000).abs() < maxDifference) {
          maxDifference = (sampleRateCalc - 32000).abs();
          sampleRate = 32000;
        }
        if ((sampleRateCalc - 48000).abs() < maxDifference) {
          maxDifference = (sampleRateCalc - 48000).abs();
          sampleRate = 48000;
        }

        if (sampleRate == 48000) {
          for (int i = 2; i < stream.length; i += 3) {
            _buffer
                .add(((stream[i - 2] + stream[i - 1] + stream[i]) / 3).round());
          }
        }
        if (sampleRate == 32000) {
          for (int i = 1; i < stream.length; i += 2) {
            _buffer.add(((stream[i - 1] + stream[i]) / 2).round());
          }
        }
        if (sampleRate == 16000) {
          _buffer.addAll(stream);
        }

        if (_buffer.length > this.length) {
          _buffer = _buffer.sublist(_buffer.length - this.length);
        }
        if (measurements % updateFrequency == 0) {
          update();
        }
      }));
    }
  }

  List<int> to16bit(List<int> input) {
    List<int> out = [];
    out = Uint8List.fromList(input).buffer.asInt16List().toList();
    return out;
  }

  Uint8List getStepBuffer() {
    while (_buffer.length < this.length) {
      _buffer.add(0);
    }
    return Int16List.fromList(_buffer).buffer.asUint8List();
  }

  List<int> getBuffer() {
    while (_buffer.length < this.length) {
      _buffer.add(0);
    }
    return _buffer;
  }

  @override
  prepData() {
    super.prepData();
    this.raw = getStepBuffer();
  }
}
