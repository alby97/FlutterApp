import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/chat_academic_view_screen.dart';
import 'package:youni_app/utils/utility.dart';

class ChatAcademicScreen extends StatefulWidget {
  ChatAcademicScreen({Key key}) : super(key: key);

  @override
  _ChatAcademicScreenState createState() => _ChatAcademicScreenState();
}

class _ChatAcademicScreenState extends State<ChatAcademicScreen> with WidgetsBindingObserver{

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
    http.Response response = await http.get(getUrlHome()+"getDepartments", headers: {HttpHeaders.authorizationHeader : await getToken()});
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
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2)),
        title: Text("Lista dei dipartimenti", 
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Avenir Next',
          fontSize: 20
        ),),
      ),
      body: ListView(
        
        children: List.generate(deps.length, (i) {
          return ListTile(
            
            title: Text(deps[i], style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15.0),),
            onTap: () {
              //andare in chatAcademic view Screen
              Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ChatAcademicScreenView(department: deps[i])));
            },
          );
        }),
      ),
    );
  }
}