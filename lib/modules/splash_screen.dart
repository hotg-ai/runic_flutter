import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  static int screen = 0;
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

const AUTH0_DOMAIN = 'dev-1qev9owo.us.auth0.com';
final authorizationEndpoint = Uri.parse('https://$AUTH0_DOMAIN/authorize');
final tokenEndpoint = Uri.parse('https://$AUTH0_DOMAIN/oauth/token');

const AUTH0_CLIENT_ID = 'S71L2EvzSTEiSAuEXg4D0wk6KCuMOr6f';

const AUTH0_REDIRECT_URI = 'com.auth0.flutterdemo://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';

class _SplashScreenState extends State<SplashScreen> {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    login();
    super.initState();
  }

  login() async {
    try {
      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: ['openid', 'profile', 'offline_access'],
          // promptValues: ['login']
        ),
      );
      final idToken = parseIdToken(result!.idToken!);
      final profile = await getUserDetails(result.accessToken!);

      await secureStorage.write(
          key: 'refresh_token', value: result.refreshToken);

      print(idToken);
      print(profile);
      setState(() {
        //isBusy = false;
        //isLoggedIn = true;
        //name = idToken['name'];
        //picture = profile['picture'];
      });
    } catch (e, s) {
      print('login error: $e - stack: $s');
    }
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    final url = Uri.parse('https://$AUTH0_DOMAIN/userinfo');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

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
                      onPressed: () {}),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {}),
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
                      child: Center(
                          child: Text(
                    "What's in a rune?",
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
                        "Rune is an orchestration tool for specifying how data should be processed, with an emphasis on the machine learning world, in a way which is portable and robust.",
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
                      onPressed: () {}),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {}),
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
                        "Accelerate development of TinyML apps with Rune",
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
                        "Rune is a tiny container specifically designed to help you containerize TinyML applications across several platforms and devices. It is like docker but tinier.",
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
                        onPressed: () {
                          SplashScreen.screen = 0;
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
                      onPressed: () {}),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                      icon: Image.asset(
                        "assets/images/icons/github.png",
                        width: 28,
                      ),
                      onPressed: () {}),
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
                      child: Center(
                          child: Text(
                    "Welcome To RUNE",
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
                        "Welcome to tinyVerse by HOTG, where we will muse about tinyML and Machine Learning on tiny devices.",
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
