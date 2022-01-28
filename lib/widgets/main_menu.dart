import 'dart:typed_data';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:runevm_fl/runevm_fl.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/utils/navigation_bar_clipper.dart';

class MainMenu extends StatelessWidget {
  final Function preLoad;
  final config = {"hide": false};
  MainMenu({Key? key, this.preLoad = _myDefaultFunc}) : super(key: key);
  static String currentRoute = "home";
  static _myDefaultFunc() async {
    return null;
  }

  void _navigateTo(BuildContext context, String route) {
    if (currentRoute == route) {
      //same route do nothing
    } else {
      currentRoute = route;
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: 110,
        child: Stack(children: <Widget>[
          Container(),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 32,
              child: Blur(
                  blur: 3.5,
                  blurColor: darkBlueBlue,
                  colorOpacity: 0.0,
                  child: Container())),
          Material(
              color: Colors.transparent,
              child: config["hide"]!
                  ? Container()
                  : ClipPath(
                      clipper: NavigationBarClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              darkGreyBlue,
                              darkBlueBlue,
                              darkGreyBlue80,
                            ])),
                        child: Stack(children: <Widget>[
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              top: 60,
                              child: Container()),
                          Positioned(
                              bottom: 28,
                              left: 1 * MediaQuery.of(context).size.width / 6 -
                                  28,
                              height: 28,
                              child: IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  onPressed: () {
                                    _navigateTo(context, 'history');
                                  },
                                  icon: Opacity(
                                      opacity:
                                          currentRoute == "history" ? 1.0 : 0.5,
                                      child: Image.asset(
                                        "assets/images/icons/icon_history.png",
                                      )))),
                          Positioned(
                              bottom: 28,
                              left: 2 * MediaQuery.of(context).size.width / 6 -
                                  28,
                              height: 28,
                              child: IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  onPressed: () {
                                    _navigateTo(context, 'posts');
                                  },
                                  icon: Opacity(
                                      opacity:
                                          currentRoute == "posts" ? 1.0 : 0.5,
                                      child: Image.asset(
                                        "assets/images/icons/icon_chart.png",
                                      )))),
                          Positioned(
                              bottom: 28,
                              left: 4 * MediaQuery.of(context).size.width / 6 -
                                  14,
                              height: 28,
                              child: IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  onPressed: () {
                                    _navigateTo(context, 'deployed');
                                  },
                                  icon: Opacity(
                                      opacity: currentRoute == "deployed"
                                          ? 1.0
                                          : 0.5,
                                      child: Image.asset(
                                        "assets/images/icons/icon_model.png",
                                      )))),
                          Positioned(
                              bottom: 28,
                              left: 5 * MediaQuery.of(context).size.width / 6 -
                                  14,
                              height: 28,
                              child: IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  onPressed: () {
                                    _navigateTo(context, 'profile');
                                  },
                                  icon: Opacity(
                                      opacity:
                                          currentRoute == "profile" ? 1.0 : 0.5,
                                      child: Image.asset(
                                        "assets/images/icons/icon_user.png",
                                      )))),
                          Positioned(
                              top: -15,
                              left: MediaQuery.of(context).size.width / 2 - 60,
                              height: 120,
                              width: 120,
                              child: Container(
                                  width: 50,
                                  child: IconButton(
                                      iconSize: 50,
                                      splashRadius: 50,
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      onPressed: () async {
                                        config["hide"] = true;
                                        await preLoad();
                                        _navigateTo(context, "home");
                                      },
                                      icon: Opacity(
                                          opacity: currentRoute == "home"
                                              ? 1.0
                                              : 0.5,
                                          child: Image.asset(
                                            "assets/images/icons/icon_home.png",
                                          )))))
                        ]),
                      )))
        ]));
  }
}
