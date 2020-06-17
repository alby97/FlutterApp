import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youni_app/utils/teaching.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/utils/firebaseMsgUtils.dart' as firebaseMsgUtils;

/*
Per cambiare il corso di studi si deve avere :
lo username : Ok
Il precedente Cds con anno e indirizzo : li passo nel costruttore


Cosa si deve fare prima di procedere?
! 1) Chiedere all'utente se vuole effettivamente cambiare il Cds (showDialog)
! 2) Fare l'unsubscribe di tutti gli insegnamenti del Cds precedente se si vuole procedere
! 3) Richiesta in cui si manda il nuovo CdS con tutti i dati
*/

class ChangeCourseOfStudyScreen extends StatefulWidget {
  final String courseStudy, courseType, courseAddress;

  ChangeCourseOfStudyScreen(
      {this.courseStudy, this.courseType, this.courseAddress});

  _ChangeCourseOfStudyScreenState createState() =>
      _ChangeCourseOfStudyScreenState(
          courseStudy: courseStudy,
          courseType: courseType,
          courseAddress: courseAddress);
}

class _ChangeCourseOfStudyScreenState extends State<ChangeCourseOfStudyScreen>
    with WidgetsBindingObserver {
  String courseStudy, courseType, courseAddress;

  _ChangeCourseOfStudyScreenState(
      {this.courseStudy, this.courseType, this.courseAddress});

  String dep = "", year = "", address = "";
  bool _waitingResp = true;
  bool departmentChosen = false,
      courseChosen = false,
      yearChosen = false,
      addressChosen = false,
      _operationSuccessful;

  List<String> departments = new List<String>();
  List<Corso> corsi = new List<Corso>();
  List<String> anni = new List<String>();
  List<String> addresses = new List<String>();

  Corso courseSelected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getDepartments().then((listDep) {
      departments = listDep.cast<String>();
      setState(() {
        _waitingResp = false;
      });
    });
  }

  Future<List<dynamic>> _getDepartments() async {
    var token = await getToken();
    var url = getUrlHome() + "getDepartments";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
        checkResponseStatus(response, context);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data;
    } else {
      return null;
    }
  }

  Future<void> _getCourses(String val) async {
    /*
    for (int i = 0; i < departments.length; i++) {
      if (departments[i] == val) {
        depSelected = i;
        break;
      }
    }
    */
    dep = val;
    setState(() {
      _waitingResp = true;
    });
    var token = await getToken();
    var url = getUrlHome() + "getCourses";
    http.Response response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: token,
    }, body: {
      "dipartimento": "$dep"
    });
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body); //json.decode(response.body);
      _createCoursesList(data);
      setState(() {
        _waitingResp = false;
        departmentChosen = true;
      });
      /*
      print("Mappa");
      print(dataMap);
      print(dataMap.elementAt(0));
      //print(dataMap.elementAt(0).keys.elementAt(index));
      print(dataMap.elementAt(0).values.elementAt(0));
      */

    }
  }

  Widget _showCourses() {
    if (departmentChosen == false) {
      return Text(
        "Non è stato selezionato alcun dipartimento.",
        style: TextStyle(
            color: Colors.black, fontFamily: 'Avenir Next', fontSize: 17.0),
      );
    }
    return Container(
        padding: EdgeInsets.all(6.0),
        child: ExpansionTile(
            key: new GlobalKey(),
            title: Text(
              courseChosen == true
                  ? courseSelected.nomeCorso + " " + courseSelected.tipo
                  : "Corsi di studio",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Avenir Next',
                  fontSize: 17.0),
            ),
            children: corsi
                .map((val) => new ListTile(
                        title: new RichText(
                      text: TextSpan(
                          text: val.nomeCorso,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print("Tap");
                              getYears(val.nomeCorso, val.tipo);
                            },
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Avenir Next',
                              fontSize: 15.0),
                          children: <TextSpan>[
                            TextSpan(
                              text: " : " + val.tipo,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  print("Tap");
                                  await getYears(val.nomeCorso, val.tipo);
                                },
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Avenir Next',
                                  fontSize: 15.0),
                            )
                          ]),
                    )))
                .toList()));
  }

  Future<void> getYears(String course, String type) {
    courseSelected = new Corso(course, type);
    http.post(getUrl() + "getYears",
        body: {"nomeCorso": course, "tipoCorso": type}).then((response) {
          checkResponseStatus(response, context);
      if (response.statusCode == 201) {
        int yearMin = json.decode(response.body)["yearMin"];
        int yearMax = json.decode(response.body)["yearMax"];
        List<String> tmp = new List<String>();
        for (; yearMin < yearMax; yearMin++) {
          tmp.add(yearMin.toString() + "/" + (yearMin + 1).toString());
        }
        setState(() {
          anni = tmp;
          courseChosen = true;
        });
      } else {
        //TODO: GESTIRE ERRORE
      }
    });
  }

  Widget _showYears(BuildContext context) {
    if (courseChosen == false) {
      return Text('');
    }
    return Container(
      padding: EdgeInsets.all(6.0),
      child: ExpansionTile(
        key: new GlobalKey(),
        title: Text(
          yearChosen ? year : "Anno di iscrizione",
          style: TextStyle(
              color: Colors.black, fontFamily: 'Avenir Next', fontSize: 17.0),
        ),
        children: anni
            .map((val) => new ListTile(
                  title: new RichText(
                    text: TextSpan(
                      text: val,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          year = val;
                          await _getAddresses();
                          //_sendCompleteProfile(context, val);
                        },
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Avenir Next',
                          fontSize: 15.0),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Future<void> _getAddresses() async {
    String token = await getToken();
    print(token);
    String url = getUrlHome() + "getCourseAddresses";
    http.Response response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: token
    }, body: {
      "course_name": courseSelected.nomeCorso,
      "course_type": courseSelected.tipo,
      "course_year": year
    });
    checkResponseStatus(response, context);
    if (response.statusCode == 201) {
      print(json.decode(response.body));
      List<dynamic> jsonData = json.decode(response.body);
      addresses = (jsonData).cast<String>();
      setState(() {
        yearChosen = true;
      });
    } else {
      //TODO: gestire errore
    }
  }

  Widget _showCourseAddresses() {
    if (yearChosen == false) {
      return Text('');
    } else {
      return Container(
        padding: EdgeInsets.all(6.0),
        child: ExpansionTile(
          key: new GlobalKey(),
          title: Text(
              addressChosen == true ? address : "Indirizzi corso di studio",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Avenir Next',
                  fontSize: 17.0)),
          children: addresses
              .map((val) => new ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: val,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              address = val;
                              addressChosen =
                                  true; //! da vedere se cambia il title da solo
                            });
                          },
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Avenir Next',
                            fontSize: 15.0),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }
  }

  void _createCoursesList(List json) {
    List<Corso> tmp = new List<Corso>();
    for (int i = 0; i < json.length; i++) {
      print(json[i]);
      Corso c = Corso.fromJson(json[i]);
      tmp.add(c);
    }
    corsi = tmp;
  }

  Future<List> _getTeachingsToNotify() async {
    String token = await getToken();
    http.Response response = await http.get(
        getUrlHome() + 'getTeachingsToNotify',
        headers: {HttpHeaders.authorizationHeader: token});
    print("Fatto");
    print(response.statusCode);
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List l = json.decode(response.body);
      print(l);
      return l;
    } else {
      //restituire errore
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _waitingResp == true
          ? new Center(
              child: new SpinKitPouringHourglass(
                color: Colors.white,
              ),
            )
          :
_operationSuccessful !=null ? AlertDialog(
  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
  content: Text(_operationSuccessful == true ? "Corso di studi cambiato con successo" : "C'è stato un errore, riprovare",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20) ),
  actions: <Widget>[
    _operationSuccessful == true ? FlatButton(
      child: Text("Torna al profilo",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ) : FlatButton(
      child: Text("Chiudi",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    )
  ],
) : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(3.0, 26.0, 3.0, 8.0),
              child: Column(
                children: <Widget>[
                  Container(
                      child: ExpansionTile(
                    title: Text(
                      departmentChosen == true ? dep : "Scegli un dipartimento",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Avenir Next',
                          fontSize: 17.0),
                    ),
                    children: departments
                        .map((val) => new ListTile(
                              title: new RichText(
                                text: TextSpan(
                                    text: val,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print("Tap");
                                        _getCourses(val);
                                      },
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Avenir Next',
                                        fontSize: 15.0)),
                              ),
                            ))
                        .toList(),
                  )),
                  SizedBox(
                    height: 8.0,
                  ),
                  Center(
                    child: _showCourses(),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Center(
                    child: _showYears(context),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Center(
                    child: _showCourseAddresses(),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Center(
                    child: FlatButton(
                      child: Text("Modifica il corso di studi"),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                  content: Text(
                                      _operationSuccessful != null? _operationSuccessful == true ? "Corso di studi cambiato con successo!" : "C'è stato un errore, riprovare." : "Sei sicuro/a di voler cambiare Corso di Studi?",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                  actions: <Widget>[
                                    _operationSuccessful != null ? _operationSuccessful == true ? FlatButton(
                                      child: Text("Torna al profilo",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                    ) : FlatButton(
                                      child: Text("Chiudi",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ) : FlatButton(
                                      child: Text("Sì",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                      onPressed: () async {
                                        setState(() {
                                         _waitingResp = true; 
                                        });
                                        List l = await _getTeachingsToNotify();
                                        for (int i = 0; i < l.length; i++) {
                                          String teaching = l[i];
                                          print(teaching);
                                          print(teaching.replaceAll(" ", "_"));
                                          /*Teaching tmp =
                                              Teaching.fromJson(l[i]);
                                              
                                            */  
                                              
                                          FirebaseMessaging _firebaseMessaging =
                                              firebaseMsgUtils.getInstance();
                                          _firebaseMessaging
                                              .unsubscribeFromTopic(teaching
                                                  .toString()
                                                  .replaceAll(
                                                      new RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_'));
                                          //!SI DEVE GESTIRE L'EVENTUALE ERRORE QUANDO SI FA L'UNSUBSCRIBE
                                        }
                                        http.post(
                                            getUrlHome() +
                                                "changeCourseOfStudy",
                                            headers: {
                                              HttpHeaders.authorizationHeader:
                                                  await getToken()
                                            },
                                            body: {
                                              "courseName":
                                                  courseSelected.nomeCorso,
                                              "courseType": courseSelected.tipo,
                                              "address": address,
                                              "year": year,
                                              "department": dep
                                            }).then((response) {
                                              checkResponseStatus(response, context);
                                          if (response.statusCode == 201) {
                                            setState(() {
                                              _operationSuccessful = true;
                                              _waitingResp = false;
                                              Navigator.of(context).pop();
                                            });
                                            /*
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                content: Text("Corso di studi cambiato con successo"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  )
                                                ],
                                              )
                                            );
                                            */
                                          } else {
                                            //GESTISCI ERRORE
                                            setState(() {
                                              _operationSuccessful = false;
                                              _waitingResp = false;
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ));
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class Corso {
  final String nomeCorso;
  final String tipo;

  Corso(this.nomeCorso, this.tipo);

  Corso.fromJson(Map<String, dynamic> json)
      : nomeCorso = json['course_name'],
        tipo = json['course_type'];
}
