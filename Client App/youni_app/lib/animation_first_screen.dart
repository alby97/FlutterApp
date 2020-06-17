import 'dart:math';

import 'package:flutter/material.dart';
import 'package:youni_app/loginScreen.dart';

class AnimationFirstScreen extends StatefulWidget {
  _AnimationFirstScreen createState() => new _AnimationFirstScreen();
}

class _AnimationFirstScreen extends State<AnimationFirstScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation flip_anim;

  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    flip_anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(0.0, 0.5, curve: Curves.linear),
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 50.0),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.red[100]])),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red[100], Colors.red[700]])),
          child: AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget child) {
                return Center(
                    child: Column(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.repeat();
                      },
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..rotateY(2 * pi * flip_anim.value),
                          alignment: Alignment.center,
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            child: Image.asset(
                                'assets/images/LogoNoSfondoResize.png'),
                          ),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "\n"
                      ),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(
                          color: Colors.white,
                          style: BorderStyle.solid
                        )
                      ),
                      child: Text('Entra',
                      style: TextStyle(
                        fontFamily: 'Avenir Next',
                        fontSize: 15.0,
                        color: Colors.white
                      )),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                      },
                    )
                  ],
                ));
              }),
        )
        /*AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget child) {
          return Center (
            child: InkWell(
              onTap: (){
                controller.repeat();
              },
              child: Container(
                
              ),
            ),
          );
        }
      ),*/
        );
  }
}
