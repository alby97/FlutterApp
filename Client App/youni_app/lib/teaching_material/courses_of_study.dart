import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youni_app/complete_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/teaching_material/material_teaching_files_screen.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';

class CoursesOfStudyScreen extends StatefulWidget {
  final String department;

  CoursesOfStudyScreen({this.department});

  @override
  _CoursesOfStudyScreenState createState() =>
      _CoursesOfStudyScreenState(department: department);
}

class _CoursesOfStudyScreenState extends State<CoursesOfStudyScreen>
    with WidgetsBindingObserver {
  final String department;

  _CoursesOfStudyScreenState({this.department});

  bool _done = false;

  TextEditingController _filter = new TextEditingController();

  bool buttonSearchPressed = false;

  List<Corso> courses;

  Widget createAppBar() {
    TextField textField = new TextField(
      controller: _filter,
      decoration: new InputDecoration(hintText: "Cerca..."),
    );
    AppBar appBar = new AppBar(
      leading: IconButton(
        icon: buttonSearchPressed ? Icon(Icons.close) : Icon(Icons.search),
        onPressed: () {
          setState(() {
            buttonSearchPressed = !buttonSearchPressed;
          });
        },
      ),
      title: buttonSearchPressed ? textField : Text("Lista Corsi di Studi"),
    );
    return appBar;
  }

  Future<List<Corso>> getCourses() async {
    var url = Uri.encodeFull(getUrlHome()+"materialTeaching/departments/$department/courses");
    http.Response response = await http.get(url, headers: {HttpHeaders.authorizationHeader : await getToken()});
    checkResponseStatus(response, context);
    List<Corso> tmp = new List<Corso>();
    if(response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      for(int i = 0; i < jsonData.length; i++) {
        tmp.add(Corso.fromJson(jsonData[i]));
      }
    }
    return tmp;
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCourses().then((list) {
      courses = list;
      setState(() {
        _done = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _done == false
        ? SpinKitPouringHourglass(
            color: Colors.white,
            size: 50,
          )
        : Scaffold(
          appBar: createAppBar(),
          body: ListView(
            children: List.generate(courses.length, (i) {
              if(_filter.text != ""){
                if(courses[i].nomeCorso.toLowerCase().contains(_filter.text.toLowerCase())){
                  return ListTile(title: Text(courses[i].toString()),onTap: () {
                    //!goto show_files
                  },);
                }
                else {
                  return SizedBox();
                }
              }
              else {
                return ListTile(title: Text(courses[i].toString()),onTap: () {
                    //!goto show_files
                    Navigator.of(context).push(new MaterialPageRoute(builder: (context) => MaterialTeachings(department: department, courseOfStudy: courses[i].toString(),)));
                  },);
              }
            }),
          ),
        );
  }
}
