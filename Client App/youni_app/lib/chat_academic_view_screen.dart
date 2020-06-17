import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/academic_chat.dart';
import 'package:youni_app/chat.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

class ChatAcademicScreenView extends StatefulWidget {
  final String department;

  ChatAcademicScreenView({this.department});

  @override
  _ChatAcademicScreenViewState createState() => _ChatAcademicScreenViewState(department: department);
}

class _ChatAcademicScreenViewState extends State<ChatAcademicScreenView>
    with WidgetsBindingObserver {

      final String department;

  _ChatAcademicScreenViewState({this.department});

  List<_AcademicChat> academicChats, tmp;
  bool _done = false;

  static TextEditingController _filter = new TextEditingController();

  String _searchText;

  bool bottSearchPressed = false;

  Widget appBarTitle = TextField(
    controller: _filter,
    decoration: new InputDecoration(
        prefixIcon: new Icon(Icons.search), hintText: 'Cerca...'),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchText = "";
    getAcademicChatsForDepartment().then((list) {
      if (list != null) {
        academicChats = createAcademicChatsList(list);
        //print(academicChats);
        setState(() {
          _done = true;
        });
      }
    });
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

/*
  @override
  void dispose() {
    setState(() {
      _searchText = "";
      bottSearchPressed = false;
    });
    super.dispose();
  }
*/
  Future<List<dynamic>> getAcademicChatsForDepartment() async {
    //!!! Da aggiungere il dipartimento come parametro che viene scelto in chat_academic_screen
    String url = getUrlHome() + "getAcademicChats";
    String token = await getToken();
    http.Response response =
        await http.post(url, headers: {HttpHeaders.authorizationHeader: token}, body: {"department" : department});
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List tmp = json.decode(response.body);
      return tmp;
    } else {
      return null;
    }
  }

  List<_AcademicChat> createAcademicChatsList(List<dynamic> jsonList) {
    List<_AcademicChat> tmp2 = new List<_AcademicChat>();
    for (int i = 0; i < jsonList.length; i++) {
      tmp2.add(new _AcademicChat(
          id: jsonList[i]["id"],
          department: jsonList[i]["department"],
          courseName: jsonList[i]["course_name"],
          courseType: jsonList[i]["course_type"],
          year: jsonList[i]["year_regulation"],
          cfu: jsonList[i]["cfu"],
          teaching: jsonList[i]["teaching"]));
    }
    return tmp2;
  }

  List<Widget> _buildAcademicChatList() {
    tmp = new List<_AcademicChat>();
    if (bottSearchPressed == true && _searchText != "") {
      for (int i = 0; i < academicChats.length; i++) {
        if (academicChats[i]
            .toString()
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tmp.add(academicChats[i]);
        }
      }
    } else {
      tmp = academicChats;
    }
    if (tmp.length == 0) {
      return null;
    } else {
      return new List.generate(tmp.length, (i) {
        return ListTile(
          title: Text(tmp[i].toString(), style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15)),
          onTap: () {
            print(tmp[i].id);
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) => AcademicChat(
                      chatName: tmp[i].toString(),
                      id: tmp[i].id,
                    )));
            //TODO: rimandare ad academic_chat con il chatname pari al toString ma è da aggiustare (mettere gli underscore per separare i campi)
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _done == false
        ? SpinKitPouringHourglass(
            color: Colors.white,
            size: 50.0,
          )
        : Scaffold(
          backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2),),
              title: bottSearchPressed == true
                  ? appBarTitle
                  : Text("Lista Chat Accademiche",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Avenir Next',
                    fontSize: 20
                  ),),
              leading: IconButton(
                icon: bottSearchPressed == true
                    ? Icon(FontAwesomeIcons.times, color: Colors.white,)
                    : Icon(FontAwesomeIcons.search, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    bottSearchPressed = !bottSearchPressed;
                  });
                },
              ),
            ),
            body: _searchText == ""
                ? /*tmp != null && tmp.isNotEmpty
              ?*/
                ListView(
                    children: _buildAcademicChatList(),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.exclamation,
                          color: Colors.red,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Nessuna chat risponde ai tuoi criteri di ricerca",
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
          );
  }
}

class _AcademicChat {
  String id, department, courseName, courseType, year, cfu, teaching;

  _AcademicChat(
      {this.id,
      this.department,
      this.courseName,
      this.courseType,
      this.year,
      this.cfu,
      this.teaching});

  _AcademicChat.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData["id"],
        department = jsonData["department"],
        courseName = jsonData["course_name"],
        courseType = jsonData["course_type"],
        year = jsonData["year_regulation"],
        cfu = jsonData["cfu"],
        teaching = jsonData["teaching"];

  @override
  String toString() {
    return courseName +
        " " +
        courseType +
        " " +
        year +
        " " +
        cfu +
        " " +
        teaching;
  }

  String chatName() {
    return courseName +
        "_" +
        courseType +
        "_" +
        year +
        "_" +
        cfu +
        "_" +
        teaching;
  }
}
