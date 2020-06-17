import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youni_app/colors.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart'
    as datetime;
import 'package:intl/intl.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/teaching.dart';
import 'package:youni_app/utils/utility.dart' as utils;
import 'package:http/http.dart' as http;

import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateNewLessonChangeScreen extends StatefulWidget {
  _CreateNewLessonChangeScreenState createState() =>
      _CreateNewLessonChangeScreenState();
}

class _CreateNewLessonChangeScreenState
    extends State<CreateNewLessonChangeScreen> with WidgetsBindingObserver {
  String courseName, courseType, author, classroom;
  Teaching teachSelected;

  bool opComplete = false;

  final controllerDescription = TextEditingController();
  final controllerClassroom = TextEditingController();
  DateTime oldTime, newTime;

  List<Teaching> teachings;

  List<String> tipi;

  List<String> classrooms;

  String tipo;

  String name, surname;

  static TextEditingController _filter = new TextEditingController();

  String _searchText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCourseInfo().then((jsonResp) {
      print(jsonResp);
      courseName = jsonResp['course_study'];
      courseType = jsonResp['course_type'];
      getTeachings().then((jsonResp2) {
        teachings = createTeachingsList(jsonResp2);
        utils.getValue(utils.getUserKey()).then((username) {
          author = username;
          getClassrooms().then((rooms) {
            classrooms = rooms;
            tipi = new List();
            tipi.add("Annullamento");
            tipi.add("Rinvio");
            utils.getValue("name").then((name) {
              this.name = name;
              utils.getValue("surname").then((surname) {
                this.surname = surname;
                setState(() {
                  opComplete = true;
                  print(name + " " + surname);
                });
              });
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
            setState(() {
              opComplete = true;
            });
          });
        });
      });
    });
  }

  Future<Map<String, dynamic>> _getCourseInfo() async {
    var url = utils.getUrlHome() + "getLessonsChanges/" + "getCourseInfo";
    var token = await utils.getToken();
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    checkResponseStatus(response, context);
    return json.decode(response.body);
  }

  Future<List<String>> getClassrooms() async {
    String token = await utils.getToken();
    String url = utils.getUrlHome() + "getClassroomsName";
    List<String> rooms = new List<String>();
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List<dynamic> tmp = json.decode(response.body);
      for (int i = 0; i < tmp.length; i++) {
        String nameTmp = tmp[i]["name"];
        rooms.add(nameTmp);
      }
    } else {
      //errore
      rooms = new List<String>();
    }
    return rooms;
  }

  List<Widget> _buildClassroomsList() {
    List<String> tmp = new List<String>();
    if (_searchText != "") {
      for (int i = 0; i < classrooms.length; i++) {
        if (classrooms[i].toLowerCase().contains(_searchText.toLowerCase())) {
          tmp.add(classrooms[i]);
        }
      }
    } else {
      tmp = classrooms;
    }
    return new List.generate(tmp.length, (index) {
      return ListTile(
        title: Text(tmp[index]),
        onTap: () {
          print(index);
          print(tmp[index]);
          setState(() {
            controllerClassroom.text = tmp[index];
            Navigator.of(context).pop();
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        bottom: PreferredSize(child: Container(color: Colors.red, height: 2), preferredSize: Size.fromHeight(2)),
        title: Text('Aggiungi una variazione', 
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Avenir Next',
          fontSize: 20
        ),),
      ),
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
      body: opComplete == false
          ? Container(
              child: SpinKitPouringHourglass(
                    color: Colors.white,
                    size: 50.0,
                  ))
          : Container(
              child: ListView(
                padding: EdgeInsets.fromLTRB(3.0, 10.0, 3.0, 5.0),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    
                    padding: EdgeInsets.all(6.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: courseName,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: courseType,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: name,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: surname,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    child: ExpansionTile(
                      key: new GlobalKey(),
                      title: Text(
                        teachSelected == null
                            ? "Scegli l'insegnamento"
                            : teachSelected.toString(),
                        style: TextStyle(
                            fontFamily: 'Avenir Next',
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      children: teachings
                          .map((val) => new ListTile(
                                  title: RichText(
                                text: TextSpan(
                                    text: val.nomeInsegnamento +
                                        ", " +
                                        val.indirizzo +
                                        ", " +
                                        val.cfu,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          teachSelected = val;
                                        });
                                      },
                                    style: TextStyle(
                                        fontFamily: 'Avenir Next',
                                        color: Colors.white,
                                        fontSize: 20.0)),
                              )))
                          .toList(),
                    ),
                  ),
                  ExpansionTile(
                    key:
                        new GlobalKey(), //!RICORDARE CHE E' FONDAMENTALE AFFINCHE' DOPO CHE SI E' SCELTO UN VALORE IL PANEL SI RICHIUDA DA SOLO
                    title: Text(
                      tipo == null ? "Seleziona il tipo di variazione" : tipo,
                      style: TextStyle(
                          fontFamily: 'Avenir Next',
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    children: tipi
                        .map((val) => new ListTile(
                                title: RichText(
                                    text: TextSpan(
                              text: val,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    tipo = val;
                                  });
                                },
                              style: TextStyle(
                                  fontFamily: 'Avenir Next',
                                  color: Colors.white,
                                  fontSize: 20.0),
                            ))))
                        .toList(),
                  ),
                  TextFormField(
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 20.0),
                    enabled: true,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontFamily: 'Avenir Next', color: Colors.white),
                        hintText: 'Inserire una descrizione'),
                    controller: controllerDescription,
                  ),
                  tipo == "Rinvio"
                      ? Row(
                          children: <Widget>[
                            Expanded(
                                child: TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Avenir Next',
                                  fontSize: 20.0),
                              enabled: false,
                              controller: controllerClassroom,
                            )),
                            FlatButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                        title: TextField(
                                          controller: _filter,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Avenir Next',
                                            fontSize: 20
                                          ),
                                        ),
                                        content: Container(
                                            width: double.maxFinite,
                                            height: 350.0,
                                            child: ListView(
                                              padding: EdgeInsets.all(5.0),
                                              children: _buildClassroomsList(),
                                            ))));
                              },
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                              color: Colors.white, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Text(
                                'Scegli l\'aula',
                                style: TextStyle(
                                    fontFamily: 'Avenir Next',
                                    color: Colors.white),
                              ),
                            )
                          ],
                        )
                      : SizedBox(),
                  tipo == "Rinvio"
                      ? datetime.DateTimeField(
                          decoration: InputDecoration(
                              hintText: "Vecchia data",
                              hintStyle: TextStyle(
                                  fontFamily: 'Avenir Next',
                                  color: Colors.white,
                                  fontSize: 20.0)),
                          format: DateFormat("dd-MM-yyyy hh:mm"),
                          style: TextStyle(
                              fontFamily: 'Avenir Next',
                              color: Colors.white,
                              fontSize: 20.0),
                          onShowPicker: (context, value) async {
                            final date = await showDatePicker(
                                
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(DateTime.now()),
                              );
                              return datetime.DateTimeField.combine(date, time);
                            } else {
                              return value;
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              print("Value: " + value.toString());
                              oldTime = value;
                            });
                          },
                        )
                      : SizedBox(),
                  tipo == "Rinvio"
                      ? datetime.DateTimeField(
                          decoration: InputDecoration(
                              hintText: "Nuova data",
                              hintStyle: TextStyle(
                                  fontFamily: 'Avenir Next',
                                  color: Colors.white,
                                  fontSize: 20.0)),
                          format: DateFormat("dd-MM-yyyy hh:mm"),
                          style: TextStyle(
                              fontFamily: 'Avenir Next',
                              color: Colors.white,
                              fontSize: 20.0),
                          onShowPicker: (context, value) async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(DateTime.now()),
                              );
                              return datetime.DateTimeField.combine(date, time);
                            } else {
                              return value;
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              print("Value: " + value.toString());
                              newTime = value;
                            });
                          },
                        )
                      : SizedBox(height: 50),
                  FlatButton(
                    
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                              color: Colors.white, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(60.0)
                    ),
                      child: Text('Invia richiesta',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 20
                      )),
                      onPressed: () async {
                        if (tipo != null) {
                          var url = utils.getUrlHome() + "saveLessonChange";
                          print(url);
                          http.Response response =
                              await http.post(url, headers: {
                            HttpHeaders.authorizationHeader:
                                await utils.getToken()
                          }, body: {
                            'teaching': json.encode({
                              'name': teachSelected.nomeInsegnamento,
                              'indirizzo': teachSelected.indirizzo,
                              'cfu': teachSelected.cfu
                            }),
                            'description': controllerDescription.text,
                            'author': author,
                            'course_name': courseName,
                            'course_type': courseType,
                            'type': tipo,
                            'classroom': controllerClassroom.text == null &&
                                    tipo == "Annullamento"
                                ? ""
                                : controllerClassroom.text,
                            'old_time':
                                oldTime == null ? "" : oldTime.toString(),
                            'new_time':
                                newTime == null ? "" : newTime.toString(),
                            'timestamp': DateTime.now().toString(),
                            'author_name': name,
                            'author_surname': surname
                          });
                          print(response.statusCode);
                          print(response.body);
                          checkResponseStatus(response, context);
                          if (response.statusCode == 201) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  
                                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                      content: Text(
                                          "Variazione lezione inviata con successo.",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Avenir Next',
                                            fontSize: 20
                                          ),),
                                      elevation: 4.0,
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Ok",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Avenir Next'
                                          )),
                                          onPressed: () {
                                            Navigator.of(context).popUntil(
                                                ModalRoute.withName(
                                                    '/lessonsChangesScreen')); //ritorna alla pagina delle variazioni lezione
                                          },
                                        )
                                      ],
                                    ));
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                      content: Text(json
                                          .decode(response.body)["message"], style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Avenir Next',
                                            fontSize: 20
                                          ),),
                                      elevation: 4.0,
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Ok",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Avenir Next'
                                          ),),
                                          onPressed: () {
                                            Navigator.of(context).popUntil(
                                                ModalRoute.withName(
                                                    '/lessonsChangesScreen')); //ritorna alla pagina delle variazioni lezione
                                          },
                                        )
                                      ],
                                    ));
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                    content: Text(
                                        "Scegli prima il tipo di variazione.",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 20
                                        ),),
                                    elevation: 4.0,
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Ok",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next'
                                        ),),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ));
                        }
                      }),
                ],
              ),
            ),
          );
  }
}
