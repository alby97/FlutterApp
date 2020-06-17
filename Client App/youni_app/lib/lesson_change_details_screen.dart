import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/lessons_changes.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

class LessonChangeDetailsScreen extends StatefulWidget {
  String id;

  LessonChangeDetailsScreen({this.id});

  LessonChangeDetailsScreenState createState() =>
      new LessonChangeDetailsScreenState(id: id);
}

class LessonChangeDetailsScreenState extends State<LessonChangeDetailsScreen> {
  String id;
  String myUsername;

  LessonChange lessonChange;

  bool done = false;

  LessonChangeDetailsScreenState({this.id});

  //! aggiungi il campo old_time se la variazione è un rinvio

  @override
  void initState() {
    super.initState();
    getToken().then((token) {
      String url = getUrlHome();
      http.post(url + "getLessonChangeFromId",
          headers: {HttpHeaders.authorizationHeader: token},
          body: {'id': id}).then((response) {
            checkResponseStatus(response, context);
        if (response.statusCode == 200) {
          print(response.body);
          var jsonData = json.decode(response.body);
          lessonChange = LessonChange.fromJson(jsonData);
          /* List<String> list = jsonData["likes"].cast<String>();
          lessonChange.likes = list.length;
          lessonChange.liked = list.contains(getValue('Username'));
          list = jsonData["dislikes"].cast<String>();
          lessonChange.dislikes = list.length;
          lessonChange.disliked = list.contains(getValue('Username'));
          */
          List<String> likes = jsonData["likes"].cast<String>();
          List<String> dislikes = jsonData["dislikes"].cast<String>();
          getValue("Username").then((username) {
            print(username);
            myUsername = username;
            lessonChange.liked = likes.contains(username);
            lessonChange.disliked = dislikes.contains(username);
            print(lessonChange.author);
            print(lessonChange.description);
            print(lessonChange.liked);
            print(lessonChange.disliked);
            print(lessonChange.likes);
            print(lessonChange.dislikes);
            setState(() {
              done = true;
            });
          });
        } else {
          //errore
          setState(() {
            done = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        body: done == false
            ? Center(
                child: SpinKitPouringHourglass(
                  color: Colors.white,
                ),
              )
            : Container(
                child: lessonChange == null
                    ? Text("Errore")
                    : Column(children: <Widget>[
                        RichText(text: TextSpan(text: " ")),
                        RichText(text: TextSpan(text: " ")),
                        RichText(text: TextSpan(text: " ")),
                        RichText(text: TextSpan(text: " ")),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0),
                          initialValue: "Autore: " + lessonChange.authorName + " " + lessonChange.authorSurname,
                          decoration: InputDecoration(
                              prefixIcon: Icon(FontAwesomeIcons.user,
                                  color: Colors.white, size: 20.0)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ),
                        RichText(text: TextSpan(text: " ")),
                        TextFormField(
                          enabled: false,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0),
                          initialValue: "Tipo: " + lessonChange.type,
                          decoration: InputDecoration(
                              prefixIcon: lessonChange.type == "Annullamento" ? Icon(FontAwesomeIcons.times,
                                  color: Colors.white, size: 20.0) : Icon(FontAwesomeIcons.syncAlt)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ),
                        RichText(text: TextSpan(text: " ")),
                        TextFormField(
                          enabled: false,
                          // TODO la descrizione può richiedere più linee
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0),
                          initialValue:
                              "Descrizione: " + lessonChange.description,
                          decoration: InputDecoration(
                              prefixIcon: Icon(FontAwesomeIcons.fileAlt,
                                  color: Colors.white, size: 25.0)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ),
                        RichText(text: TextSpan(text: " ")),
                        TextFormField(
                          enabled: false,
                          maxLines: 3,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0),
                          initialValue: "Insegnamento: " +
                               lessonChange.teaching.nomeInsegnamento + " " + lessonChange.teaching.indirizzo + " " + lessonChange.teaching.cfu,
                          decoration: InputDecoration(
                              prefixIcon: Icon(FontAwesomeIcons.userGraduate,
                                  color: Colors.white, size: 25.0)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ),
                        RichText(text: TextSpan(text: " ")),
                        lessonChange.type == "Rinvio"
                            ? TextFormField(
                                enabled: false,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20.0),
                                initialValue: "Aula: " + lessonChange.classRoom,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.home,
                                        color: Colors.white, size: 25.0)),
                              )
                            : SizedBox(),
                        lessonChange.type == "Rinvio" ? Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ) : SizedBox(),
                        RichText(text: TextSpan(text: " ")),
                        lessonChange.type == "Rinvio"
                            ? TextFormField(
                                enabled: false,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20.0),
                                initialValue: "Orario: " +
                                    lessonChange.newTime.toString(),
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.access_time,
                                        color: Colors.white, size: 25.0)),
                              )
                            : SizedBox(),
                        lessonChange.type == "Rinvio"
                            ? Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 1.0))),
                        ) : SizedBox(),
                      
                        Container(
                          //margin: EdgeInsets.fromLTRB(130.0, 25.0, 0, 0),
                          //height: 15.0,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.thumb_up,
                                          color: lessonChange.liked
                                              ? Colors.green
                                              : Colors.white,
                                          size: 25.0),
                                      onPressed: () async {
                                        print(lessonChange.liked);
                                        print(lessonChange.disliked);
                                        print("before");
                                        //TODO
                                        String url =
                                            getUrlHome() + "lessonsChangeLike";
                                        http.Response response =
                                            await http.post(url, headers: {
                                          HttpHeaders.authorizationHeader:
                                              await getToken()
                                        }, body: {
                                          "id": lessonChange.id,
                                          "liked": "${lessonChange.liked}",
                                          "disliked": "${lessonChange.disliked}"
                                        });
                                        checkResponseStatus(response, context);
                                        if (response.statusCode == 201) {
                                          setState(() {
                                            var jsonData = json
                                                .decode(response.body)["data"];
                                            List<String> likes =
                                                jsonData["likes"]
                                                    .cast<String>();
                                             List<String> dislikes =
                                                jsonData["dislikes"]
                                                    .cast<String>();
                                            lessonChange.likes = likes.length;
                                            lessonChange.dislikes = dislikes.length;
                                            lessonChange.liked =
                                                likes.contains(myUsername);
                                            if(lessonChange.liked == true) {
                                              lessonChange.disliked = false;
                                            }
                                            print(lessonChange.liked);
                                            print(lessonChange.disliked);
                                            print(lessonChange.likes);
                                          });
                                        } else {
                                          //TODO: Gestire errore
                                        }
                                      },
                                    ),
                                    Text(
                                      lessonChange.likes.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 16.0),
                                    )
                                  ],
                                ),
                              ),
                              RichText(text: TextSpan(text: "     ")),
                              RichText(text: TextSpan(text: "     ")),
                              RichText(text: TextSpan(text: "     ")),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.thumb_down,
                                          color: lessonChange.disliked
                                              ? Colors.red
                                              : Colors.white,
                                          size: 25.0),
                                      onPressed: () async {
                                        //TODO
                                        String url = getUrlHome() +
                                            "lessonsChangeDislike";
                                        http.Response response =
                                            await http.post(url, headers: {
                                          HttpHeaders.authorizationHeader:
                                              await getToken()
                                        }, body: {
                                          "id": lessonChange.id,
                                          "liked": "${lessonChange.liked}",
                                          "disliked": "${lessonChange.disliked}"
                                        });
                                        checkResponseStatus(response, context);
                                        if (response.statusCode == 201) {
                                          setState(() {
                                            var jsonData = json
                                                .decode(response.body)["data"];
                                            List<String> dislikes =
                                                jsonData["dislikes"]
                                                    .cast<String>();
                                                    print(dislikes);
                                            lessonChange.dislikes =
                                                dislikes.length;
                                                List<String> likes =
                                                jsonData["likes"]
                                                    .cast<String>();
                                                    lessonChange.likes = likes.length;
                                            lessonChange.disliked = dislikes
                                                .contains(myUsername);
                                                print(myUsername);
                                            print(lessonChange.disliked);
                                            if (lessonChange.disliked) {
                                              lessonChange.liked = false;
                                            }
                                            /*lessonChange.liked == true
                                              ? lessonChange.liked = false
                                              : lessonChange.liked = true;
                                              */
                                          });
                                          print(lessonChange.liked);
                                          print(lessonChange.disliked);
                                          print(lessonChange.dislikes);
                                        } else {
                                          //TODO: Gestire errore
                                        }
                                      },
                                    ),
                                    Text(
                                      lessonChange.dislikes.toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 16.0),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ])));
  }
}
