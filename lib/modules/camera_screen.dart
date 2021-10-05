import 'dart:convert';
import 'dart:typed_data';

import 'package:blur/blur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/main.dart';
import 'package:runic_flutter/utils/image_utils.dart';
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
  bool enableAudio = true;
  XFile? imageFile;
  XFile? videoFile;
  bool show = true;
  bool showRest = true;

  @override
  void initState() {
    super.initState();
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
      );
    }
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
    onNewCameraSelected(cameras.last);
  }

  run() async {
    XFile shot = await controller!.takePicture();
    Uint8List rawImage = await shot.readAsBytes();
    widget.cap.thumb = rawImage;
    Uint8List bytes = ImageUtils.convertImage(rawImage, widget.cap.parameters);
    widget.cap.raw = bytes;

    await RuneEngine.run();

    setState(() {});
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
                    top: 21,
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
                      Expanded(child: Container()),
                      InkWell(
                          onTap: () {
                            run();
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
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14)),
                                      color: const Color(0xffff00e5))))),
                      Expanded(child: Container())
                    ]))
                : Container(),
            //results
            showBackButton && RuneEngine.output["type"] != "none"
                ? Positioned(
                    top: 40,
                    height: RuneEngine.output["type"] == "Image" ? 160 : 42,
                    left: 50,
                    right: 50,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: RuneEngine.output["type"] == "Image"
                            ? Image.memory(
                                RuneEngine.output["output"],
                                fit: BoxFit.cover,
                              )
                            : Blur(
                                blur: 10,
                                blurColor: Colors.white24,
                                colorOpacity: 0.2,
                                child: Container(
                                  color: darkBlueBlue.withAlpha(0),
                                ))))
                : Container(),
            showBackButton && RuneEngine.output["type"] == "String"
                ? Positioned(
                    top: 40,
                    height: 42,
                    left: 50,
                    right: 50,
                    child: Row(children: [
                      Expanded(child: Container()),
                      Container(
                          child: Text("${RuneEngine.output}",
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white))),
                      Expanded(child: Container())
                    ]))
                : Container()
          ])),
    );
  }
}
