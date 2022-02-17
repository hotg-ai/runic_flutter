import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/deployed_screen.dart';
import 'package:runic_flutter/modules/history_screen.dart';
import 'package:runic_flutter/modules/home_screen.dart';
import 'package:runic_flutter/modules/posts_screen.dart';
import 'package:runic_flutter/modules/profile_screen.dart';
import 'package:runic_flutter/modules/rune_screen.dart';
import 'package:runic_flutter/modules/splash_screen.dart';
import 'package:runic_flutter/modules/url_loading_screen.dart';
import 'dart:async';
import 'dart:io';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

void main() async {
  if (kIsWeb) {
    //check if rune url parameter is present.
    String uri = Uri.base.query;
    print(uri);
    List<String> parts = uri.split("url=");
    print(parts);
    if (parts.length == 2) {
      RuneEngine.url = parts[1];
      print(RuneEngine.url);
    }
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

StreamSubscription? _sub;
Future<void> initUniLinks(BuildContext context) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      RuneEngine.url = initialLink;
    }
    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        RuneEngine.url = link;
        Navigator.pushNamed(context, "url");
      }
      // Use the uri and warn the user, if it is not correct
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
  return;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ;
    return FutureBuilder<void>(
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return MaterialApp(
          theme: ThemeData(fontFamily: 'Inconsolata'),
          initialRoute: RuneEngine.url != null ? 'url' : 'splash',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case 'home':
                return PageTransition(
                    child: HomeScreen(),
                    type: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0));
              case 'profile':
                return PageTransition(
                    child: ProfileScreen(),
                    type: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0));
              case 'history':
                return PageTransition(
                    child: HistoryScreen(),
                    type: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0));
              case 'deployed':
                return PageTransition(
                    child: DeployedScreen(),
                    type: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0));
              case 'posts':
                return PageTransition(
                    child: PostsScreen(),
                    type: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0));
              default:
                return null;
            }
          },
          routes: {
            'splash': (context) => SplashScreen(),
            'rune': (context) => RuneScreen(),
            'url': (context) => URLLoadingScreen(),
            //'home': (context) => HomeScreen(),
            //'profile': (context) => ProfileScreen(),
            //'history': (context) => HistoryScreen(),
            //'posts': (context) => PostsScreen(),
            //'deployed': (context) => DeployedScreen()
          },
        );
      },
      future: initUniLinks(context),
    );
  }
}
