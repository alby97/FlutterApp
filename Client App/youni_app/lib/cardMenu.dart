import 'package:flutter/material.dart';

class CardMenu extends StatefulWidget {
  final String text;
  final Image image;
  final Color color;
  final Function onTapFunction;

  CardMenu({this.text, this.image, this.color, this.onTapFunction});

  @override
  _CardMenuState createState() => _CardMenuState(
      text: text, color: color, image: image, onTapFunction: onTapFunction);
}

class _CardMenuState extends State<CardMenu> {
  final String text;
  final Image image;
  final Color color;
  final Function onTapFunction;

  _CardMenuState({this.text, this.image, this.color, this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120.0,
        margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        child: InkWell(
          onTap: onTapFunction,
          child: Stack(
            children: <Widget>[
              //menuCard,
              //iconCard,
              Container(
                height: 124.0,
                margin: EdgeInsets.only(left: 46.0),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(25, 25, 25, 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: color, style: BorderStyle.solid, width: 2.5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0))
                    ]),
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  alignment: FractionalOffset.centerLeft,
                  child: image),
              Container(
                padding: EdgeInsets.fromLTRB(130.0, 50.0, 0, 0),
                //margin: EdgeInsets.symmetric(vertical: 45.0, horizontal: 110.0),
                child: RichText(
                  text: TextSpan(
                      text: text,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 22,
                      )),
                ),
              )
            ],
          ),
        ));
  }
/*
    final iconCard = new Container(
    margin: EdgeInsets.symmetric(
      vertical: 16.0
    ),
    alignment: FractionalOffset.centerLeft,
    child: image
    );

  final menuCard = Container(
    height: 124.0,
    margin: EdgeInsets.only(left: 46.0),
  
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      //border: Border.all(color: color),
      boxShadow: <BoxShadow> [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
          offset: Offset(0.0, 10.0)
        )
      ]
    ),
  );
  */
}
