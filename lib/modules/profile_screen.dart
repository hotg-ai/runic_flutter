import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/core/hf_auth.dart';
import 'package:runic_flutter/widgets/background.dart';
import 'package:runic_flutter/widgets/main_menu.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              'Profile',
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
          body: ListView(
            children: [
              HFAuth.isLoggedIn && HFAuth.profile.containsKey("picture")
                  ? new Center(
                      child: Container(
                          margin: EdgeInsets.all(21),
                          width: 64.0,
                          height: 64.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      HFAuth.profile["picture"])))))
                  : Container(),
              Center(
                  child: Text(
                HFAuth.isLoggedIn && HFAuth.profile.containsKey("name")
                    ? HFAuth.profile["name"]
                    : "Not logged in",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              )),
              Container(
                height: 42,
                margin:
                    EdgeInsets.only(top: 32, bottom: 11, left: 21, right: 21),
                decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20.5),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        charcoalGrey.withAlpha(125),
                        barneyPurpleColor.withAlpha(50),
                        indigoBlueColor.withAlpha(125),
                      ],
                    )),
                child: RawMaterialButton(
                  elevation: 4.0,
                  child: new Text(
                    !HFAuth.isLoggedIn ? 'Login' : 'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (HFAuth.isLoggedIn)
                      await HFAuth.logout();
                    else
                      await HFAuth.login();
                    setState(() {});
                  },
                ),
              )
            ],
          )),
      MainMenu()
    ]);
  }
}
