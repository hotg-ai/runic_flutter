import 'dart:math';

import 'package:blur/blur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/logs.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/log_screen.dart';
import 'package:runic_flutter/modules/result_screen.dart';
import 'package:runic_flutter/utils/error_screen.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/capabilities/accel_cap.dart';
import 'package:runic_flutter/widgets/capabilities/accel_capability_widget.dart';
import 'package:runic_flutter/widgets/capabilities/audio_cap.dart';
import 'package:runic_flutter/widgets/capabilities/audio_capability_widget.dart';
import 'package:runic_flutter/widgets/capabilities/image_cap.dart';
import 'package:runic_flutter/widgets/capabilities/image_capability_widget.dart';
import 'package:runic_flutter/widgets/capabilities/rand_cap.dart';
import 'package:runic_flutter/widgets/capabilities/rand_capability_widget.dart';
import 'package:runic_flutter/widgets/capabilities/raw_cap.dart';
import 'package:runic_flutter/widgets/capabilities/raw_capability_widget.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class RuneScreen extends StatefulWidget {
  RuneScreen({Key? key}) : super(key: key);
  static Logs logs = new Logs();
  @override
  _RuneScreenState createState() => _RuneScreenState();
}

class _RuneScreenState extends State<RuneScreen> with TickerProviderStateMixin {
  bool show = true;
  bool showRest = true;
  bool loading = false;
  bool _error = false;
  bool showed = false;

  refresh() {
    setState(() {});
  }

  bool _turn = false;
  @override
  void initState() {
    super.initState();
    if (RuneScreen.logs.isConnected()) {
      beat();
    }
    //if no rune is loaded go back to home screen
    if (RuneEngine.runeBytes!.length == 0) {
      print("Falling back to home screen");
      Navigator.pushNamed(context, "home");
    } else {
      loadRune();
    }
  }

  beat() {
    setState(() {
      _turn = !_turn;
    });

    if (mounted) {
      new Future.delayed(const Duration(milliseconds: heartBeatInterval), () {
        beat();
      });
    }
  }

  Future<void> loadRune() async {
    setState(() {
      loading = true;
    });
    await Future.delayed(Duration(milliseconds: 20));
    await RuneEngine.load(RuneScreen.logs);

    setState(() {
      loading = false;
    });
    //print("_manifest: $_manifest");
  }

  _run([bool silent = false]) async {
    if (RuneEngine.output["type"] == "none") {
      showDownload();
    }
    if (!silent) {
      setState(() {
        loading = true;
      });
    }

    await Future.delayed(Duration(milliseconds: 20));
    await RuneEngine.run(RuneScreen.logs);

    setState(() {
      loading = false;
    });

    if (RuneEngine.output["type"] == "Error") {
      setState(() {
        _error = true;
      });
    } else if (RuneEngine.output["type"] != "String") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen()),
      ).then((value) {
        showDownload();
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    print(RuneEngine.manifest);
    return Stack(children: [
      Background(),
      Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Column(children: [
              Text(RuneEngine.runeMeta["name"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(
                RuneEngine.runeMeta["description"],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              )
            ]),
            actions: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icons/notification.png",
                    width: 16,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LogScreen()));
                  }),
              (RuneScreen.logs.isConnected())
                  ? AnimatedOpacity(
                      opacity: _turn ? 0.0 : 1.0,
                      duration: Duration(milliseconds: heartBeatInterval),
                      child: Tooltip(
                          padding: EdgeInsets.all(21),
                          triggerMode: TooltipTriggerMode.tap,
                          message:
                              "Connected to Studio\nNamespace:${Logs.projectID}\nDeviceType:${Logs.getDeviceType()}\nURL:${Logs.socketIOUrl}",
                          child: Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                              child: Icon(Icons.favorite,
                                  size: 16, color: Colors.red))))
                  : Center(
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
                          icon: Icon(Icons.download, size: 16),
                          splashColor: Colors.white,
                          splashRadius: 21,
                          onPressed: () {
                            showed = false;
                            showDownload();
                          }),
                    )),
              Container(
                width: 10,
              )
            ],
          ),
          body: Stack(children: [
            Container(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: ListView.builder(
                    itemCount: 4 + RuneEngine.manifest.length,
                    itemBuilder: (context, index) {
                      if (index < RuneEngine.manifest.length) {
                        if (RuneEngine.capabilities[index].type ==
                            CapabilitiesIds["ImageCapability"]) {
                          return Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ImageCapabilityWidget(
                                cap: RuneEngine.capabilities[index] as ImageCap,
                                notifyParent: refresh,
                                back: () {
                                  showDownload();
                                },
                                single: RuneEngine.capabilities.length <= 1,
                              ));
                        }
                        if (RuneEngine.capabilities[index].type ==
                            CapabilitiesIds["RandCapability"]) {
                          return Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: RandomCapabilityWidget(
                                cap: RuneEngine.capabilities[index] as RandCap,
                                notifyParent: refresh,
                                single: RuneEngine.capabilities.length <= 1,
                              ));
                        }
                        if (RuneEngine.capabilities[index].type ==
                            CapabilitiesIds["RawCapability"]) {
                          return Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: RawCapabilityWidget(
                                cap: RuneEngine.capabilities[index],
                                notifyParent: refresh,
                                single: RuneEngine.capabilities.length <= 1,
                              ));
                        }
                        if (RuneEngine.capabilities[index].type ==
                            CapabilitiesIds["AccelCapability"]) {
                          return Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: AccelCapabilityWidget(
                                cap: RuneEngine.capabilities[index] as AccelCap,
                                notifyParent: refresh,
                                single: RuneEngine.capabilities.length <= 1,
                              ));
                        }
                        if (RuneEngine.capabilities[index].type ==
                            CapabilitiesIds["AudioCapability"]) {
                          return Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: AudioCapabilityWidget(
                                cap: RuneEngine.capabilities[index] as AudioCap,
                                notifyParent: refresh,
                                run: _run,
                                single: RuneEngine.capabilities.length <= 1,
                              ));
                        }
                      }
                      if (index == RuneEngine.manifest.length) {
                        return Container(
                          height: 42,
                          margin: EdgeInsets.only(top: 11, bottom: 11),
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            onPressed: () {
                              _run();
                            },
                          ),
                        );
                      }
                      if (index == RuneEngine.manifest.length + 1) {
                        return !showRest || RuneEngine.output["type"] == "none"
                            ? Container()
                            : new Card(
                                shape: RoundedRectangleBorder(
                                  //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                                  side: BorderSide(
                                      color: Colors.white.withAlpha(30),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(19.0),
                                ),
                                color: Colors.white.withAlpha(0),
                                margin: EdgeInsets.all(0),
                                child: Container(
                                  //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                  height: RuneEngine.output["type"] == "String"
                                      ? 80
                                      : 0,
                                  //padding: EdgeInsets.all(3),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Container(
                                          color: Colors.white.withAlpha(30),
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Stack(children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Center(
                                                      child: RuneEngine.output[
                                                                  "type"] ==
                                                              "String"
                                                          ? Text(
                                                              "${RuneEngine.output["output"]}",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          : Container()),
                                                ),
                                              ],
                                            )
                                          ]))),
                                )); /*ListTile(
                              title: Text(
                                "Output",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: _output["type"] == "String"
                                  ? Text("${_output["output"]}",
                                      style: TextStyle(color: Colors.white))
                                  : _output["type"] == "Image"
                                      ? Image.memory(_output["output"])
                                      : Container(),
                            );*/

                      }
                      if (index == RuneEngine.manifest.length + 2) {
                        return runTimeLogs();
                      }
                      final isWebMobile = kIsWeb &&
                          (defaultTargetPlatform == TargetPlatform.iOS ||
                              defaultTargetPlatform == TargetPlatform.android);

                      return Container(
                        height: 140,
                      );
                    })),
            loading ? LoadingScreen() : MainMenu(),
          ])),
      _error
          ? ErrorScreen(
              description: RuneEngine.output["output"],
              onClose: () {
                setState(() {
                  _error = false;
                });
              })
          : Container()
    ]);
  }

  Widget runTimeLogs() {
    return Container(
      height: 42,
      margin: EdgeInsets.only(top: 11, bottom: 11),
      decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 6,
              offset: Offset(0, 3), // changes position of shadow
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
          'Show Rune runtime logs',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogScreen()),
          );
        },
      ),
    );
  }

  void showDownload() async {
    if (!showed &&
        kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      SnackBar snackBar = SnackBar(
          elevation: 0,
          duration: Duration(seconds: 100),
          backgroundColor: Colors.transparent,
          content: Container(
              height: 180,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                    ),
                    Blur(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        width: double.infinity,
                      ),
                      colorOpacity: 0.1,
                    ),
                    Center(
                      child: ListTile(
                        onTap: () async {
                          String url = defaultTargetPlatform ==
                                  TargetPlatform.android
                              ? "https://play.google.com/store/apps/details?id=ai.hotg.runicapp&hl=en_US&gl=US"
                              : "https://apps.apple.com/be/app/runic-by-hotg-ai/id1550831458";
                          await canLaunch(url)
                              ? await launch(url, forceSafariVC: false)
                              : throw 'Could not launch $url';
                        },
                        trailing: Image.asset(
                          defaultTargetPlatform == TargetPlatform.iOS ||
                                  defaultTargetPlatform == TargetPlatform.macOS
                              ? "assets/images/btn-apple.png"
                              : "assets/images/btn-google.png",
                          width: 120,
                        ),
                        title: Text(
                          "Download Runic App",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                            "By downloading our test app you can test out the models live on the edge! Both on IOS and Android",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300)),
                      ),
                    ),
                    Positioned(
                        right: -10,
                        top: -10,
                        width: 42,
                        height: 42,
                        child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            })),
                  ]))));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      showed = true;
    }
  }

  @override
  dispose() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    RuneScreen.logs.disconnect();
    super.dispose();
  }
}
