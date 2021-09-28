import 'package:flutter/material.dart';

const bubbleHeight = 128 / 444;
const bubbleWidth = (444) / 1500;

class NavigationBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, bubbleHeight * size.height);
    path.lineTo(bubbleWidth * size.width, bubbleHeight * size.height);

    Offset dest = Offset((bubbleWidth + (0.5 - bubbleWidth) / 2) * size.width,
        bubbleHeight * size.height / 2);
    Offset mid = Offset((bubbleWidth + (0.5 - bubbleWidth) / 4) * size.width,
        bubbleHeight * size.height);
    path.quadraticBezierTo(mid.dx, mid.dy, dest.dx, dest.dy);
    Offset dest2 = Offset(size.width / 2, 0);
    Offset mid2 =
        Offset((bubbleWidth + (0.5 - bubbleWidth) * 3 / 4) * size.width, 0);
    path.quadraticBezierTo(mid2.dx, mid2.dy, dest2.dx, dest2.dy);

    path.quadraticBezierTo(
        size.width - mid2.dx, mid2.dy, size.width - dest.dx, dest.dy);
    path.quadraticBezierTo(size.width - mid.dx, mid.dy,
        size.width - bubbleWidth * size.width, bubbleHeight * size.height);
    path.lineTo(size.width, bubbleHeight * size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
