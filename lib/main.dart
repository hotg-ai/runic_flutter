// @dart=2.9
import 'package:flutter/material.dart';
import 'package:runic_mobile/rune/runic.dart';
import 'rune/registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Runic.fetchRegistry();
  runApp(RunicApp());
}

class RunicApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RunicMainPage(title: 'Runic'),
    );
  }
}

class RunicMainPage extends StatefulWidget {
  RunicMainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RunicMainPageState createState() => _RunicMainPageState();
}

class _RunicMainPageState extends State<RunicMainPage> {
  @override
  Widget build(BuildContext context) {
    return (Runic.runes.length > 0)
        ? Registry(registry: Runic.runes)
        : Container(color: Color.fromRGBO(59, 188, 235, 1));
  }
}
