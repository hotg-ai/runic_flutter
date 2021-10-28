import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_depot.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';

import 'package:runic_flutter/widgets/barcode_scanner.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class DeployedScreen extends StatefulWidget {
  DeployedScreen({Key? key}) : super(key: key);
  @override
  _DeployedScreenState createState() => _DeployedScreenState();
}

class _DeployedScreenState extends State<DeployedScreen> {
  List<dynamic> searchList = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    fetchRunes();
  }

  Future<void> fetchRunes() async {
    await RuneDepot.getRunes();
    print("fetch Runes");
    setState(() {
      search();
    });
  }

  String searchString = "";
  TextEditingController textController = new TextEditingController();
  TextEditingController urlTextController =
      new TextEditingController(text: "https://");
  void search() {
    searchList = RuneDepot.runes!
        .where((element) =>
            "$element".toLowerCase().contains(searchString.toLowerCase()))
        .toList();
    setState(() {});
  }

  void qrCodeResult(String result) {
    //set url
    urlTextController.text = result;
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
          leadingWidth: 12,
          backgroundColor: Colors.transparent,
          leading: Container(),
          title: Text(
            'Your deployed runes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ListView(
              shrinkWrap: true,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 38,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: glassRunic(
                        Container(
                            margin: EdgeInsets.fromLTRB(13, 0, 5, 0),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: urlTextController,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 0.0),
                                  suffixIconConstraints: BoxConstraints(
                                      maxWidth: 36,
                                      minWidth: 36,
                                      maxHeight: 36),
                                  suffixIcon: Container(
                                      padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                                      child: Image.asset(
                                        "assets/images/icons/paste.png",
                                        height: 14,
                                      )),
                                  hintStyle: TextStyle(
                                      color: whiteAlpha, fontSize: 15),
                                  hintText:
                                      'Your Rune URL (you can fetch them locally)'),
                            )),
                      )),
                      Container(
                        width: 10.5,
                      ),
                      glassRunic(
                          RawMaterialButton(
                            fillColor: whiteAlpha.withAlpha(30),
                            constraints: BoxConstraints(),
                            onPressed: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BarcodeScanner(qrCodeResult)))
                                  .then((value) {
                                //notifyParent();
                              });
                            },
                            elevation: 0.0,
                            //fillColor: whiteAlpha,
                            child: Image.asset("assets/images/icons/qr.png"),
                            padding: EdgeInsets.all(9.0),
                          ),
                          border: 0.0,
                          width: 38.0,
                          height: 38.0)
                    ],
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  height: 42,
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
                      'Fetch and Deploy',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });

                      RuneEngine.runeBytes =
                          await Registry.downloadWASM(urlTextController.text);
                      RuneEngine.runeMeta = {
                        "name": "/${urlTextController.text}".split("/").last,
                        "description": "Fetched Rune"
                      };
                      RuneDepot.addRune(
                          RuneEngine.runeBytes, RuneEngine.runeMeta);
                      await fetchRunes();
                      setState(() {
                        loading = false;
                      });
                      Navigator.pushNamed(
                        context,
                        'rune',
                      );
                    },
                  ),
                ),
                Container(
                  height: 30,
                ),
                Container(
                  child: Text(
                    'Your Runes',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w200),
                  ),
                ),
                Container(
                  height: 10,
                ),
                Container(
                  height: 38,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: glassRunic(Container(
                              margin: EdgeInsets.fromLTRB(13, 0, 5, 0),
                              child: TextField(
                                controller: textController,
                                onChanged: (text) {
                                  searchString = text;
                                  search();
                                },
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 0.0),
                                    prefixIconConstraints: BoxConstraints(
                                        maxWidth: 24,
                                        minWidth: 24,
                                        maxHeight: 36),
                                    prefixIcon: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 6, 8, 6),
                                        child: Image.asset(
                                          "assets/images/icons/search.png",
                                          height: 18,
                                        )),
                                    hintStyle: TextStyle(
                                        color: whiteAlpha, fontSize: 15),
                                    hintText: 'Search'),
                              )))),
                      Container(
                        width: 10.5,
                      ),
                      glassRunic(
                          RawMaterialButton(
                            fillColor: whiteAlpha.withAlpha(30),
                            constraints: BoxConstraints(),
                            onPressed: () {
                              textController.clear();
                              searchString = "";
                              search();
                              setState(() {});
                            },
                            elevation: 0.0,
                            //fillColor: whiteAlpha,
                            child:
                                Image.asset("assets/images/icons/filter.png"),
                            padding: EdgeInsets.all(9.0),
                          ),
                          border: 0.0,
                          width: 38.0,
                          height: 38.0)
                    ],
                  ),
                ),
                Container(
                  height: 15,
                ),
                Container(
                    padding: EdgeInsets.all(0),
                    //height: 2000,
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: searchList.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= searchList.length) {
                          return Container();
                        }
                        return Container(
                            height: 120,
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            width: double.infinity,
                            child: new InkWell(
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });

                                  RuneEngine.runeBytes =
                                      (await RuneDepot.getRune(
                                          searchList[index]["uuid"]))!;
                                  RuneEngine.runeMeta = searchList[index];

                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.pushNamed(
                                    context,
                                    'rune',
                                  );
                                },
                                child: new Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.white.withAlpha(20),
                                          width: 0),
                                      borderRadius: BorderRadius.circular(19.0),
                                    ),
                                    color: Colors.white.withAlpha(20),
                                    margin: EdgeInsets.all(0),
                                    shadowColor: blackColor,
                                    child: Container(
                                      padding: EdgeInsets.all(0),
                                      child: new GridTile(
                                        child: Container(
                                            child: Opacity(
                                                opacity: 0.8,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: Row(children: [
                                                      Expanded(
                                                        child: (searchList[
                                                                    index]
                                                                .containsKey(
                                                                    "img"))
                                                            ? Image.network(
                                                                searchList[index]
                                                                        ["img"]
                                                                    ["src"],
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: double
                                                                    .infinity,
                                                                width: double
                                                                    .infinity,
                                                              )
                                                            : Image.asset(
                                                                "assets/images/rune_placeholder.png",
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: double
                                                                    .infinity,
                                                                width: double
                                                                    .infinity,
                                                              ),
                                                      ),
                                                      Expanded(
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          12.0),
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                        child:
                                                                            Container()),
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          new Text(
                                                                        searchList[index]
                                                                            [
                                                                            'name'],
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ), //just for testing, will fill with image later
                                                                    ),
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          new Text(
                                                                        searchList[index]
                                                                            [
                                                                            'timestamp'],
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w200),
                                                                      ), //just for testing, will fill with image later
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            Container())
                                                                  ])))
                                                    ])))),
                                      ),
                                    ))));
                      },
                    )),
                Container(height: 80)
              ],
            )),
      ),
      MainMenu(),
      loading ? LoadingScreen() : Container(),
    ]);
  }
}
