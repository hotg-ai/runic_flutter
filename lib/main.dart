import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/modules/home_screen.dart';
import 'package:runic_flutter/modules/profile_screen.dart';
import 'package:runic_flutter/modules/rune_screen.dart';
import 'package:runic_flutter/modules/splash_screen.dart';

void main() async {
  if (kIsWeb) {
    String para1 = Uri.base.path;
    print(para1); //get parameter with attribute "para1"
  }
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'splash',
      routes: {
        'splash': (context) => SplashScreen(),
        'home': (context) => HomeScreen(),
        'profile': (context) => ProfileScreen(),
        'rune': (context) => RuneScreen()
      },
    );
  }
}
