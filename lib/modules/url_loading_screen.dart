import 'package:blur/blur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/logs.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/utils/error_screen.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class URLLoadingScreen extends StatefulWidget {
  URLLoadingScreen({Key? key}) : super(key: key);

  @override
  _URLLoadingScreenState createState() => _URLLoadingScreenState();
}

class _URLLoadingScreenState extends State<URLLoadingScreen> {
  bool _error = false;
  bool loaded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRune();
  }

  loadRune() async {
    Logs log = new Logs();
    RuneEngine.runeBytes = await Registry.downloadWASM(RuneEngine.url!, log);
    if (RuneEngine.runeBytes == null) {
      setState(() {
        _error = true;
      });
      return;
    }
    RuneEngine.runeMeta = {
      "name": "/${RuneEngine.url!}".split("/").last,
      "description": "Rune"
    };
    loaded = true;
    Navigator.pushNamed(
      context,
      'rune',
    ).then((value) {
      Navigator.pushNamed(
        context,
        'home',
      );
    });
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
            leadingWidth: 42,
            backgroundColor: Colors.transparent,
            title: Center(
                child: Text(
              'Fetching and Loading Rune',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )),
          ),
          body: LoadingScreen()),
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
