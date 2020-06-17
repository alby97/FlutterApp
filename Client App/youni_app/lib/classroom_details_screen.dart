import 'package:flutter/material.dart';
import 'package:youni_app/utils/classrooms.dart';


class ClassRoomDetailsScreen extends StatelessWidget with WidgetsBindingObserver{

  Classroom classroom;
  
  ClassRoomDetailsScreen(Classroom classroom){
    WidgetsBinding.instance.addObserver(this);
    this.classroom = classroom;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(classroom.name),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              enabled: false,
              title: Text(classroom.name, style: TextStyle(fontSize: 20.0, fontFamily: 'Avenir Next', color: Colors.black),),
              //leading: ,
            ),
            ListTile(
              enabled: false,
              title: Text(classroom.department, style: TextStyle(fontSize: 20.0, fontFamily: 'Avenir Next', color: Colors.black)),
            ),
            ListTile(
              enabled: false,
              title: Text(classroom.building, style: TextStyle(fontSize: 20.0, fontFamily: 'Avenir Next', color: Colors.black)),
            ),
            ListTile(
              enabled: false,
              title: Text("Piano: " + classroom.floor, style: TextStyle(fontSize: 20.0, fontFamily: 'Avenir Next', color: Colors.black)),
            ),
            ListTile(
              enabled: false,
              title: Text("Numero massimo posti a sedere: " + classroom.seatsMax, style: TextStyle(fontSize: 20.0, fontFamily: 'Avenir Next', color: Colors.black))
            )
          ],
        ),
      ),
    );
  }
}