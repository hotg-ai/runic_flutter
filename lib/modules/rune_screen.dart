import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/result_screen.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/capabilities/image_capability_widget.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class RuneScreen extends StatefulWidget {
  RuneScreen({Key? key}) : super(key: key);

  @override
  _RuneScreenState createState() => _RuneScreenState();
}

class _RuneScreenState extends State<RuneScreen> {
  bool show = true;
  bool showRest = true;
  bool loading = false;

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    //if no rune is loaded go back to home screen
    if (RuneEngine.runeBytes.length == 0) {
      print("Falling back to home screen");
      Navigator.pushNamed(context, "home");
    } else {
      loadRune();
    }
  }

  Future<void> loadRune() async {
    setState(() {
      loading = true;
    });
    await Future.delayed(Duration(milliseconds: 20));
    await RuneEngine.load();

    setState(() {
      loading = false;
    });
    //print("_manifest: $_manifest");
  }

  _run() async {
    setState(() {
      loading = true;
    });
    await Future.delayed(Duration(milliseconds: 20));
    await RuneEngine.run();
    setState(() {
      loading = false;
    });
    if (RuneEngine.output["type"] != "String") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen()),
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
          body: Stack(children: [
            Container(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
                child: ListView.builder(
                    itemCount: 2 + RuneEngine.manifest.length,
                    itemBuilder: (context, index) {
                      if (index < RuneEngine.manifest.length) {
                        return Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: ImageCapabilityWidget(
                              cap: RuneEngine.capabilities[index],
                              notifyParent: refresh,
                              single: RuneEngine.capabilities.length <= 1,
                            ));
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

                      return Container();
                    })),
            loading ? LoadingScreen() : MainMenu()
          ]))
    ]);
  }
}
