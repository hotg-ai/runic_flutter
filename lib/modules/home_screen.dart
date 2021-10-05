import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/rune_screen.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/utils/navigation_bar_clipper.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:blur/blur.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> searchList = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    fetchRegistry();
  }

  void fetchRegistry() async {
    await Registry.fetchRegistry();
    setState(() {
      searchList = Registry.runes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'Welcome To the Rune Tinyverse',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(top: 0.0),
                                    suffixIconConstraints: BoxConstraints(
                                        maxWidth: 36,
                                        minWidth: 36,
                                        maxHeight: 36),
                                    suffixIcon: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 6, 0, 6),
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
                              onPressed: () {},
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
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Container(
                    child: Text(
                      'Checkout our Runes',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    child: Text(
                      'These are the ones we made for you',
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
                              onPressed: () {},
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
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          child: GridView.builder(
                            itemCount: searchList.length + 2,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 320,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8),
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= searchList.length) {
                                return Container();
                              }
                              return new InkWell(
                                  onTap: () async {
                                    print(searchList[index]);
                                    setState(() {
                                      loading = true;
                                    });

                                    RuneEngine.runeBytes =
                                        await Registry.downloadWASM(
                                            'https://rune-registry.web.app/registry/' +
                                                searchList[index]["name"] +
                                                '/rune.rune');
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
                                            color: blackColor, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(19.0),
                                      ),
                                      color: blackColor.withAlpha(0),
                                      margin: EdgeInsets.all(0),
                                      shadowColor: blackColor,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        child: new GridTile(
                                            child: Container(
                                                child: Opacity(
                                                    opacity: 0.8,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      child: (searchList[index]
                                                              .containsKey(
                                                                  "img"))
                                                          ? Image.network(
                                                              searchList[index]
                                                                      ["img"]
                                                                  ["src"],
                                                              fit: BoxFit.cover,
                                                              height: double
                                                                  .infinity,
                                                              width: double
                                                                  .infinity,
                                                            )
                                                          : Image.asset(
                                                              "assets/images/rune_placeholder.png",
                                                              fit: BoxFit.cover,
                                                              height: double
                                                                  .infinity,
                                                              width: double
                                                                  .infinity,
                                                            ),
                                                    ))),
                                            header: Container(
                                                padding: EdgeInsets.all(12.0),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: new Text(
                                                          searchList[index]
                                                              ['name'],
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ), //just for testing, will fill with image later
                                                      )
                                                    ]))),
                                      )));
                            },
                          ))),
                  //Container(height: 80)
                ],
              )),
          MainMenu(),
          loading ? LoadingScreen() : Container(),
        ]));
  }
}
