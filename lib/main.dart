// @dart=2.9
import 'dart:convert';

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:runic_mobile/graphs.dart';
import 'package:runic_mobile/rune/capabilities/accelerometer.dart';
import 'package:runic_mobile/rune/capabilities/audio.dart';
import 'package:runic_mobile/rune/capabilities/image.dart';
import 'package:runic_mobile/rune/runic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:camera/camera.dart';

const gestures = ["Wing", "Ring", "Slope"];
const speech = ["Silence", "Yes", "No"];

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Runic.fetchRegistry();
  runApp(RunicApp());
}

class RunicApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RunicMainPage(title: 'Runic'),
    );
  }
}

class RunicMainPage extends StatefulWidget {
  RunicMainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RunicMainPageState createState() => _RunicMainPageState();
}

class _RunicMainPageState extends State<RunicMainPage> {
  CameraController controller;
  final Runic _runic = new Runic();
  bool _running = false;

  dynamic currentRune = {
    "name": "hotg-ai/sine_input",
    "description": "Sine prediction rune from random input"
  };
  bool model = false;
  bool loading = false;

  ImageCapability _imageCap = new ImageCapability();
  AcceleroMeter _accelerometer =
      new AcceleroMeter(stepSize: 16, bufferLength: 128);
  Audio _audioRecorder = new Audio();

  @override
  void initState() {
    super.initState();
  }

  int _currentCamera = 0;
  bool _cameraInitialized;
  initCamera(int cameraID) async {
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
    controller?.dispose();
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
      Row(children: [
        Expanded(child: Container()),
        Container(width: 10),
        Container(
          height: 80,
          width: 280,
          child: new DropdownButtonFormField<String>(
            iconSize: 42,
            decoration: InputDecoration.collapsed(hintText: ''),
            dropdownColor: Color.fromRGBO(59, 188, 235, 1),
            elevation: 0,
            isExpanded: true,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color.fromRGBO(59, 188, 235, 1)),
            value: currentRune["name"],
            items: Runic.runes.map((dynamic rune) {
              return new DropdownMenuItem<String>(
                value: rune["name"],
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.asset(
                      "assets/rune.png",
                      height: 42,
                    ),
                    //tileColor: Color.fromRGBO(59, 188, 235, 1),
                    title: new Text(rune["name"],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    subtitle: new Text(rune["description"],
                        style: TextStyle(color: Colors.white, fontSize: 12))),
              );
            }).toList(),
            onChanged: (value) {
              for (dynamic rune in Runic.runes) {
                if (rune["name"] == value) {
                  currentRune = rune;
                }
              }

              setState(() {});
            },
          ),
        ),
        Expanded(child: Container()),
      ]),
      Container(height: 21),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            width: 142,
            padding: EdgeInsets.all(0.0),
            height: 42,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              color: Color.fromRGBO(59, 188, 235, 1),
              child: Text("Deploy Rune",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.white)),
              onPressed: () async {
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
                  await _runic.deployWASM(currentRune["name"], () {
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
                            format: int.parse(
                                _runic.parameters["4"]["pixel_format"]));
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
              },
            )),
        Container(
          width: 10,
        ),
        (_runic.loading)
            ? Container(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(color: Colors.white))
            : Text(
                _runic.wasmSize > 0
                    ? "Rune size: ${_runic.wasmSize}"
                    : "No Rune deployed",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.white),
              ),
        (_runic.loading)
            ? Text(
                " Loading ",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.white),
              )
            : Expanded(
                child: _runic.wasmSize > 0
                    ? Container(
                        child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ))
                    : Container()),
      ]),
    ];
    if (_runic.millisecondsPerRun > 0) {
      runeTiles.add(ListTile(
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
        leading: Icon(
          Icons.input,
          color: Color.fromRGBO(59, 188, 235, 1),
        ),
        title: Text(
          "Capability: ",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${_runic.capabilities[cap]}",
          style: TextStyle(color: Colors.white),
        ),
      ));
      if (cap == "4") {
        //VIDEO!
        runeTiles.add(
          Row(children: [
            Expanded(
                child: Center(
                    child: Container(
                        height: 220,
                        width: !(controller.value.isInitialized && mounted)
                            ? 220
                            : 1 / controller.value.aspectRatio * 220,
                        padding: const EdgeInsets.only(
                            right: 0.0, left: 0.0, top: 0, bottom: 0),
                        child: (controller.value.isInitialized && mounted)
                            ? CameraPreview(controller)
                            : Text("Waiting for Camera")))),
            Container(
              width: 10,
            ),
            IconButton(
                onPressed: () {
                  initCamera(_currentCamera == 0 ? 1 : 0);
                },
                icon: Icon(Icons.camera_front,
                    color: Color.fromRGBO(59, 188, 235, 1)))
          ]),
        );
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
    if (_runic.modelOutput != null) {
      runeTiles.add(ListTile(
          leading: Icon(
            Icons.outbond,
            color: Color.fromRGBO(59, 188, 235, 1),
          ),
          title: Text(
            "Output: ",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            "${_runic.modelOutput}",
            style: TextStyle(color: Colors.white),
          )));
      if (_runic.capabilities.length > 0) {
        runeTiles.add(ListTile(
            leading: Icon(
              Icons.dashboard_outlined,
              color: Color.fromRGBO(59, 188, 235, 1),
            ),
            title: Text(
              "${_runic.rawOutput}",
              style: TextStyle(color: Colors.white),
            )));
      }
      if (_runic.capabilities.containsKey("4")) {
        if (_runic.elements.length > 0) {
          List<int> result =
              new List<int>.from(modelResult.last["predictions"]);

          String resultString = (result[0] > max(result[1], result[2]))
              ? "Unknown"
              : (result[1] > result[2])
                  ? "Person"
                  : "No Person";
          runeTiles.add(
            Container(
                //height: 84,
                padding: const EdgeInsets.only(
                    right: 0.0, left: 0.0, top: 10, bottom: 0),
                child: Text(
                  "$resultString",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800),
                )),
          );
          runeTiles.add(ListTile(
            title: Text(
              "Unknown",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[0] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
          runeTiles.add(ListTile(
            title: Text(
              "Person",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[1] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
          runeTiles.add(ListTile(
            title: Text(
              "No Person",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[2] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
        }
      } else if (_runic.capabilities.containsKey("2")) {
        if (_runic.elements.length > 0) {
          List<int> result =
              new List<int>.from(modelResult.last["predictions"]);

          String resultString = (result[1] > max(result[2], result[3]))
              ? "Silence"
              : (result[2] > result[3])
                  ? "Yes"
                  : "No";
          runeTiles.add(
            Container(
                //height: 84,
                padding: const EdgeInsets.only(
                    right: 0.0, left: 0.0, top: 10, bottom: 0),
                child: Text(
                  "$resultString",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800),
                )),
          );
          runeTiles.add(ListTile(
            title: Text(
              "Silence",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[1] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
          runeTiles.add(ListTile(
            title: Text(
              "Yes",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[2] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
          runeTiles.add(ListTile(
            title: Text(
              "No",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: LinearProgressIndicator(
              value: result[3] / 255,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(59, 188, 235, 1)),
              backgroundColor: Color.fromRGBO(42, 39, 98, 1),
              minHeight: 6,
            ),
          ));
        }
      } else if (_runic.capabilities.containsKey("3")) {
        if (_runic.elements.length > 0) {
          List<Widget> gestureBoard = [];
          List<dynamic> results = _runic.elements.last["predictions"];
          for (int gestureID = 0; gestureID < gestures.length; gestureID++) {
            gestureBoard.add(
              Row(children: [
                Expanded(
                    child: Text(gestures[gestureID],
                        style: TextStyle(color: Colors.white))),
                ElevatedButton(
                    onPressed: () {
                      train(gestures[gestureID]);
                    },
                    child: Text("Train"))
              ]),
            );
            gestureBoard.add(
              LinearProgressIndicator(
                value: results[gestureID],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(59, 188, 235, 1)),
                backgroundColor: Color.fromRGBO(42, 39, 98, 1),
                minHeight: 6,
              ),
            );
          }
          runeTiles.add(
            Container(
                //height: 84,
                padding: const EdgeInsets.only(
                    right: 0.0, left: 0.0, top: 10, bottom: 0),
                child: Column(children: gestureBoard)),
          );
        }
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
          padding: EdgeInsets.fromLTRB(21, 21, 21, 21),
          margin: EdgeInsets.all(21),
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
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21.0),
                ),
                color: Color.fromRGBO(59, 188, 235, 1),
                child: Text("Run model",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.white)),
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
              )),
    ]);
    return Scaffold(
      backgroundColor: Color.fromRGBO(42, 39, 98, 1),

      body: Stack(children: [
        Container(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: ListView(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                children: tiles)),
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
