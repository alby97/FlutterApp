import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:youni_app/utils/categories.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/homeScreenArguments.dart';
import 'colors.dart' as myColors;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:youni_app/utils/utility.dart' as utils;
import 'package:flutter_spinkit/flutter_spinkit.dart';
class CompleteProfileScreen extends StatefulWidget {
  CompleteProfileScreen() {
    utils.setLastRoute('/completeProfileScreen');
  }

  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with WidgetsBindingObserver {
  List<dynamic> departments;
  List<Corso> corsi = new List<Corso>();
  List<String> anni = new List<String>();
  List<String> addresses = new List<String>();
  List<Category> interestsCategories = new List<Category>();
  Map<String, bool> interestsChosen;

  String dep;
  String nameCourse;
  String typeCourse;
  String yearChosen;
  String addressCourse;

  bool _waitingResp = true;
  bool _firstOpComplete = false;
  bool _secondOpComplete = false;
  bool _thirdOpComplete = false;
  bool _getInterests = false;

  TextEditingController nameController, surnameController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //da aggiustare gli anni, vanno presi dal db (dal primo anno fino all'ultimo)
    /*
    int annoPrec = 2006;
    int annoSucc = 2007;
    int target = 2019;
    List<String> tmp = new List<String>();
    for (; annoPrec < target; annoPrec++, annoSucc++) {
      tmp.add(annoPrec.toString() + "/" + annoSucc.toString());
    }
    */
    _getDepartments().then((res) {
      setState(() {
        print("SetSt");
        departments = res;
       // anni = tmp;
        _waitingResp = false;
      });
      getCategories().then((list) {
        setState(() {
          interestsCategories = createCategoriesList(list);
          interestsChosen = new Map<String, bool>();
          for(int i = 0; i < interestsCategories.length; i++) {
            interestsChosen[interestsCategories[i].name] = false;
          }
          print(interestsChosen.toString());
          _getInterests = true;
        });
      });
    });
    nameController = new TextEditingController();
    surnameController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
          title: Text('Completa il tuo profilo',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Avenir Next',
            fontSize: 20.0
          ),),
          elevation: 0.1,
        ),
        body: _waitingResp == true
            ? _showIndicator()
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(3.0, 26.0, 3.0, 8.0),
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.0),
                      child: ExpansionTile(
                          title: Text(
                            "Dipartimenti",
                            style: TextStyle(color: Colors.white,
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
                                        style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15.0)),
                                  )))
                              .toList()),
                    ),
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
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    Center(
                      child: TextField(
                        style: TextStyle(color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 17.0),
                        controller: nameController,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          hintStyle: TextStyle(
                              color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
                          hintText: 'Nome',
                          labelStyle: TextStyle(color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 17.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Center(
                      child: TextField(
                        style: TextStyle(color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 17.0),
                        controller: surnameController,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          hintStyle: TextStyle(
                              color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
                          hintText: 'Cognome',
                          labelStyle: TextStyle(color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 17.0),
                        ),
                      ),
                      
                    ),
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Center(
                      child: _getInterests == true ? _showInterests() : SizedBox(),
                      
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    RichText(
                      text: TextSpan(text: ""),
                    ),
                    Center(
                      child: FlatButton(
                        child: Text("Completa il profilo",
                        style: TextStyle(color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 17.0)),
                        onPressed: () {
                          _sendCompleteProfile(context);
                        },
                      ),
                    )
                  ],
                )),
              ));
  }

  Future<List<dynamic>> _getDepartments() async {
    var token = await _getToken();
    var url = utils.getUrlHome() + "getDepartments";
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
    var token = await _getToken();
    var url = utils.getUrlHome() + "getCourses";
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
        _firstOpComplete = true;
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

  Future<String> _getToken() async {
    final String key = "token";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(key);
    return token;
  }

  Widget _showIndicator() {
    return Center(
      child: SpinKitPouringHourglass(
                    color: Colors.white,
                    size: 50.0,
                  )
    );
  }

  Widget _showCourses() {
    if (_firstOpComplete == false) {
      return Text(
        "Non è stato selezionato alcun dipartimento.",
        style: TextStyle(color: Colors.white,
        fontFamily: 'Avenir Next',
        fontSize: 17.0),
      );
    }
    return Container(
        padding: EdgeInsets.all(6.0),
        child: ExpansionTile(
          key: new GlobalKey(),
            title: Text(
              "Corsi di studio",
              style: TextStyle(color: Colors.white,
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
                              _saveCourse(val.nomeCorso, val.tipo);
                            },
                          style: TextStyle(color: Colors.white,
                          fontFamily: 'Avenir Next',
                          fontSize: 15.0),
                          children: <TextSpan>[
                            TextSpan(
                              text: " : " + val.tipo,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  print("Tap");
                                  await _saveCourse(val.nomeCorso, val.tipo);
                                },
                              style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15.0),
                            )
                          ]),
                    )))
                .toList()));
  }


  Widget _showCourseAddresses ()  {
    if(_thirdOpComplete == false) {
      return Text('');
    }
    else {  
      return Container(
              padding: EdgeInsets.all(6.0),
              child: ExpansionTile(
                key: new GlobalKey(),
                title: Text("Indirizzi corso di studio", style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0)),
                children: addresses.map(
                  (val) => new ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: val,
                        recognizer: TapGestureRecognizer()..onTap = () {
                          setState(() {
                           addressCourse = val; //! da vedere se cambia il title da solo 
                          });
                        },
                        style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15.0),
                      ),
                    ),
                  )
                ).toList(),
              ),
            );
          }
        }

  Widget _showInterests () {
    return ExpansionTile(
      title: Text("Mostra interessi", style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0)),
      children: interestsCategories.map((val) => CheckboxListTile(
        value: interestsChosen[val.name],
        onChanged: (newValue) {
          setState(() {
           interestsChosen[val.name] = newValue; 
          });
        },
        title: RichText(
          text: TextSpan(
            text: val.name,
            style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next')
          ),
        ),
      )).toList(),
    );
  }

  Future<void> _saveCourse(String nomeCorso, String tipoCorso) async {
    /*
    for (int i = 0; i < corsi.length; i++) {
      if (corsi[i].nomeCorso == corso) {
        courseSelected = i;
        break;
      }
    }
    */
    nameCourse = nomeCorso;
    typeCourse = tipoCorso;
    http.post(utils.getUrl() + "getYears", body: {
      "nomeCorso": nomeCorso,
      "tipoCorso": tipoCorso
    }).then((response) {
      print(response.body);
      checkResponseStatus(response, context);
      if (response.statusCode == 201) {
        int yearMin = json.decode(response.body)["yearMin"];
        int yearMax = json.decode(response.body)["yearMax"];
        List<String> tmp = new List<String>();
        for (; yearMin < yearMax; yearMin++) {
          tmp.add(yearMin.toString() + "/" + (yearMin + 1).toString());
          setState(() {
            anni = tmp;
            _secondOpComplete = true;
          });
        }
      } else {
        //TODO: gestisci errore
      }
    });
  }

  Widget _showYears(BuildContext context) {
    if (_secondOpComplete == false) {
      return Text('');
    }
    return Container(
      padding: EdgeInsets.all(6.0),
      child: ExpansionTile(
        key: new GlobalKey(),
        title: Text(
          "Anno di iscrizione",
          style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
        ),
        children: anni
            .map((val) => new ListTile(
                  title: new RichText(
                    text: TextSpan(
                      text: val,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          yearChosen = val;
                          await _getAddresses();
                          //_sendCompleteProfile(context, val);
                        },
                      style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 15.0),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

Future <void> _getAddresses () async {
  String token = await utils.getToken();
  print(token);
  String url = utils.getUrlHome()+"getCourseAddresses";
  Response response = await http.post(url, headers: {HttpHeaders.authorizationHeader : token}, body: {
          "course_name" : nameCourse,
          "course_type" : typeCourse,
          "course_year" : yearChosen
        });
  if(response.statusCode == 201) {
    print(json.decode(response.body));
    List<dynamic> jsonData = json.decode(response.body);
    addresses =  (jsonData).cast<String>();
    setState(() {
     _thirdOpComplete = true; 
    });
  }
  else {
    //TODO: gestire errore
  }
}


  void _createCoursesList(List json) {
    List<Corso> tmp = new List<Corso> ();
    for (int i = 0; i < json.length; i++) {
      print(json[i]);
      Corso c = Corso.fromJson(json[i]);
      tmp.add(c);
    }
    corsi = tmp;
  }

  void _sendCompleteProfile(BuildContext context) async {
    var token = await _getToken();
    var url = utils.getUrlHome() + "completeProfile";
    //print(corsi[courseSelected]);
    //var info = corsi[courseSelected].tipo;

    List<String> interessi = new List<String>();
    interestsChosen.forEach((key, value) {
      if(value == true) {
        interessi.add(key);
      }
    });
    var jsonObj = {
      "interests": interessi
    };
    var jsonString = json.encode(jsonObj);
    
    //TODO: aggiungere dei controlli per verificare che ogni campo sia stato completato/selezionato
    var payload = {
      "dipartimento": "$dep",
      "corso": "$nameCourse",
      "anno": "$yearChosen",
      "tipo": "$typeCourse",
      "nome" : "${nameController.text}",
      "cognome" : "${surnameController.text}",
      "indirizzo" : "$addressCourse",
      "interessi" : "$jsonString"
    };
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token}, body: payload);
        checkResponseStatus(response, context);
    if (response.statusCode == 201) {
      //TODO: Salvare in locale i corsi e il dipartimento, ogni volta che si accede al profilo controllare che il dipartimento e il corso non sia cambiato
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString('CdS', nameCourse);
      sp.setString('Dep', dep);
      print(response.body);
      await utils.saveToken(json.decode(response.body)["token"]);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              title: Text("Completamento profilo",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20
              )),
              content: Text(
                  "Hai completato il profilo con successo! Verrai reindirizzato alla home page.",
                  style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        'homeScreen', (Route<dynamic> route) => false,
                        arguments: HomeScreenArguments("3h", "registration")
                        );
                  },
                  child: Text(
                    "Chiudi",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              title: Text("Completamento profilo",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
              content: Text("C'è stato un errore, riprovare.",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popAndPushNamed('/completeProfileScreen');
                  },
                  child: Text(
                    "Chiudi",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            );
          });
    }
  }
}

class Corso {
  final String nomeCorso;
  final String tipo;

  Corso(this.nomeCorso, this.tipo);

  Corso.fromJson(Map<String, dynamic> json)
      : nomeCorso = json['course_name'],
        tipo = json['course_type'];

    @override
    String toString() {
    return nomeCorso + " " + tipo;
     }
}
