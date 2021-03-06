import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/core/logs.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_depot.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/rune_screen.dart';
import 'package:runic_flutter/utils/error_screen.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/utils/navigation_bar_clipper.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:blur/blur.dart';
import 'package:runic_flutter/widgets/barcode_scanner.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> searchList = [];
  bool _loading = false;
  bool _error = false;
  String _loadingProgress = "";
  String _loadingDescription = "";
  @override
  void initState() {
    super.initState();
    fetchRegistry();
    login();
  }

  void fetchRegistry() async {
    await Registry.fetchRegistry();
    setState(() {
      searchList = Registry.runes;
    });
  }

  void showDownload() async {
    if (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      SnackBar snackBar = SnackBar(
          elevation: 0,
          duration: Duration(seconds: 4),
          backgroundColor: Colors.transparent,
          content: Container(
              height: 240,
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 130),
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                    ),
                    Blur(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        width: double.infinity,
                      ),
                      colorOpacity: 0.2,
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
                          width: 100,
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
                    )
                  ]))));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void login() async {
    if (!kIsWeb) {
      await HFAuth.init();
      if (HFAuth.isLoggedIn) {
        print("AUTH0logged in with ${HFAuth.profile}");
      } else {
        //await HFAuth.login();
      }
      setState(() {});
    }
  }

  String searchString = "";
  TextEditingController textController = new TextEditingController();
  TextEditingController urlTextController =
      new TextEditingController(text: "https://");
  void search() {
    searchList = Registry.runes
        .where((element) =>
            "$element".toLowerCase().contains(searchString.toLowerCase()))
        .toList();
    setState(() {});
  }

  void qrCodeResult(String result) {
    //set url
    urlTextController.text = result;
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Background(),
      Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leadingWidth: 12,
          backgroundColor: Colors.transparent,
          leading: Container(),
          title: Text(
            'Welcome To the Runic Mobile App',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          actions: [
            /*IconButton(
                icon: Image.asset(
                  "assets/images/icons/notification.png",
                  width: 16,
                ),
                onPressed: () {
                  //Navigator.pushNamed(context, "history");
                }),*/
            kIsWeb
                ? Center(
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
                          showDownload();
                        }),
                  ))
                : Container(),
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
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        Clipboard.getData(Clipboard.kTextPlain)
                                            .then((value) {
                                          if (value != null) {
                                            if (value.text != null) {
                                              urlTextController.text =
                                                  value.text!;
                                              setState(() {});
                                            }
                                          }
                                          //value is clipbarod data
                                        });
                                      },
                                      padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                                      icon: Image.asset(
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
                            onPressed: () async {
                              if (!kIsWeb) {
                                if (await Permission.camera
                                    .request()
                                    .isGranted) {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BarcodeScanner(qrCodeResult)))
                                      .then((value) {
                                    //notifyParent();
                                  });
                                }
                              } else {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BarcodeScanner(qrCodeResult)))
                                    .then((value) {
                                  //notifyParent();
                                });
                              }
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
                      Registry.onUpdate = (int bytesIn, int totalBytes) {
                        _loadingProgress =
                            "${bytesIn > totalBytes ? 100 : (bytesIn / totalBytes * 100).round()}%";
                        _loadingDescription = "${(bytesIn / 1000).round()}Kb";
                        setState(() {});
                      };
                      setState(() {
                        _loading = true;
                      });
                      Logs log = new Logs();
                      RuneScreen.logs = log;
                      RuneEngine.runeBytes = await Registry.downloadWASM(
                          urlTextController.text, log);
                      if (RuneEngine.runeBytes == null) {
                        setState(() {
                          _loading = false;
                          _error = true;
                        });
                        return;
                      }
                      RuneEngine.runeMeta = {
                        "name": "/${urlTextController.text}".split("/").last,
                        "description": "Fetched Rune"
                      };
                      setState(() {
                        _loading = false;
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
                    child: GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: searchList.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= searchList.length) {
                          return Container();
                        }

                        return new InkWell(
                            onTap: () async {
                              setState(() {
                                _loading = true;
                              });
                              if (searchList[index]["cached"]) {
                                try {
                                  RuneEngine.runeBytes = (await RuneDepot.getRune(
                                      "${searchList[index]["name"]}_${searchList[index]["version"]}"))!;
                                } catch (e) {
                                  setState(() {
                                    _loading = false;
                                    return;
                                  });
                                }

                                RuneEngine.runeMeta = searchList[index];
                              } else {
                                Registry.onUpdate =
                                    (int bytesIn, int totalBytes) {
                                  _loadingProgress =
                                      "${bytesIn > totalBytes ? 100 : (bytesIn / totalBytes * 100).round()}%";
                                  _loadingDescription =
                                      "Fetching ${searchList[index]["name"]}";
                                  print("Received $bytesIn/$totalBytes");
                                  setState(() {});
                                };
                                RuneEngine.runeBytes = await Registry.downloadWASM(
                                    'https://rune-registry.web.app/registry/' +
                                        searchList[index]["name"] +
                                        '/rune.rune',
                                    null);
                                if (RuneEngine.runeBytes == null) {
                                  setState(() {
                                    _loading = false;
                                    _error = true;
                                  });
                                  return;
                                }
                                Registry.onUpdate =
                                    (int bytesIn, int totalBytes) {
                                  print("Received $bytesIn/$totalBytes");
                                };
                                _loadingProgress = "";
                                _loadingDescription = "";
                                RuneEngine.runeMeta = searchList[index];
                                await RuneDepot.addRune(
                                    RuneEngine.runeBytes!, RuneEngine.runeMeta,
                                    uuid:
                                        "${searchList[index]["name"]}_${searchList[index]["version"]}");
                                await Registry.fetchRegistry(force: true);
                                search();
                              }

                              setState(() {
                                _loading = false;
                              });
                              Navigator.pushNamed(
                                context,
                                'rune',
                              );
                            },
                            child: new Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: blackColor, width: 2),
                                  borderRadius: BorderRadius.circular(19.0),
                                ),
                                color: blackColor.withAlpha(0),
                                margin: EdgeInsets.all(0),
                                shadowColor: blackColor,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  child: new GridTile(
                                      footer: Container(
                                          padding: EdgeInsets.only(bottom: 5),
                                          child: Row(children: [
                                            Expanded(child: Container()),
                                            searchList[index]["cached"]
                                                ? Icon(
                                                    Icons.cached,
                                                    color: Colors.white
                                                        .withAlpha(100),
                                                    size: 12,
                                                  )
                                                : Container(),
                                            Container(
                                              width: 10,
                                            )
                                          ])),
                                      child: Container(
                                          child: Opacity(
                                              opacity: 0.8,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: (searchList[index]
                                                        .containsKey("img"))
                                                    ? Image.network(
                                                        searchList[index]["img"]
                                                            ["src"],
                                                        fit: BoxFit.cover,
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                      )
                                                    : Image.asset(
                                                        "assets/images/rune_placeholder.png",
                                                        fit: BoxFit.cover,
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                      ),
                                              ))),
                                      header: Container(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: new Text(
                                                    searchList[index]['name'],
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ), //just for testing, will fill with image later
                                                )
                                              ]))),
                                )));
                      },
                    )),
                Container(height: 80)
              ],
            )),
      ),
      MainMenu(),
      _loading
          ? LoadingScreen(
              progress: _loadingProgress,
              description: _loadingDescription,
            )
          : Container(),
      _error
          ? ErrorScreen(
              description: "Error fetching and deploying rune",
              onClose: () {
                setState(() {
                  _error = false;
                });
              })
          : Container()
    ]);
  }
}
