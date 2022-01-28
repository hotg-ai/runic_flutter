import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runic_flutter/config/theme.dart';

class ErrorScreen extends StatelessWidget {
  final String description;
  final Function onClose;
  ErrorScreen({Key? key, required this.description, required this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GlassmorphicContainer(
            margin: EdgeInsets.all(0),
            borderRadius: 0,
            blur: 12,
            border: 0,
            linearGradient: LinearGradient(colors: [
              Colors.black.withAlpha(25),
              Colors.white.withAlpha(15)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderGradient: LinearGradient(
                colors: [darkBackGroundColor, darkBackGroundColor]),
            width: double.infinity,
            height: double.infinity,
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  padding: EdgeInsets.all(25),
                  child: Center(
                      child: Text(
                    "ERROR",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ))),
              Center(
                child: Container(
                    width: 128,
                    height: 128,
                    child: Image.asset("assets/images/icons/error.png")),
              ),
              Container(
                  padding: EdgeInsets.all(25),
                  child: Center(
                      child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ))),
              Center(
                  child: Container(
                height: 42,
                width: 128,
                margin: EdgeInsets.only(top: 11, bottom: 11),
                decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
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
                    'OK',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () {
                    onClose();
                  },
                ),
              ))
            ]))));
  }
}
