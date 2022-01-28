import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/analytics.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    refreshHistory();
    super.initState();
  }

  List<String> dateStamps = [];
  void refreshHistory() async {
    await Analytics.getHistory();
    dateStamps = List.from(Analytics.history.keys);
    dateStamps.sort((a, b) {
      return int.parse(a) > int.parse(b) ? -1 : 1;
    });
    setState(() {});
  }

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
            leading: Container(),
            backgroundColor: Colors.transparent,
            title: Text(
              'History',
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
                  itemCount: dateStamps.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: new Card(
                            shape: RoundedRectangleBorder(
                              //side: BorderSide(color: Colors.white.withAlpha(50), width: 2),
                              side: BorderSide(
                                  color: Colors.white.withAlpha(30), width: 1),
                              borderRadius: BorderRadius.circular(19.0),
                            ),
                            color: Colors.white.withAlpha(0),
                            margin: EdgeInsets.all(0),
                            child: Container(
                              //margin: EdgeInsets.fromLTRB(4, 4, 4, 4),
                              height: 60,
                              //padding: EdgeInsets.all(3),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Container(
                                      color: Colors.white.withAlpha(30),
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: Stack(children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      21, 24, 0, 0),
                                                  child: Text(
                                                    "${Analytics.history[dateStamps[index]]}",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Container(
                                            padding: EdgeInsets.fromLTRB(
                                                21, 2, 0, 0),
                                            child: Text(
                                                "${DateTime.fromMillisecondsSinceEpoch(int.parse(dateStamps[index])).toLocal()}",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w200,
                                                    color: Colors.white)))
                                      ]))),
                            )));
                  }))),
      MainMenu()
    ]);
  }
}
