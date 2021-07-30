// @dart=2.9
import 'dart:convert';
import 'package:flutter/src/services/system_chrome.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final bool url;
  RunicHomePage({Key key, this.currentRune, this.url = false})
      : super(key: key);

  @override
  _RunicHomePageState createState() => _RunicHomePageState();
}

class _RunicHomePageState extends State<RunicHomePage> {
  Uint8List thumb;
  List<CameraDescription> cameras;
  CameraController controller;
  final Runic _runic = new Runic();
  bool _running = false;

  bool model = false;
  bool loading = false;

  Uint8List imageTwo;

  ImageCapability _imageCap = new ImageCapability();
  AcceleroMeter _accelerometer =
      new AcceleroMeter(stepSize: 16, bufferLength: 64);
  Audio _audioRecorder = new Audio();

  @override
  void initState() {
    super.initState();
    deploy();
  }

  int _currentCamera = 1;
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
    //controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
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
          _imageCap.image = image;
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
        Runic.inputData[0] = Uint8List.fromList(audio);
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
  bool error = false;
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
      if (widget.url) {
        await _runic.deployWASMFromURL(widget.currentRune["name"], () {
          setState(() {});
        });
      } else {
        await _runic.deployWASM(widget.currentRune["name"],
            widget.currentRune["version"].toString(), () {
          setState(() {});
        });
      }

      try {
        print("_runic.getManifest: ");
        List man = await _runic.getManifest("manifest");
        if (man.length == 0) {
          setState(() {
            error = true;
          });
        }
        print("_runic.getManifest: ${_runic.parameters}");

        if (_runic.capabilitiesList.length > 1) {
          print(
              "_imageCap = new ImageCapability(width: 384, height: 384, format: 0);");
          _imageCap = new ImageCapability(width: 384, height: 384, format: 0);
        }
        if (_runic.capabilities.containsKey("4")) {
          if (_runic.parameters["4"].containsKey("width") &&
              _runic.parameters["4"].containsKey("height") &&
              _runic.parameters["4"].containsKey("pixel_format")) {
            _imageCap = new ImageCapability(
                width: int.parse(_runic.parameters["4"]["width"]),
                height: int.parse(_runic.parameters["4"]["height"]),
                format: int.parse(_runic.parameters["4"]["pixel_format"]));
            //hard coded fix for style transfer

          }

          initCamera(0);
        }

        if (_runic.capabilities.containsKey("2")) {
          initAudio();
        } else {
          _audioRecorder.stopRecording();
        }

        if (_runic.capabilities.containsKey("3")) {
          print("_runic.capabilities");
          int bufferLength = _runic.parameters["3"].containsKey("n")
              ? int.parse(_runic.parameters["3"]["n"])
              : 128;

          _accelerometer =
              new AcceleroMeter(stepSize: 16, bufferLength: bufferLength);
          _accelerometer.startRecording();
          _running = true;
          _accelerometer.onStep = (List<dynamic> buffer) async {
            //print("ok");
            Runic.inputData[0] = _accelerometer.getByteList();
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
    List<Widget> props = [];
    if (!_runic.capabilities.containsKey("5") && _runic.elements.length > 0) {
      for (Map element in _runic.elements) {
        props.add(Container(
            height: 28,
            child: Row(
              children: [
                Expanded(
                    child: Text(element["label"],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    child: LinearProgressIndicator(
                  backgroundColor: lightColor,
                  color: Color.fromRGBO(59, 188, 235, 1),
                  value: element["score"],
                ))
              ],
            )));
      }
    }
    List<Widget> runeTiles = [
      (!_runic.capabilities.containsKey("5") && _runic.elements.length > 0)
          ? ListTile(
              dense: false,
              leading: Icon(
                Icons.insights,
                color: Color.fromRGBO(59, 188, 235, 1),
              ),
              title: Column(
                children: props,
              ),
            )
          : Container(),
      (_runic.capabilities.length > 0)
          ? (_runic.capabilitiesList.length > 1 && _runic.outputData.length > 0)
              ? ListTile(
                  title: Image.memory(_runic.getImageOut()),
                )
              : ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.raw_on,
                    color: Color.fromRGBO(59, 188, 235, 1),
                  ),
                  title: Text(
                    "${_runic.rawOutput}",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ))
          : Container(),
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
      runeTiles.add(
        ListTile(
          dense: true,
          leading: Icon(
            Icons.speed,
            color: Color.fromRGBO(59, 188, 235, 1),
          ),
          title: Text(
            "Runtime: ${_runic.millisecondsPerRun}ms",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Container(
              height: 32,
              child: LineChart(
                runTime(_runic.runTimes),
              )),
        ),
      );
    }

    List<Widget> inputWidgets = [];
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
        inputWidgets.add(
          Row(children: [
            Stack(children: [
              Center(
                  child: Container(
                      height: !(controller.value.isInitialized && mounted)
                          ? MediaQuery.of(context).size.width
                          : controller.value.aspectRatio *
                              MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          right: 0.0, left: 0.0, top: 0, bottom: 0),
                      child: (controller.value.isInitialized && mounted)
                          ? CameraPreview(controller)
                          : Text("Waiting for Camera"))),
              Positioned(
                child: Container(
                    color: lightColor,
                    width: 120,
                    height: 120 * _imageCap.height / _imageCap.width,
                    child: thumb != null ? Image.memory(thumb) : Container()),
                right: 10,
                top: 10,
              ),
              (_runic.capabilitiesList.length > 1)
                  ? Positioned(
                      child: new InkWell(
                          onTap: () async {
                            final ImagePicker _picker = ImagePicker();
                            final PickedFile image = await _picker.getImage(
                                source: ImageSource.gallery);
                            imageTwo = await _imageCap
                                .processCameraImageFromLibrary(image, 0);
                            setState(() {});
                          },
                          child: Container(
                              color: lightColor,
                              width: 120,
                              height: 120 * _imageCap.height / _imageCap.width,
                              child: imageTwo != null
                                  ? Image.memory(imageTwo)
                                  : Center(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                          Icon(Icons.image,
                                              color: Color.fromRGBO(
                                                  59, 188, 235, 1)),
                                          Text(
                                            "Upload Image",
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    59, 188, 235, 1)),
                                          )
                                        ])))),
                      right: 140,
                      top: 10,
                    )
                  : Container(),
              Positioned(
                  right: 12,
                  top: 12,
                  child: Text("CAP 1",
                      style:
                          TextStyle(color: Color.fromRGBO(59, 188, 235, 1)))),
              (_runic.capabilitiesList.length > 1)
                  ? Positioned(
                      right: 142,
                      top: 12,
                      child: Text("CAP 2",
                          style: TextStyle(
                              color: Color.fromRGBO(59, 188, 235, 1))))
                  : Container(),
              IconButton(
                  onPressed: () {
                    initCamera(_currentCamera == 0 ? 1 : 0);
                  },
                  icon: Icon(Icons.camera_front,
                      color: Color.fromRGBO(59, 188, 235, 1)))
            ]),
          ]),
        );
      }
      if (cap == "2") {
        inputWidgets.add(
          Container(
            height: 320,
            padding: const EdgeInsets.only(
                right: 21.0, left: 21.0, top: 21, bottom: 21),
            child: LineChart(
              audioData(_audioRecorder.getBuffer()),
            ),
          ),
        );
      }
      if (cap == "3") {
        inputWidgets.add(
          Container(
            height: 320,
            padding: const EdgeInsets.only(
                right: 21.0, left: 21.0, top: 21, bottom: 21),
            child: LineChart(
              accelometerData(_accelerometer),
            ),
          ),
        );
      }

      if (cap == "5") {
        inputWidgets.add(
          Container(
            height: 320,
            padding: const EdgeInsets.only(
                right: 21.0, left: 21.0, top: 21, bottom: 21),
            child: LineChart(
              mainData(_runic.elements),
            ),
          ),
        );
      }
    }
    runeTiles.add(Container(
      height: 150,
    ));
    tiles.addAll([
      Container(
        height: 150,
        padding: EdgeInsets.only(top: 5, left: 16),
      ),
      Container(
          decoration: new BoxDecoration(
              color: Color.fromRGBO(24, 17, 64, 1),
              borderRadius: new BorderRadius.all(
                const Radius.circular(21.0),
              )),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          margin: EdgeInsets.zero,
          child: Column(
            children: runeTiles,
          )),
    ]);

    return Scaffold(
      floatingActionButton: Container(
          height: 62,
          child: Row(children: [
            Expanded(child: Container()),
            FloatingActionButton(
                key: Key("button_one"),
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
                key: Key("button_two"),
                backgroundColor: Color.fromRGBO(59, 188, 235, 1),
                splashColor: accentColor,
                onPressed: (_runic.wasmSize > 0)
                    ? () async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          if (_runic.capabilities.containsKey("4")) {
                            Runic.inputData = [];

                            Runic.inputData.add(_imageCap.processCameraImage(
                                _imageCap.image,
                                (Platform.isIOS)
                                    ? 90
                                    : 90 + _currentCamera * 180));
                            if (imageTwo != null) {
                              ImageCapability cap =
                                  new ImageCapability(width: 256, height: 256);
                              Runic.inputData
                                  .add(cap.processLibLibrary(imageTwo));
                            }
                          }

                          await _runic.runRune();
                          if (_runic.capabilities.containsKey("4")) {
                            thumb = _imageCap.getThumb();
                          }
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
                key: Key("button_three"),
                backgroundColor: runningContinious
                    ? accentColor
                    : Color.fromRGBO(59, 188, 235, 1),
                onPressed: (_runic.wasmSize > 0)
                    ? () async {
                        runningContinious = true;
                        while (runningContinious) {
                          try {
                            if (_runic.capabilities.containsKey("4")) {
                              Runic.inputData[0] = _imageCap.processCameraImage(
                                  _imageCap.image,
                                  (Platform.isIOS)
                                      ? 90
                                      : 90 + _currentCamera * 180);
                            }
                            await _runic.runRune();
                            if (_runic.capabilities.containsKey("4") &&
                                Random().nextDouble() < 0.01) {
                              thumb = _imageCap.getThumb();
                            }
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
      body: error
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                  child: Column(children: [
                Icon(
                  Icons.error_rounded,
                  color: accentColor,
                ),
                Text(
                  "Error deploying Rune",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: accentColor),
                )
              ])))
          : Stack(children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: inputWidgets,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  )),
              Positioned(
                  height: 480,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                  child: ListView(children: tiles)),
            ]),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
