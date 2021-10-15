import 'dart:convert';
import 'dart:typed_data';

import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/main.dart';
import 'package:runic_flutter/modules/result_screen.dart';
import 'package:runic_flutter/modules/rune_screen.dart';
import 'package:runic_flutter/utils/image_utils.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final ImageCap cap;
  CameraScreen({Key? key, required this.cap}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool enableAudio = false;
  XFile? imageFile;
  XFile? videoFile;
  bool show = true;
  bool showRest = true;
  bool flash = false;
  int camera = 0;
  bool live = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    initCam();
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
        child: RuneEngine.output["type"] == "Objects"
            ? CustomPaint(
                painter: ShapePainter(RuneEngine.objects), child: Container())
            : Container(),
      );
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
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

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    print(cameraDescription);
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.low : ResolutionPreset.low,
      enableAudio: false,
    );

    controller = cameraController;
    cameraController.setFlashMode(flash ? FlashMode.auto : FlashMode.off);
    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      print("async $mounted");
      setState(() {});
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
        ...(!kIsWeb
            ? [
                cameraController
                    .getMinExposureOffset()
                    .then((value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((value) => _maxAvailableExposureOffset = value)
              ]
            : []),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
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

  void initCam() async {
    //print("LoadRune");
    //await RunevmFl.load(CameraScreen.runeBytes);
    //_manifest = jsonDecode(await RunevmFl.manifest);
    //print("_manifest: $_manifest");
    //init cam
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print("${e.code}, ${e.description}");
    }
    for (CameraDescription cameraDescription in cameras) {
      print("$cameraDescription");
    }
    onNewCameraSelected(cameras[camera]);
  }

  switchCamera() {
    camera++;
    if (camera == cameras.length) {
      camera = 0;
    }
    onNewCameraSelected(cameras[camera]);
  }

  run() async {
    loading = true;
    setState(() {});
    XFile shot = await controller!.takePicture();
    Uint8List rawImage = await shot.readAsBytes();
    List<Uint8List> data =
        ImageUtils.convertImage(rawImage, widget.cap.parameters);
    widget.cap.thumb = data[1];
    Uint8List bytes = data[0];
    widget.cap.raw = bytes;

    await RuneEngine.run();
    loading = false;
    setState(() {});
    if (RuneEngine.output["type"] != "Image" && controller != null && live) {
      new Future.delayed(const Duration(milliseconds: 100), () {
        run();
      });
    }
    if (RuneEngine.output["type"] == "Image") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen()),
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool showBackButton = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Stack(children: [
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: _cameraPreviewWidget()),
            showBackButton
                ? Positioned(
                    left: 21,
                    top: 42,
                    height: 42,
                    width: 42,
                    child: IconButton(
                        onPressed: () async {
                          showBackButton = false;
                          setState(() {});
                          await Future.delayed(
                              const Duration(milliseconds: 100), () {});

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white)))
                : Container(),
            showBackButton
                ? Positioned(
                    bottom: 120,
                    height: 84,
                    left: 50,
                    right: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Blur(
                            blur: 10,
                            blurColor: Colors.white.withAlpha(100),
                            colorOpacity: 0.2,
                            child: Container(
                              color: darkBlueBlue.withAlpha(100),
                            ))))
                : Container(),
            showBackButton
                ? Positioned(
                    bottom: 120,
                    height: 84,
                    left: 50,
                    right: 50,
                    child: Row(children: [
                      Expanded(
                          child: Container(
                              child: IconButton(
                        icon: (flash)
                            ? Icon(Icons.flash_on, color: darkGreyBlue)
                            : Icon(Icons.flash_off, color: darkGreyBlue),
                        onPressed: () {
                          flash = !flash;
                          onNewCameraSelected(cameras[camera]);
                        },
                      ))),
                      InkWell(
                          onTap: () {
                            if (RuneEngine.output["type"] != "Image") {
                              live = !live;
                              if (live) {
                                run();
                              }
                            } else {
                              live = false;
                              run();
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(33)),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xffff00e5),
                                  )),
                              child: Container(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    live ? Icons.stop : Icons.play_arrow,
                                    color: darkGreyBlue,
                                    size: 21,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14)),
                                      color: const Color(0xffff00e5))))),
                      Expanded(
                          child: Container(
                              child: IconButton(
                        icon: Image.asset("assets/images/icons/reload.png"),
                        onPressed: () {
                          switchCamera();
                        },
                      )))
                    ]))
                : Container(),
            //results
            showBackButton && RuneEngine.output["type"] == "String"
                ? Positioned(
                    top: 100,
                    height: 82,
                    left: 0,
                    right: 0,
                    child: Blur(
                        blur: 10,
                        blurColor: Colors.white24,
                        colorOpacity: 0.2,
                        child: Container(
                          color: darkBlueBlue.withAlpha(0),
                        )))
                : Container(),
            showBackButton && RuneEngine.output["type"] == "String"
                ? Positioned(
                    top: 100,
                    height: 82,
                    left: 0,
                    right: 0,
                    child: Row(children: [
                      Expanded(
                          child: Text("${RuneEngine.output["output"]}",
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              )))
                    ]))
                : Container(),
            showBackButton && (loading || RuneEngine.executionTime > 0.0)
                ? Positioned(
                    bottom: 20,
                    height: 82,
                    left: 0,
                    right: 0,
                    child: loading &&
                            (RuneEngine.executionTime > 250 ||
                                RuneEngine.executionTime == 0)
                        ? LoadingScreen()
                        : Container(
                            alignment: Alignment.center,
                            child: Text(
                                "${RuneEngine.executionTime.round()} ms",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white))))
                : Container(),
          ])),
    );
  }
}

T? _ambiguate<T>(T? value) => value;