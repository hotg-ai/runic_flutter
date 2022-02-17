import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  static int screen = 0;

  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

  void checkFirstTime() async {
    final firstTime = await secureStorage.read(key: 'is_first_time');
    print("firsttime: $firstTime");
    if (firstTime != null) {
      if (firstTime == "false") {
        SplashScreen.screen = 0;
        Navigator.pushNamed(context, "home");
      }
    }
  }

  linkToDiscord() {
    _launchURL("https://discord.gg/ZB4sv28fbh");
  }

  linkToGithub() {
    _launchURL("https://github.com/hotg-ai");
  }

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url, forceSafariVC: false)
      : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    switch (SplashScreen.screen) {
      case 1:
        return Stack(children: [
          Background(
            screen: Screen.splash,
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                leadingWidth: 42,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/discord.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToDiscord();
                      }),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToGithub();
                      }),
                ],
              ),
              body: ListView(
                children: [
                  Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(60, 72, 60, 20),
                          width: 320,
                          child:
                              Image.asset("assets/images/splash/img_2.png"))),
                  Container(
                    height: 42,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                      child: Center(
                          child: Text(
                        "Developer experience for edge computing",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ))),
                  Container(
                    height: 12,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 20, 60, 60),
                      child: Center(
                          child: Text(
                        "We are building the developer experience tools and infrastructure for edge computing. Our goal is to make this space accessible to anyone in the world by building open systems that our community loves.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ))),
                  Center(
                      child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: darkBackGroundColor.withAlpha(100),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              indigoBlueColor.withAlpha(250),
                              indigoBlueColor.withAlpha(150),
                              barneyPurpleColor.withAlpha(60),
                            ],
                            stops: [
                              0,
                              0.5,
                              1.0
                            ])),
                    width: 64,
                    height: 64,
                    child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 24),
                        splashColor: Colors.white,
                        splashRadius: 21,
                        onPressed: () {
                          SplashScreen.screen++;
                          Navigator.pushNamed(context, "splash");
                        }),
                  )),
                ],
              )),
        ]);
      case 2:
        return Stack(children: [
          Background(
            screen: Screen.splash,
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                leadingWidth: 42,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/discord.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToDiscord();
                      }),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToGithub();
                      }),
                ],
              ),
              body: ListView(
                children: [
                  Container(
                    height: 72,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                      child: Center(
                          child: Text(
                        "Develop at warp speed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ))),
                  Container(
                    height: 12,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 20, 60, 10),
                      child: Center(
                          child: Text(
                        "Accelerate development of edge AI with portable Rune containers.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ))),
                  Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(60, 20, 60, 20),
                          width: 320,
                          child:
                              Image.asset("assets/images/splash/img_3.png"))),
                  Center(
                      child: Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: darkBackGroundColor.withAlpha(100),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              indigoBlueColor.withAlpha(250),
                              indigoBlueColor.withAlpha(150),
                              barneyPurpleColor.withAlpha(60),
                            ],
                            stops: [
                              0,
                              0.5,
                              1.0
                            ])),
                    child: TextButton(
                        child: Text(
                          "Get started",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          SplashScreen.screen = 0;
                          await secureStorage.write(
                              key: 'is_first_time', value: "false");
                          Navigator.pushNamed(context, "home");
                        }),
                  )),
                ],
              )),
        ]);
      default:
        return Stack(children: [
          Background(
            screen: Screen.splash,
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                leadingWidth: 42,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/discord.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToDiscord();
                      }),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {
                        linkToGithub();
                      }),
                ],
              ),
              body: ListView(
                children: [
                  Center(
                      child: Container(
                          width: 320,
                          child:
                              Image.asset("assets/images/splash/img_1.png"))),
                  Container(
                    height: 42,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                      child: Center(
                          child: Text(
                        "Deploy on-device ML within minutes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ))),
                  Container(
                    height: 12,
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(60, 20, 60, 60),
                      child: Center(
                          child: Text(
                        "Build and test an edge computing app within minutes using Hammer Forge.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ))),
                  Center(
                      child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: darkBackGroundColor.withAlpha(100),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              indigoBlueColor.withAlpha(250),
                              indigoBlueColor.withAlpha(150),
                              barneyPurpleColor.withAlpha(60),
                            ],
                            stops: [
                              0,
                              0.5,
                              1.0
                            ])),
                    width: 64,
                    height: 64,
                    child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 24),
                        splashColor: Colors.white,
                        splashRadius: 21,
                        onPressed: () {
                          SplashScreen.screen++;
                          Navigator.pushNamed(context, "splash");
                        }),
                  )),
                ],
              )),
        ]);
    }
  }
}
