import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';
import 'package:webviewx/webviewx.dart';

class PostsScreen extends StatefulWidget {
  PostsScreen({Key? key}) : super(key: key);

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
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
            leading: Container(),
            title: Text(
              'Tinyverse',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: [
              IconButton(
                  icon: Image.asset(
                    "assets/images/icons/notification.png",
                    width: 16,
                  ),
                  onPressed: () {}),
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        barneyPurpleColor.withAlpha(150),
                        indigoBlueColor.withAlpha(150),
                      ],
                    )),
                width: 30,
                height: 30,
                child: IconButton(
                    icon: Icon(Icons.segment, size: 16),
                    splashColor: Colors.white,
                    splashRadius: 21,
                    onPressed: () {}),
              )),
              Container(
                width: 10,
              )
            ],
          ),
          body: Container(
              height: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: WebViewX(
                  height: double.infinity,
                  width: double.infinity,
                  initialContent: "https://tinyverse.substack.com/"))),
      MainMenu()
    ]);
  }
}
