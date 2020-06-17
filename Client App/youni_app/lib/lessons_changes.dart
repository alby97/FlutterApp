import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/chooseTeachingsNotifications.dart';
import 'package:youni_app/colors.dart' as myColor;
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart' as utils;
import 'package:http/http.dart' as http;
import 'package:youni_app/viewTeachingsToNotify.dart';
import 'create_new_lesson_change_screen.dart';
import 'lesson_change_details_screen.dart';

class LessonsChangesScreen extends StatefulWidget {
  _LessonsChangesScreenState createState() => _LessonsChangesScreenState();
}

class _LessonsChangesScreenState extends State<LessonsChangesScreen>
    with WidgetsBindingObserver {
  List<LessonChange> lessonsChanges;
  bool opComplete = false;

  final GlobalKey<RefreshIndicatorState> _refKey =
      new GlobalKey<RefreshIndicatorState>();

  /*
   * In the initState first send a request to get the lessons changes specifying course name and type
   * 
   * 
   * 
   * 
   */

  void _buildLessonsChangesList() {
    getLessonsChanges().then((list) {
      //print("List:");
      //print(list);
      lessonsChanges = _createLessonsChangesList(list);
      setState(() {
        //TODO: Va aggiunto il timestamp e va fatto l'ordinamento con quello
        lessonsChanges.sort((a, b) {
          if (a.timestamp.compareTo(b.timestamp) == 1) {
            return -1;
          } else if (a.timestamp.compareTo(b.timestamp) == -1) {
            return 1;
          }
          return 0;
        });

        opComplete = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buildLessonsChangesList();
    /*
    getLessonsChanges().then((list) {
      print("List:");
      print(list);
      lessonsChanges = _createLessonsChangesList(list);
      setState(() {
        lessonsChanges.sort((a, b) {
          if (a.newTime.compareTo(b.newTime) == 1) {
            return -1;
          } else if (a.newTime.compareTo(b.newTime) == -1) {
            return 1;
          }
          return 0;
        });
        opComplete = true;
      });
    });*/
  }

  Future<List<dynamic>> getLessonsChanges() async {
    String token = await utils.getToken();
    String url = utils.getUrlHome() + 'getLessonsChanges';
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
        checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      List l = json.decode(response.body);
     // print("L: ");
    //  print(l);
      return l;
    } else {
      return List(); //! da aggiustare
    }
  }

  void refresh() {
    _buildLessonsChangesList();
  }

  List<LessonChange> _createLessonsChangesList(List<dynamic> jsonList) {
    List<LessonChange> tmp = new List<LessonChange>();
    print(jsonList);
    if (jsonList != null) {
      for (var i = 0; i < jsonList.length; i++) {
        print(jsonList[i]);
        LessonChange lc = LessonChange.fromJson(jsonList[i]);
        /* List<String> list = jsonList[i]["likes"].cast<String>();
        lc.likes = list.length;
        lc.liked = list.contains(utils.getValue('Username'));
        list = jsonList[i]["dislikes"].cast<String>();
        lc.dislikes = list.length;
        lc.disliked = list.contains(utils.getValue('Username'));
        */
        tmp.add(lc);
      }
    }
    print(tmp);
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    return opComplete == false ? SpinKitPouringHourglass(
            color: Colors.white,
            size: 50.0,
          )
 : Scaffold(
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),

      drawer: Drawer(
          elevation: 2.0,
          child: ListView(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(13.0, 7.0, 13.0, 2.0),
                title: Text("Scegli insegnamenti da seguire"),
                trailing: Icon(FontAwesomeIcons.arrowRight),
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) =>
                          new ChooseTeachingsNotifications()));
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(13.0, 7.0, 13.0, 2.0),
                title: Text("Visualizza gli insegnamenti preferiti"),
                trailing: Icon(FontAwesomeIcons.arrowRight),
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ViewTeachingsToNotify()));
                },
              )
            ],
          )),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        title: Text('Variazione Lezione'),
        bottom: PreferredSize(child: Container(color: Colors.red, height: 2), preferredSize: Size.fromHeight(2))
      ),
      body: /* Container(
            child:*/
          (opComplete == false || lessonsChanges.length <= 0)
              ? Stack(
                  children: <Widget>[
                    
                    Center(
                      child: Text('Non ci sono variazioni da visualizzare',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 15
                      ),),
                    ),
                  ],
                )
              : Container(
                  child: //<Widget>[
                      RefreshIndicator(
                  key: _refKey,
                  onRefresh: () async {
                    setState(() {
                      _buildLessonsChangesList();
                    });
                  },
                  
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(lessonsChanges.length, (i) {
                      return Card(
                          elevation: 8.0,
                          // ! Vedi se occorre inserire altre cose
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          LessonChangeDetailsScreen(
                                            id: lessonsChanges[i].id,
                                          )))
                                  .then((value) {
                                refresh();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(25, 25, 25, .9)),
                              height: 120.0,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        30.0, 45.0, 10, 50.0),
                                    child: Icon(lessonsChanges[i].type == "Annullamento" ? FontAwesomeIcons.times: FontAwesomeIcons.sync,
                                        color: Colors.white, size: 30.0),
                                  ),
                                  RichText(
                                    text: TextSpan(text: ""),
                                  ),
                                  RichText(
                                    text: TextSpan(text: ""),
                                  ),
                                  
                                  Container(
                                    color: Colors.white,
                                    height: 50,
                                    width: 2,
                                  ),
                                 RichText(text: TextSpan(text: " ")),
                                  RichText(text: TextSpan(text: " ")),
                                  RichText(
                                    text: TextSpan(
                                        text: lessonsChanges[i]
                                            .teaching
                                            .nomeInsegnamento + " " + lessonsChanges[i].teaching.indirizzo + " " + lessonsChanges[i].teaching.cfu, //Mostro il nome dell'insegnamento
                                        style: TextStyle(
                                            fontFamily: 'Avenir Next',
                                            fontSize: 15.0,
                                            color: Colors.white),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "\n" + lessonsChanges[i].type,
                                            style: TextStyle(
                                                fontFamily: 'Avenir Next',
                                                color: Colors.white,
                                                fontSize: 15.0),
                                          ),
                                          TextSpan(
                                            text: lessonsChanges[i]
                                                        .description
                                                        .length >
                                                    15
                                                ? "\n" +
                                                    lessonsChanges[i]
                                                        .description
                                                        .substring(0, 15) +
                                                    '...'
                                                : "\n" +
                                                    lessonsChanges[i]
                                                        .description,
                                            style: TextStyle(
                                                fontFamily: 'Avenir Next',
                                                color: Colors.white,
                                                fontSize: 15.0),
                                          ),
                                          TextSpan(
                                              text: lessonsChanges[i].authorName != null && lessonsChanges[i].authorSurname != null ? "\n" +
                                                  lessonsChanges[i].authorName + " " + lessonsChanges[i].authorSurname : "",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Avenir Next',
                                                  fontSize: 15.0))
                                        ]),
                                  ),
                                  Expanded(
                                    //padding: EdgeInsets.fromLTRB(150.0, 45.0, 0.0, 50.0),
                                    child: Icon(Icons.keyboard_arrow_right,
                                        size: 30.0, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    }),
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        heroTag: 'buttAdd',
        backgroundColor: Color.fromRGBO(76, 76, 76, 0.9),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => new CreateNewLessonChangeScreen()));
        },
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Aggiungi una nuova variazione',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class LessonChange {
  _Teaching teaching;
  String description, author, courseName, courseType, type, classRoom, id, authorName, authorSurname;
  int likes, dislikes;
  DateTime newTime;
  DateTime timestamp;
  bool liked, disliked;

  LessonChange(
      this.teaching,
      this.description,
      this.author,
      this.courseName,
      this.courseType,
      this.type,
      this.classRoom,
      this.likes,
      this.dislikes,
      this.newTime,
      this.timestamp,
      this.id, this.authorName, this.authorSurname);

//!TODO: QUANDO SI CREA LA LISTA AGGIUNGERE UN BOOLEANO CHE DICE SE SI HA AGGIUNTO GIA' IL LIKE, VEDERE SE FARLO QUI O SE FARLO IN DETAILS

  

  static int _createLikes(List<dynamic> jsonLikes) {
    List<String> tmp = jsonLikes.cast<String>();
    return tmp.length;
  }

  static int _createDislikes(List<dynamic> jsonDislikes) {
    List<String> tmp = jsonDislikes.cast<String>();
    return tmp.length;
  }

  static Future<bool> _createLiked(List<dynamic> jsonLikes) async {
    List<String> tmp = jsonLikes.cast<String>();
    print(tmp);

    return tmp.contains(await utils.getValue('Username'));
  }

  static Future<bool> _createDisliked(List<dynamic> jsonDislikes) async {
    List<String> tmp = jsonDislikes.cast<String>();
    print(tmp);
    return tmp.contains(await utils.getValue('Username'));
  }

  LessonChange.fromJson(Map<String, dynamic> jsonMap)
      : teaching = _Teaching.fromJson(jsonMap['teaching']),
        description = jsonMap['description'],
        author = jsonMap['author'],
        courseName = jsonMap['course_name'],
        courseType = jsonMap['course_type'],
        type = jsonMap['type'].toString(),
        classRoom = jsonMap['classroom'],
        likes = _createLikes((jsonMap['likes'])),
        dislikes = _createDislikes(((jsonMap['dislikes']))),
        newTime = jsonMap['new_time'] != ""
            ? DateTime.parse(jsonMap['new_time'])
            : null,
        timestamp = DateTime.parse(jsonMap['timestamp']),
        id = jsonMap['id'],
        authorName = jsonMap["author_name"],
        authorSurname = jsonMap["author_surname"] //,
  //  liked =  (_createLiked((jsonMap['likes']))),
  //  disliked = (_createDisliked(((jsonMap['likes']))))
  ;
}

class _Teaching {
  final String nomeInsegnamento;
  final String indirizzo;
  final String cfu;

  _Teaching(this.nomeInsegnamento, this.indirizzo, this.cfu);

  String toString() {
    return nomeInsegnamento + " " + indirizzo + " " + cfu;
  }

  _Teaching.fromJson(Map<String, dynamic> json)
      : nomeInsegnamento = json['name'],
        indirizzo = json['indirizzo'],
        cfu = json['cfu'].toString();
}
