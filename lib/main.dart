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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  }
}
