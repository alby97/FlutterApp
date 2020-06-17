import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nice_button/nice_button.dart';

class ProvaButton extends StatefulWidget {

  @override
  _ProvaButtonState createState() => _ProvaButtonState();
}

class _ProvaButtonState extends State<ProvaButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           NiceButton(onPressed: () {}, text: "", background: null,
           gradientColors: [Colors.white, Colors.red, Colors.redAccent, Colors.lightBlue],
           elevation: 8.0,
           icon: FontAwesomeIcons.home,
           mini: true,
           iconColor: Colors.black,)

         ],
       ),
    );
  }
}