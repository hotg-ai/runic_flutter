import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/modules/home_screen.dart';
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
      routes: {
        'splash': (context) => SplashScreen(),
        'home': (context) => HomeScreen(),
        'profile': (context) => ProfileScreen(),
        'rune': (context) => RuneScreen(),
        'url': (context) => URLLoadingScreen()
      },
    );
  }
}
