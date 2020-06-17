import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/complete_profile_screen.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/firebaseMsgUtils.dart';
import 'package:youni_app/utils/teaching.dart';
import 'package:youni_app/utils/utility.dart';

class ChooseTeachingsNotifications extends StatefulWidget {
  @override
  _ChooseTeachingsNotificationsState createState() =>
      _ChooseTeachingsNotificationsState();
}

class _ChooseTeachingsNotificationsState
    extends State<ChooseTeachingsNotifications> with WidgetsBindingObserver {
  String dep;
  bool _waitingResp = true, depChosen = false;

  List<Corso> corsi;
  List<String> departments;
  List<Teaching> teachings;
  List<bool> switchersValues;

  bool _showTeachings = false;

  Corso courseSelected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getDepartments().then((list) {
      departments = list.cast<String>();
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
    print(response.statusCode);
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data;
    } else {
      return null;
    }
  }

  Future<void> _getCourses(String val) async {
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
        depChosen = true;
        //_firstOpComplete = true;
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

  void _createCoursesList(List json) {
    List<Corso> tmp = new List<Corso>();
    for (int i = 0; i < json.length; i++) {
      print(json[i]);
      Corso c = Corso.fromJson(json[i]);
      tmp.add(c);
    }
    corsi = tmp;
  }

  void _createTeachingList(List json) {
    List<Teaching> tmp = new List<Teaching>();
    for (int i = 0; i < json.length; i++) {
      Teaching t = Teaching.fromJson(json[i]);
      tmp.add(t);
    }
    teachings = tmp;
    _getTeachingsToNotify().then((list2) {
      print("Ok2");
      List teachsToNotify = list2;
      print(teachsToNotify.toString());
      switchersValues = new List<bool>(teachings.length);
      for (int i = 0; i < switchersValues.length; i++) {
        if (teachsToNotify.isNotEmpty &&
            teachsToNotify.contains(teachings[i].nomeInsegnamento +
                " " +
                teachings[i].indirizzo +
                " " +
                teachings[i].cfu)) {
          switchersValues[i] = true;
        } else {
          switchersValues[i] = false;
          print("False " + i.toString());
        }
      }
      setState(() {
        print("True");
        _showTeachings = true;
      });
    });
  }

  void _getTeachings() async {
    var url = getUrlHome() + "getAllTeachingsLessonChanges";
    http.Response response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: await getToken()
    }, body: {
      "course_name": courseSelected.nomeCorso,
      "course_type": courseSelected.tipo
    });
    checkResponseStatus(response, context);
    if (response.statusCode == 201) {
      _createTeachingList(json.decode(response.body));
    } else {
      //SHOW ERROR
    }
  }

  Future<List> _getTeachingsToNotify() async {
    String token = await getToken();
    var url = getUrlHome() + "getTeachingsToNotify";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      print("if 200");
      List teachsToNotify = json.decode(response.body)["teachings_to_notify"];
      return teachsToNotify;
    } else {
      print('Errore');
      //TODO: gestire errore
      return new List();
    }
  }

  Future<bool> _subscribeTeaching(Teaching t) async {
    String teaching = t.toString();
    FirebaseMessaging _fMessaging = getInstance();
    _fMessaging.subscribeToTopic(
        teaching.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_'));
    print("Subscription done");
    var url = getUrlHome() + "subscribeTeaching";
    var token = await getToken();
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {'teaching': t.toJson()});
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    }
    else {
      return false;
    }
  }

  Future<bool> _unsubscribeTeaching(Teaching t) async {
    String teaching = t.toJson();
    FirebaseMessaging _fMessaging = getInstance();
    _fMessaging.unsubscribeFromTopic(
        teaching.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_'));
    print('Unsubscription done');
    var url = getUrlHome() + "unsubscribeTeaching";
    var token = await getToken();
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {'teaching': t.toJson()});
        checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      return false;
    } else if (response.statusCode == 400) {
      return true;
    }
    else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _waitingResp == true
          ? Center(
              child: SpinKitPouringHourglass(
                color: Colors.white,
              ),
            )
          : _showTeachings ? ListView(
                            shrinkWrap: true,
                            children: List.generate(teachings.length, (i) {
                              return ListTile(
                                title: Text(
                                  "Nome: " +
                                      teachings[i].nomeInsegnamento +
                                      ", indirizzo: " +
                                      teachings[i].indirizzo +
                                      ", CFU: " +
                                      teachings[i].cfu,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Avenir Next"),
                                ),
                                trailing: Switch(
                                  onChanged: (bool value) {
                                    if (value == true) {
                                      _subscribeTeaching(teachings[i])
                                          .then((val) {
                                        setState(() {
                                          switchersValues[i] = val;
                                          if(val == false) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                                title: Text("Errore",
                                                style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                                content: Text("C'è stato un errore, riprovare.",
                                                style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                                actions: <Widget>[FlatButton(
                                                  child: Text("Chiudi"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )],
                                              )
                                            );
                                          }
                                        });
                                      });
                                    } else {
                                      _unsubscribeTeaching(teachings[i])
                                          .then((val) {
                                        setState(() {
                                          switchersValues[i] = val;
                                          if(val == true) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                                title: Text("Errore",
                                                style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                                content: Text("C'è stato un errore, riprovare.",style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                                                actions: <Widget>[FlatButton(
                                                  child: Text("Chiudi"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )],
                                              )
                                            );
                                          }
                                        });
                                      });
                                    }
                                  },
                                  value: switchersValues[i],
                                ),
                              );
                            }),
                          ) : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
              child: Center(
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                          Container(
                            child: ExpansionTile(
                              key: new GlobalKey(),
                              title: Text(
                                dep == null ? "Dipartimenti" : dep,
                                style: TextStyle(fontFamily: 'Avenir Next'),
                              ),
                              children: departments
                                  .map((val) => new ListTile(
                                        title: new RichText(
                                          text: TextSpan(
                                              text: val,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Avenir Next"),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  _getCourses(val);
                                                }),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          //SizedBox(height: ,)
                          depChosen == false
                              ? SizedBox()
                              : ExpansionTile(
                                  key: new GlobalKey(),
                                  title: Text(
                                    courseSelected != null
                                        ? courseSelected.toString()
                                        : "Corsi",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Avenir Next"),
                                  ),
                                  children: corsi
                                      .map((corso) => ListTile(
                                            title: RichText(
                                              text: TextSpan(
                                                  text: corso.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily:
                                                          "Avenir Next"),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          courseSelected =
                                                              corso;
                                                          _getTeachings();
                                                          //TODO
                                                        }),
                                            ),
                                          ))
                                      .toList(),
                                )
                        ],
                ),
              ),
            ),
    );
  }
}
