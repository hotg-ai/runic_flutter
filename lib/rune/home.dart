// @dart=2.9
import 'dart:convert';

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:runic_mobile/rune/graphs.dart';
import 'package:runic_mobile/rune/capabilities/accelerometer.dart';
import 'package:runic_mobile/rune/capabilities/audio.dart';
import 'package:runic_mobile/rune/capabilities/image.dart';
import 'package:runic_mobile/rune/runic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:camera/camera.dart';
import 'registry.dart';

const gestures = ["Wing", "Ring", "Slope"];
const speech = ["Silence", "Yes", "No"];

class RunicHomePage extends StatefulWidget {
  final Map<String, dynamic> currentRune;
  RunicHomePage({Key key, this.currentRune}) : super(key: key);

  @override
  _RunicHomePageState createState() => _RunicHomePageState();
}

class _RunicHomePageState extends State<RunicHomePage> {
  List<CameraDescription> cameras;
  CameraController controller;
  final Runic _runic = new Runic();
  bool _running = false;

  bool model = false;
  bool loading = false;

  ImageCapability _imageCap = new ImageCapability();
  AcceleroMeter _accelerometer =
      new AcceleroMeter(stepSize: 16, bufferLength: 128);
  Audio _audioRecorder = new Audio();

  @override
  void initState() {
    super.initState();
    deploy();
  }

  int _currentCamera = 0;
  bool _cameraInitialized;
  initCamera(int cameraID) async {
    cameras = await availableCameras();
    _currentCamera = cameraID;
    if (controller != null) {
      try {
        await controller?.stopImageStream();
        await controller?.dispose();
      } catch (e) {
        print(e);
      }
    }
    controller = CameraController(
        cameras.length > cameraID ? cameras[cameraID] : cameras[0],
        ResolutionPreset.low);
    print("Init Camera");

    controller?.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller?.initialize();
      await controller?.startImageStream((CameraImage image) async {
        if (_running == false) {
          _running = true;
          Runic.inputData = _imageCap.processCameraImage(image);
          _running = false;
          //setState(() {});
        }
      });
      setState(() {
        _cameraInitialized = true;
      });
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      print("mounted");
      setState(() {});
    }
  }

  @override
  void dispose() {
    runningContinious = false;
    controller?.dispose();
    _audioRecorder.stopRecording();
    _accelerometer.stopRecording();
    super.dispose();
  }

  List<Map<String, dynamic>> modelResult = [];
  int threads = 0;
  void initAudio() async {
    print("Init audio");
    await _audioRecorder.stopRecording();
    await _audioRecorder.initRecord();
    _audioRecorder.onStep = (List<int> audio) async {
      if (audio != null && _running == false) {
        _running = true;
        while (audio.length < 32000) {
          audio.add(0);
        }
        Runic.inputData = Uint8List.fromList(audio);
        _running = false;
      }
      setState(() {});
    };
    _audioRecorder.startRecording();
  }

  bool _train = false;
  String _trainGesture = "";
  String _trainDescription = "";
  bool runningContinious = false;
  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  Future<void> train(String gesture) async {
    _running = false;
    _accelerometer.stopRecording();

    _accelerometer.onStep = (List<dynamic> buffer) async {
      setState(() {});
    };

    setState(() {
      _trainGesture = gesture;
      _train = true;
      _trainDescription = "3";
    });
    await Future.delayed(const Duration(seconds: 1), () => {});
    setState(() {
      _train = true;
      _trainDescription = "2";
    });
    await Future.delayed(const Duration(seconds: 1), () => {});
    setState(() {
      _train = true;
      _trainDescription = "1";
    });
    _running = true;

    await Future.delayed(const Duration(seconds: 1), () => {});
    setState(() {
      _train = true;
      _trainDescription = "Start";
    });

    _accelerometer.onStep = (List<dynamic> buffer) async {
      String data = _accelerometer.getBufferJson();

      setState(() {});
    };
    _accelerometer.clearBuffer();
    _accelerometer.startRecording();
  }

  deploy() async {
    await _audioRecorder.stopRecording();
    if (controller != null) {
      try {} catch (e) {
        await controller?.stopImageStream();
      }

      await controller?.dispose();
    }
    setState(() {
      loading = true;
    });
    try {
      await _runic.deployWASM(widget.currentRune["name"], () {
        setState(() {});
      });
      try {
        print("_runic.getManifest: ");
        await _runic.getManifest("manifest");
        print("_runic.getManifest: ${_runic.parameters}");
        if (_runic.capabilities.containsKey("4")) {
          if (_runic.parameters["4"].containsKey("width") &&
              _runic.parameters["4"].containsKey("height") &&
              _runic.parameters["4"].containsKey("pixel_format")) {
            _imageCap = new ImageCapability(
                width: int.parse(_runic.parameters["4"]["width"]),
                height: int.parse(_runic.parameters["4"]["height"]),
                format: int.parse(_runic.parameters["4"]["pixel_format"]));
          }
          initCamera(1);
        }

        if (_runic.capabilities.containsKey("2")) {
          initAudio();
        } else {
          _audioRecorder.stopRecording();
        }

        if (_runic.capabilities.containsKey("3")) {
          _accelerometer.startRecording();
          _running = true;
          _accelerometer.onStep = (List<dynamic> buffer) async {
            //print("ok");
            Runic.inputData = _accelerometer.getByteList();
            //List<Map<String, Object>> result =
            //    await _runic.runRune(_accelerometer.getByteList());

            setState(() {});
          };
          print("Starting accelometer");
        } else {
          _running = false;
          _accelerometer.stopRecording();
          _accelerometer.onStep = (List<dynamic> buffer) async {};
        }
        setState(() {
          loading = false;
        });
      } on Exception catch (e) {}
    } on Exception catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    List<Widget> tiles = [];
    List<Widget> runeTiles = [
      (_runic.loading)
          ? ListTile(
              dense: true,
              leading: CircularProgressIndicator(color: accentColor),
              title: Text(
                " Loading ",
                style: TextStyle(color: Colors.white),
              ))
          : ListTile(
              leading: Container(
                  child: Icon(
                Icons.check_circle,
                color: Colors.green,
              )),
              title: Text(
                _runic.wasmSize > 0
                    ? "Rune size: ${_runic.wasmSize}"
                    : "No Rune deployed",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.white),
              ))
    ];
    if (_runic.millisecondsPerRun > 0) {
      runeTiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.speed,
            color: Color.fromRGBO(59, 188, 235, 1),
          ),
          title: Text(
            "Runtime: ${_runic.millisecondsPerRun}ms",
            style: TextStyle(color: Colors.white),
          )));
    }

    for (String cap in _runic.capabilities.keys) {
      runeTiles.add(ListTile(
        dense: true,
        leading: Icon(
          Icons.input,
          color: Color.fromRGBO(59, 188, 235, 1),
        ),
        title: Text(
          "${_runic.capabilities[cap]}",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${_runic.parameters[cap]}",
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      ));
      if (cap == "4") {
        //VIDEO!
        runeTiles.add(
          Row(children: [
            Expanded(
                child: Center(
                    child: Container(
                        height: 280,
                        width: !(controller.value.isInitialized && mounted)
                            ? 280
                            : 1 / controller.value.aspectRatio * 280,
                        padding: const EdgeInsets.only(
                            right: 0.0, left: 0.0, top: 0, bottom: 0),
                        child: (controller.value.isInitialized && mounted)
                            ? CameraPreview(controller)
                            : Text("Waiting for Camera")))),
          ]),
        );
        runeTiles.add(Center(
            child: IconButton(
                onPressed: () {
                  initCamera(_currentCamera == 0 ? 1 : 0);
                },
                icon: Icon(Icons.camera_front,
                    color: Color.fromRGBO(59, 188, 235, 1)))));
      }
      if (cap == "2") {
        runeTiles.add(
          Container(
            height: 120,
            padding: const EdgeInsets.only(
                right: 0.0, left: 0.0, top: 10, bottom: 0),
            child: LineChart(
              audioData(_audioRecorder.getBuffer()),
            ),
          ),
        );
      }
      if (cap == "3") {
        runeTiles.add(
          Container(
            height: 120,
            padding: const EdgeInsets.only(
                right: 0.0, left: 0.0, top: 10, bottom: 0),
            child: LineChart(
              accelometerData(_accelerometer),
            ),
          ),
        );
      }
    }
    if (_runic.capabilities.length > 0) {
      runeTiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.run_circle_sharp,
            color: Color.fromRGBO(59, 188, 235, 1),
          ),
          title: Text(
            "${_runic.rawOutput}",
            style: TextStyle(color: Colors.white),
          )));
    }
    if (_runic.capabilities.containsKey("4")) {
      if (_runic.elements.length > 0) {
      } else if (_runic.capabilities.containsKey("2")) {
      } else if (_runic.capabilities.containsKey("3")) {
      } else if (_runic.capabilities.containsKey("5")) {
        runeTiles.add(
          Container(
            height: 120,
            padding: const EdgeInsets.only(
                right: 0.0, left: 0.0, top: 10, bottom: 0),
            child: LineChart(
              mainData(_runic.elements),
            ),
          ),
        );
      }
    }

    tiles.addAll([
      Container(
        height: 15.5,
        padding: EdgeInsets.only(top: 5, left: 16),
      ),
      Container(
          decoration: new BoxDecoration(
              color: Color.fromRGBO(24, 17, 64, 1),
              borderRadius: new BorderRadius.all(
                const Radius.circular(21.0),
              )),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          margin: EdgeInsets.all(8),
          child: Column(
            children: runeTiles,
          )),

      /*new TextFormField(
              decoration:
                  new InputDecoration(labelText: "Enter Fibonaci Iterations"),
              initialValue: fibIt.toString(),
              onChanged: (value) {
                fibIt = int.parse(value);
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], // Only numbers can be entered
            ),*/

      /*(answer.length==0)?Container():Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(40),
              ),
              color: Color.fromRGBO(24, 17, 64, 1)),
          margin: EdgeInsets.only(left: 21,right: 21,bottom: 21),
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
            child: LineChart(
              mainData(),
            ),
          ),),*/

      (_runic.wasmSize == 0)
          ? Container(height: 0)
          : Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 21, right: 21),
              height: 63,
            )
    ]);

    return Scaffold(
      floatingActionButton: Container(
          height: 62,
          child: Row(children: [
            Expanded(child: Container()),
            FloatingActionButton(
                backgroundColor: Color.fromRGBO(59, 188, 235, 1),
                splashColor: accentColor,
                onPressed: (_runic.wasmSize > 0)
                    ? () async {
                        runningContinious = false;
                        setState(() {});
                      }
                    : null,
                child: Icon(
                  Icons.stop,
                )),
            Container(
              width: 21,
            ),
            FloatingActionButton(
                backgroundColor: Color.fromRGBO(59, 188, 235, 1),
                splashColor: accentColor,
                onPressed: (_runic.wasmSize > 0)
                    ? () async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          await _runic.runRune();
                          setState(() {
                            loading = false;
                          });
                        } on Exception catch (e) {}
                      }
                    : null,
                child: Icon(
                  Icons.play_arrow,
                )),
            Container(
              width: 21,
            ),
            FloatingActionButton(
                backgroundColor: runningContinious
                    ? accentColor
                    : Color.fromRGBO(59, 188, 235, 1),
                onPressed: (_runic.wasmSize > 0)
                    ? () async {
                        runningContinious = true;
                        while (runningContinious) {
                          try {
                            await _runic.runRune();
                            setState(() {
                              loading = false;
                            });
                          } on Exception catch (e) {}
                        }
                      }
                    : null,
                child: Icon(
                  Icons.fast_forward,
                )),
          ])),
      backgroundColor: Color.fromRGBO(42, 39, 98, 1),
      appBar: AppBar(
        backgroundColor: darkColor,
        title: Text(widget.currentRune["name"],
            style: TextStyle(color: Colors.white)),
      ),
      body: Stack(children: [
        Container(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ListView(children: tiles)),
        _train
            ? Container(
                color: Color.fromRGBO(59, 188, 235, 1).withAlpha(200),
                child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    "Train $_trainGesture Gesture\n\n$_trainDescription",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ])))
            : Container(
                height: 0,
              )
      ]),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
