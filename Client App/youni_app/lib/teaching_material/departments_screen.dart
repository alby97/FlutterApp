import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/teaching_material/courses_of_study.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';

class DepartmentsScreen extends StatefulWidget {
 
 
  @override
  _DepartmentsScreenState createState () => _DepartmentsScreenState();
}



class _DepartmentsScreenState extends State<DepartmentsScreen> with WidgetsBindingObserver {

  bool _done = false;

  List<String> deps;

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getDepartments().then((list) {
      deps = list;
      setState(() {
        _done = true;
      });
    });
  }

  Future<List<String>> getDepartments() async {
    http.Response response = await http.get(getUrlHome()+"materialTeaching/departments", headers: {HttpHeaders.authorizationHeader : await getToken()});
    checkResponseStatus(response, context);
    if(response.statusCode == 200) {
      List<String> tmp = new List<String>();
      tmp = (json.decode(response.body)).cast<String>(); //forse potrebbe non servire il decode
      return tmp;
    }
    else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _done == false ? SpinKitPouringHourglass(
      color: Colors.white,
      size: 50,
    ) : Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Lista dei dipartimenti", style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next'),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: List.generate(deps.length, (i) {
          return ListTile(
            title: Text(deps[i], style: TextStyle(fontFamily: 'Avenir Next', color: Colors.white)),
            onTap: () {
              //!goto courses_of_study
              Navigator.of(context).push(new MaterialPageRoute(builder: (context) => CoursesOfStudyScreen(department: deps[i],)));
            },
          );
        }),
      )
    );
  }

}