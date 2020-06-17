import 'package:flutter/material.dart';
import 'user_profile_screen.dart';

class CustomClipPath extends CustomClipper <Path> {
  
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height-50);
    var controllPoint = Offset(50, size.height);
    var endPoint = Offset(size.width/2, size.height);
    path.quadraticBezierTo(controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}