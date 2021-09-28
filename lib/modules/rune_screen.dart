import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/main.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:camera/camera.dart';

class RuneScreen extends StatefulWidget {
  static Uint8List runeBytes = new Uint8List(0);

  RuneScreen({Key? key}) : super(key: key);

  @override
  _RuneScreenState createState() => _RuneScreenState();
}

class _RuneScreenState extends State<RuneScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool enableAudio = true;
  XFile? imageFile;
  XFile? videoFile;
  bool show = true;
  bool showRest = true;
  //Rune
  dynamic _manifest;
  String _output = "[]";

  @override
  void initState() {
    loadRune();
    super.initState();
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    //final CameraController? cameraController = controller;
    if (controller == null) {
      return Center(
        child: Container(
            width: 84,
            height: 84,
            child: LoadingIndicator(
                indicatorType: Indicator.ballTrianglePathColoredFilled,

                /// Required, The loading type of the widget
                colors: [Colors.white.withAlpha(50)],

                /// Optional, The color collections
                strokeWidth: 2,

                /// Optional, The stroke of the line, only applicable to widget which contains line
                backgroundColor: Colors.transparent,

                /// Optional, Background of the widget
                pathBackgroundColor: Colors.transparent

                /// Optional, the stroke backgroundColor
                )),
      );
    } else {
      if (!controller!.value.isInitialized) {
        return Center(
          child: Container(
              width: 84,
              height: 84,
              child: LoadingIndicator(
                  indicatorType: Indicator.ballGridBeat,

                  /// Required, The loading type of the widget
                  colors: [Colors.white.withAlpha(50)],

                  /// Optional, The color collections
                  strokeWidth: 2,

                  /// Optional, The stroke of the line, only applicable to widget which contains line
                  backgroundColor: Colors.transparent,

                  /// Optional, Background of the widget
                  pathBackgroundColor: Colors.transparent

                  /// Optional, the stroke backgroundColor
                  )),
        );
      }
      return CameraPreview(
        controller!,
      );
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
    super.didChangeAppLifecycleState(state);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.low : ResolutionPreset.low,
      enableAudio: enableAudio,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
        //showInSnackBar(
        //    'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb ? [] : []),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void logError(String code, String? message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }

  void loadRune() async {
    print("LoadRune");
    await RunevmFl.load(RuneScreen.runeBytes);
    _manifest = jsonDecode(await RunevmFl.manifest);
    print("_manifest: $_manifest");
    //init cam
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print("${e.code}, ${e.description}");
    }
    for (CameraDescription cameraDescription in cameras) {
      print("$cameraDescription");
    }
    onNewCameraSelected(cameras.last);
  }

  Future<void> hideAll() async {
    //fixing bug with disposing CameraPreview widget
    setState(() {
      showRest = false;
    });
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      show = false;
    });
    await Future.delayed(Duration(milliseconds: 50));
  }

  _run() async {
    print("taking pic");
    XFile shot = await controller!.takePicture();
    print("taking pic2 $shot");
    Uint8List rawImage = await shot.readAsBytes();
    print("rawImage bytes ${rawImage.length}");
    Uint8List bytes = ImageUtils.convertImage(rawImage, _manifest[0]);
    print("bytes ${bytes.length}");
    _output = (await RunevmFl.runRune(bytes))!;

    print("ooo:$_output");
    setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Background(),
          AppBar(
            elevation: 0,
            centerTitle: false,
            leadingWidth: 42,
            backgroundColor: Colors.transparent,
            leading: Container(),
            title: Text(
              'Rune',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icons/notification.png",
                    width: 16,
                  ),
                  onPressed: () {}),
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        barneyPurpleColor.withAlpha(150),
                        indigoBlueColor.withAlpha(150),
                      ],
                    )),
                width: 30,
                height: 30,
                child: IconButton(
                    icon: Icon(Icons.segment, size: 16),
                    splashColor: Colors.white,
                    splashRadius: 21,
                    onPressed: () {}),
              )),
              Container(
                width: 10,
              )
            ],
          ),
          Container(
              padding: EdgeInsets.fromLTRB(12, 60, 12, 12),
              child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return !show
                          ? Container()
                          : new Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19.0),
                              ),
                              color: Colors.white.withAlpha(50),
                              margin: EdgeInsets.all(0),
                              child: Container(
                                margin: EdgeInsets.fromLTRB(2, 30, 2, 2),
                                height: 400,
                                padding: EdgeInsets.all(3),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: _cameraPreviewWidget()),
                              ));
                    }
                    if (index == 1) {
                      return !showRest
                          ? Container()
                          : Container(
                              height: 42,
                              margin: EdgeInsets.only(top: 22),
                              decoration: new BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurRadius: 6,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(20.5),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      charcoalGrey.withAlpha(125),
                                      barneyPurpleColor.withAlpha(50),
                                      indigoBlueColor.withAlpha(125),
                                    ],
                                  )),
                              child: RawMaterialButton(
                                elevation: 4.0,
                                child: new Text(
                                  'Run Model',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  _run();
                                },
                              ),
                            );
                    }
                    if (index == 2) {
                      return !showRest
                          ? Container()
                          : ListTile(
                              title: Text(
                                "Output",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text("$_output",
                                  style: TextStyle(color: Colors.white)),
                            );
                    }
                    return Container();
                  })),
          MainMenu(
            preLoad: hideAll,
          )
        ]));
  }
}
