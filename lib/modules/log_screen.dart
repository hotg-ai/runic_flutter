import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/analytics.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:share_plus/share_plus.dart';

class LogScreen extends StatefulWidget {
  LogScreen({Key? key}) : super(key: key);

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<dynamic> logs = [];
  @override
  void initState() {
    refreshLogs();
    super.initState();
  }

  void refreshLogs() async {
    logs = (await RuneEngine.getLogs()).toList();
    setState(() {});
    Future.delayed(Duration(milliseconds: 500), () {
      _controller.jumpTo(_controller.position.maxScrollExtent + 1000);
    });
  }

  final _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Background(),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            leadingWidth: 42,
            backgroundColor: Colors.transparent,
            title: Text(
              'Rune Logs',
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
          body: Container(
              padding: EdgeInsets.fromLTRB(21, 21, 21, 21),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: logs.length + 1,
                  controller: _controller,
                  itemBuilder: (BuildContext ctxt, int index) {
                    if (index == logs.length) {
                      return Container(
                          height: 100,
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  String text = "";
                                  for (String line in logs) {
                                    text = text + line + "\n";
                                  }
                                  Share.share(text);
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 21,
                                )),
                          ));
                    }
                    List<String> fields = "${logs[index]}".split("@@");
                    if (fields.length < 3) {
                      try {
                        Map<dynamic, dynamic> jsonFields =
                            jsonDecode("${logs[index]}");
                        if (jsonFields.containsKey("message")) {
                          return ListTile(
                            visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                            contentPadding: EdgeInsets.all(0),
                            minVerticalPadding: 0,
                            dense: true,
                            leading: Text(
                              jsonFields["level"],
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 10,
                                  leadingDistribution:
                                      TextLeadingDistribution.proportional,
                                  //height: 1,
                                  fontFamily: "Open sans",
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            title: Container(
                                child: Text(
                              jsonFields["message"] +
                                  " [${jsonFields["target"]}]",
                              style: TextStyle(
                                  fontSize: 10,

                                  //height: 1,
                                  fontFamily: "Open sans",
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )),
                          );
                        }
                      } catch (e) {}
                      return Container();
                    }
                    return ListTile(
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: EdgeInsets.all(0),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: Text(
                        fields[0],
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 10,
                            leadingDistribution:
                                TextLeadingDistribution.proportional,
                            //height: 1,
                            fontFamily: "Open sans",
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      title: Container(
                          child: Text(
                        fields[2] + " [${fields[1]}]",
                        style: TextStyle(
                            fontSize: 10,

                            //height: 1,
                            fontFamily: "Open sans",
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      )),
                    );
                    /*return Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Text(
                          "${logs[index]}",
                          style: TextStyle(
                              fontSize: 10,
                              leadingDistribution:
                                  TextLeadingDistribution.proportional,
                              //height: 1,
                              fontFamily: "Open sans",
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ));*/
                  }))),
    ]);
  }
}
