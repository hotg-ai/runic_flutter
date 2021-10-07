import 'package:flutter/material.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/registry.dart';
import 'package:runic_flutter/core/rune_engine.dart';
import 'package:runic_flutter/utils/loading_screen.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class URLLoadingScreen extends StatefulWidget {
  URLLoadingScreen({Key? key}) : super(key: key);

  @override
  _URLLoadingScreenState createState() => _URLLoadingScreenState();
}

class _URLLoadingScreenState extends State<URLLoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRune();
  }

  loadRune() async {
    RuneEngine.runeBytes = await Registry.downloadWASM(RuneEngine.url!);
    RuneEngine.runeMeta = {
      "name": "/${RuneEngine.url!}".split("/").last,
      "description": "Rune"
    };
    Navigator.pushNamed(
      context,
      'rune',
    );
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
    ]);
  }
}
