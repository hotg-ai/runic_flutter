import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:runic_flutter/config/theme.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GlassmorphicContainer(
      margin: EdgeInsets.all(0),
      borderRadius: 84,
      blur: 4,
      border: 0,
      linearGradient: LinearGradient(
          colors: [Colors.white.withAlpha(25), Colors.white.withAlpha(15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      borderGradient:
          LinearGradient(colors: [darkBackGroundColor, darkBackGroundColor]),
      width: 128,
      height: 128,
      child: Center(
          child: Container(
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
                  ))),
    ));
  }
}
