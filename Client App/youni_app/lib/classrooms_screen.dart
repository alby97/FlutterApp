import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/classroom_details_screen.dart';
import 'package:youni_app/utils/classrooms.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ClassroomsScreen extends StatefulWidget {
  _ClassroomsScreenState createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends State<ClassroomsScreen>
    with WidgetsBindingObserver {
  List<Classroom> classrooms;

  bool _done = false;

  static TextEditingController _filter = new TextEditingController();

  String _searchText = "";
  bool _bottSearchPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getToken().then((token) {
      http.get(getUrlHome() + "getClassrooms",
          headers: {HttpHeaders.authorizationHeader: token}).then((response) {
            checkResponseStatus(response, context);
        List<dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        List<Classroom> tmp = new List<Classroom>();
        for (int i = 0; i < jsonData.length; i++) {
          Classroom classroom = Classroom.fromJson(jsonData[i]);
          tmp.add(classroom);
        }
        classrooms = tmp;
        setState(() {
          _done = true;
        });
      });
    });
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        _searchText = _filter.text;
      }
    });
  }

  Widget appBarTitle = TextField(
    controller: _filter,
    decoration: new InputDecoration(
        prefixIcon: new Icon(FontAwesomeIcons.search), hintText: 'Cerca...'),
  );

  List<Widget> _buildClassroomsList() {
    List<Classroom> tmp = new List<Classroom>();
    if (_bottSearchPressed == true && _searchText != "") {
      for (int i = 0; i < classrooms.length; i++) {
        if (classrooms[i]
                .name
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            classrooms[i]
                .department
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            classrooms[i]
                .building
                .toLowerCase()
                .contains(_searchText.toLowerCase())) {
          tmp.add(classrooms[i]);
        }
      }
    } else {
      tmp = classrooms;
    }
    return new List.generate(tmp.length, (index) {
      return ListTile(
        title: Text(tmp[index].name,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Avenir Next',
          fontSize: 15
        ),),
        leading: Icon(FontAwesomeIcons.school, color: Colors.white),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ClassRoomDetailsScreen(tmp[index])));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _done == false
          ? Center(
              child: SpinKitPouringHourglass(color: Colors.white, size: 50.0)
            )
          : Container(
      child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                bottom: PreferredSize(child: Container(color: Colors.green, height: 2), preferredSize: Size.fromHeight(2)),
                title: _bottSearchPressed == true ? appBarTitle : Text("Aule", 
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Avenir Next',
                  fontSize: 20
                ),),
                leading: IconButton(
                  icon: _bottSearchPressed == true
                      ? Icon(FontAwesomeIcons.times)
                      : Icon(FontAwesomeIcons.search),
                  onPressed: () {
                    setState(() {
                      _bottSearchPressed = !_bottSearchPressed;
                    });
                  },
                ),
              ),
              body: Container(
                color: Color.fromRGBO(25, 25, 25, 1.0),
                child: ListView(children: _buildClassroomsList()),
              ),
            ),
    );
  }
}
