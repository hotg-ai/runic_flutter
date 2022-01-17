import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runic_flutter/config/theme.dart';
import 'package:runic_flutter/modules/log_screen.dart';

class LoadingScreen extends StatelessWidget {
  String progress;
  String description;
  LoadingScreen({Key? key, this.progress = "", this.description = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          GlassmorphicContainer(
            margin: EdgeInsets.all(0),
            borderRadius: 84,
            blur: 4,
            border: 0,
            linearGradient: LinearGradient(colors: [
              Colors.white.withAlpha(25),
              Colors.white.withAlpha(15)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderGradient: LinearGradient(
                colors: [darkBackGroundColor, darkBackGroundColor]),
            width: 128,
            height: 128,
            child: Center(
                child: Stack(children: [
              Container(
                  width: 128,
                  height: 128,
                  child: LoadingIndicator(
                      indicatorType: Indicator.orbit,

                      /// Required, The loading type of the widget
                      colors: [darkBlueBlue],

                      /// Optional, The color collections
                      strokeWidth: 2,

                      /// Optional, The stroke of the line, only applicable to widget which contains line
                      backgroundColor: Colors.transparent,

                      /// Optional, Background of the widget
                      pathBackgroundColor: Colors.transparent

                      /// Optional, the stroke backgroundColor
                      )),
              Center(
                  child: Text(
                progress,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ))
            ])),
          ),
          Center(
              child: Text(
            description,
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
          runTimeLogs(context)
        ])));
  }

  Widget runTimeLogs(BuildContext context) {
    return Container(
      height: 42,
      margin: EdgeInsets.only(top: 11, bottom: 11),
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
        child: new Icon(
          Icons.format_list_bulleted,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogScreen()),
          );
        },
      ),
    );
  }
}
