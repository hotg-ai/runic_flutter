import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:universal_html/html.dart' as html;

const updateFrequency = 3;

class AudioCap extends RawCap {
  @override
  int type = CapabilitiesIds["AudioCapability"]!;
  int length = 1000;
  int selectedPos = 0;
  int totalLength = 3000;
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
  bool recording = false;

  AudioCap({this.hz = 16000, this.ms = 1000}) {
    length = (this.hz / this.ms * 1000).round();
    totalLength = length * 3;
    selectedPos = length;
    initRecord();
    if (kIsWeb) {
      RunevmFl.initMic();
    }
  }

  initWeb() async {
    recording = true;

    millisecondStarted = DateTime.now().millisecondsSinceEpoch;
    Function check = (Function check) async {
      milliseconds =
          (DateTime.now().millisecondsSinceEpoch - millisecondStarted);
      update();
      await new Future.delayed(Duration(milliseconds: 50));

      if (recording) {
        check(check);
      }
    };
    new Future.delayed(Duration(milliseconds: 50), () {
      check(check);
    });
    dynamic output = await RunevmFl.decode(this.ms * 3);
    recording = false;
    print(output.length);
    decodeF32List(List<double>.from(output));
    update();
  }

  initRecord() async {
    if (!kIsWeb) {
      stream = await MicStream.microphone(
          sampleRate: 16000,
          channelConfig: ChannelConfig.CHANNEL_IN_MONO,
          audioFormat: AudioFormat.ENCODING_PCM_16BIT);
    } else {}
  }

  int bitcount = 0;
  int millisecondStarted = 0;
  int measurements = 0;

  stopRecording() async {
    if (kIsWeb) {
    } else {
      for (StreamSubscription<List<int>> streamSub in _streamSubscriptions) {
        await streamSub.cancel();
      }
    }

    recording = false;
    update();
  }

  int milliseconds = 0;
  startRecording() async {
    if (kIsWeb) {
      bitcount = 0;
      millisecondStarted = 0;
      recording = true;
      update();
      _buffer = [];
      initWeb();
    } else {
      bitcount = 0;
      millisecondStarted = 0;
      recording = true;

      update();
      _buffer = [];

      bits = await MicStream.bitDepth!;
      for (StreamSubscription<List<int>> streamSub in _streamSubscriptions) {
        await streamSub.cancel();
      }
      if (stream != null) {
        _streamSubscriptions.add(stream?.listen((List<int> samples) async {
          decodeStream(samples);
        }));
      }
    }
  }

  decodeF32List(List<double> data) {
    int amp = 20000;
    List<int> stream = [];
    for (int i = 0; i < data.length; i++) {
      stream.add((data[i] * amp).round());
    }
    double sampleRateCalc = data.length / (this.ms * 3) * 1000;
    double maxDifference = 5000;
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
    print("sampleRate $sampleRateCalc $sampleRate");
    if (sampleRate == 48000) {
      for (int i = 2; i < stream.length; i += 3) {
        _buffer.add(((stream[i - 2] + stream[i - 1] + stream[i]) / 3).round());
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

    if (_buffer.length > this.totalLength) {
      _buffer = _buffer.sublist(_buffer.length - this.totalLength);
    }
    while (_buffer.length < this.totalLength) {
      _buffer.add(0);
    }
  }

  decodeStream(List<int> samples) {
    measurements++;

    if (millisecondStarted == 0) {
      millisecondStarted = DateTime.now().millisecondsSinceEpoch;
    }
    List<int> stream = to16bit(samples);
    bitcount += stream.length;
    milliseconds = (DateTime.now().millisecondsSinceEpoch - millisecondStarted);
    double sampleRateCalc = bitcount / milliseconds * 1000;
    double maxDifference = 5000;
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
    print("$sampleRateCalc $sampleRate");
    if (sampleRate == 48000) {
      for (int i = 2; i < stream.length; i += 3) {
        _buffer.add(((stream[i - 2] + stream[i - 1] + stream[i]) / 3).round());
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

    if (_buffer.length > this.totalLength) {
      _buffer = _buffer.sublist(_buffer.length - this.totalLength);
      this.stopRecording();
    }
    if (_buffer.length < this.totalLength) {
      //_buffer.insert(0, 0);
    }
    if (measurements % updateFrequency == 0) {
      update();
    }
  }

  List<int> to16bit(List<int> input) {
    List<int> out = [];
    out = Uint8List.fromList(input).buffer.asInt16List().toList();
    return out;
  }

  Uint8List getStepBuffer() {
    return Int16List.fromList(
            _buffer.sublist(selectedPos, selectedPos + length))
        .buffer
        .asUint8List();
  }

  List<int> getBuffer() {
    int window = 20;
    List<int> fullBuffer = [];
    while (_buffer.length + fullBuffer.length * window - this.totalLength < 0) {
      fullBuffer.add(0);
    }
    for (int i = window; i < _buffer.length; i = i + window) {
      double sum = 0.0;
      _buffer.sublist(i - window, i).forEach((e) => sum += e);
      fullBuffer.add((sum / window).round());
    }

    return fullBuffer;
  }

  @override
  prepData() {
    super.prepData();
    this.raw = getStepBuffer();
  }
}
