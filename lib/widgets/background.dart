import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:runic_flutter/config/theme.dart';

const shapeCount = 4;
const repeats = 2;

enum Screen { splash, main }

class Background extends StatefulWidget {
  // This widget is the root of your application.
  Screen screen;
  Background({this.screen = Screen.main});

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  final List<Widget> shapes = [];
  final List<Offset> positions = [];

  @override
  void initState() {
    super.initState();
  }

  generatePositions(double width, double height) {
    Random rand = new Random();
    positions.clear();
    for (int i = 0; i < shapeCount * repeats; i++) {
      positions.add(new Offset(
          rand.nextDouble() * width * 0.8, rand.nextDouble() * height * 0.8));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (positions.length == 0) {
      generatePositions(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height);

      for (int r = 0; r < repeats; r++) {
        for (int i = 0; i < shapeCount; i++) {
          shapes.add(Positioned(
            left: positions[i + r * shapeCount].dx,
            top: positions[i + r * shapeCount].dy,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                (widget.screen == Screen.splash)
                    ? "assets/images/background_shapes/splash_shape_${i + 1}.png"
                    : "assets/images/background_shapes/shape_${i + 1}.png",
                width: 200 * Random().nextDouble(),
              ),
            ),
          ));
        }
      }
      shapes.add(GlassmorphicContainer(
        margin: EdgeInsets.fromLTRB(
            widget.screen == Screen.splash ? 42 : 0,
            widget.screen == Screen.splash ? 84 : 0,
            widget.screen == Screen.splash ? 42 : 0,
            widget.screen == Screen.splash ? 84 : 0),
        borderRadius: widget.screen == Screen.splash ? 21 : 0,
        blur: 8,
        border: 0,
        linearGradient: LinearGradient(colors: [
          widget.screen == Screen.splash
              ? Colors.white.withAlpha(25)
              : darkBackGroundColor.withAlpha(100),
          widget.screen == Screen.splash
              ? Colors.white.withAlpha(15)
              : darkBackGroundColor.withAlpha(20),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderGradient:
            LinearGradient(colors: [darkBackGroundColor, darkBackGroundColor]),
        width: double.infinity,
        height: double.infinity,
      ));
    }
    return Container(
        color: darkBackGroundColor,
        width: double.infinity,
        height: double.infinity,
        child: Stack(children: shapes));
  }
}
