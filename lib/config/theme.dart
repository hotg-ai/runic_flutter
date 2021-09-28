import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

const darkBackGroundColor = Color.fromRGBO(34, 28, 64, 1.0);
const indigoBlueColor = Color.fromRGBO(87, 30, 179, 1.0);
const barneyPurpleColor = Color.fromRGBO(179, 0, 161, 1.0);
const whiteAlpha = Color.fromRGBO(255, 255, 255, 0.4);
const blackColor = Color.fromRGBO(0, 0, 0, 1.0);
const charcoalGrey = Color.fromRGBO(56, 50, 63, 1);

const darkGreyBlue80 = Color.fromRGBO(42, 39, 97, 1.0);
const darkBlueBlue = Color.fromRGBO(24, 18, 64, 0.8);
const darkGreyBlue = Color.fromRGBO(39, 40, 83, 0.5);

const purpliblue = Color.fromRGBO(125, 44, 255, 0.1);
const brightMagenta = Color.fromRGBO(255, 0, 229, 0.13);
var theme = ThemeData(fontFamily: 'Helvetica');

final kInnerDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.white),
  borderRadius: BorderRadius.circular(32),
);

Widget glassRunic(Widget child,
    {borderRadius: 8.0,
    double width: double.infinity,
    double height: double.infinity,
    double blur: 15.0,
    double border: 1.0,
    LinearGradient borderGradient:
        const LinearGradient(colors: [whiteAlpha, whiteAlpha]),
    LinearGradient gradient: const LinearGradient(
        colors: [purpliblue, brightMagenta],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight)}) {
  return Container(
      decoration: BoxDecoration(
          border: (border == 0)
              ? null
              : Border.all(color: whiteAlpha, width: border),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
      child: GlassmorphicContainer(
          borderRadius: borderRadius,
          blur: blur,
          border: 0,
          linearGradient: gradient,
          borderGradient: borderGradient,
          width: width,
          height: height,
          child: child));
}

final elementsBorderRadius = const BorderRadius.all(Radius.circular(8));
final kGradientBoxDecoration = BoxDecoration(
  gradient: LinearGradient(colors: [indigoBlueColor, barneyPurpleColor]),
  border: Border.all(
    color: darkBackGroundColor,
  ),
  borderRadius: BorderRadius.circular(32),
);
