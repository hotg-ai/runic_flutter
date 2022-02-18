import 'dart:async';

import 'dart:typed_data';

import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:mic_stream/mic_stream.dart';
//import 'dart:html' as html;

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
  }
/*
  html.MediaStream? _localStream;
  initWeb() async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};

    try {
      var stream = await html.window.navigator.mediaDevices!
          .getUserMedia(mediaConstraints);
      _localStream = stream;
      final audio = _localStream!.getAudioTracks().first;
      html.MediaRecorder record = new html.MediaRecorder(_localStream!);
      record.start();
    } catch (e) {
      print(e.toString());
    }
  }*/

  initRecord() async {
    stream = await MicStream.microphone(
        sampleRate: 16000,
        channelConfig: ChannelConfig.CHANNEL_IN_MONO,
        audioFormat: AudioFormat.ENCODING_PCM_16BIT);
  }

  int bitcount = 0;
  int millisecondStarted = 0;
  int measurements = 0;

  stopRecording() async {
    for (StreamSubscription<List<int>> streamSub in _streamSubscriptions) {
      await streamSub.cancel();
    }
    recording = false;
    update();
  }

  int milliseconds = 0;
  startRecording() async {
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
        measurements++;

        if (millisecondStarted == 0) {
          millisecondStarted = DateTime.now().millisecondsSinceEpoch;
        }
        List<int> stream = to16bit(samples);
        bitcount += stream.length;
        milliseconds =
            (DateTime.now().millisecondsSinceEpoch - millisecondStarted);
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
      }));
    }
  }

  List<int> to16bit(List<int> input) {
    List<int> out = [];
    out = Uint8List.fromList(input).buffer.asInt16List().toList();
    return out;
  }

  Uint8List getStepBuffer() {
    //while (_buffer.length < this.totalLength) {
    //  _buffer.add(0);
    //}
    print(
        "sending buffer from $selectedPos, ${selectedPos + length} , ${_buffer.length} ${_buffer.sublist(selectedPos, selectedPos + length).length}");
    return Int16List.fromList(
            _buffer.sublist(selectedPos, selectedPos + length))
        .buffer
        .asUint8List();
  }

  List<int> getBuffer() {
    List<int> fullBuffer = [];
    while (_buffer.length + fullBuffer.length < this.totalLength) {
      fullBuffer.add(0);
    }
    fullBuffer.addAll(_buffer);
    return fullBuffer;
  }

  @override
  prepData() {
    super.prepData();
    this.raw = getStepBuffer();
  }
}
