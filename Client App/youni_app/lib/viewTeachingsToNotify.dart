import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/firebaseMsgUtils.dart';
import 'package:youni_app/utils/teaching.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

class ViewTeachingsToNotify extends StatefulWidget {
  
  @override
  _ViewTeachingsToNotifyState createState() => _ViewTeachingsToNotifyState();
}

class _ViewTeachingsToNotifyState extends State<ViewTeachingsToNotify> with WidgetsBindingObserver {

bool _waitingResp = true;
List<Teaching> _teachings;

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getTeachingsToNotify().then((list) {
      //_teachings = createTeachingsList(list);
      _teachings = new List<Teaching>();
      print(list);
      for(int i = 0; i < list.length; i++) {
        var tmp = json.decode(list[i][0]);
        print(tmp);
        _teachings.add(Teaching.fromJson(tmp));
      }
      setState(() {
        _waitingResp = false;
      });
    });
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
      return true;
    } else if (response.statusCode == 400) {
      return false;
    }
    else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: _waitingResp == true ? Center(
         child: SpinKitPouringHourglass(
           color: Colors.white,
         ),
       ) : Container(
         child: _teachings.isEmpty ? Center(
           child: Text("Non hai insegnamenti preferiti.", style: TextStyle(fontFamily: 'Avenir Next', fontSize: 20),),
         ) : ListView(
         children: List.generate(_teachings.length, (i) {
           return ListTile(
                      title: Text("Nome: " +
                          _teachings[i].nomeInsegnamento +
                          ", indirizzo: " +
                          _teachings[i].indirizzo +
                          ", CFU: " +
                          _teachings[i].cfu),
                          trailing: IconButton(
                            icon: Icon(FontAwesomeIcons.trashAlt, color: Colors.red,),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                  title: Text("Rimozione insegnamento",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20
                                  ),),
                                  content: Text("Sei sicuro/a di voler rimuovere questo insegnamento? Non riceverai più notifiche di variazioni e/o annullamento per questo insegnamento",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20
                                  ),),
                                  actions: <Widget>[
                                    FlatButton.icon(icon: Icon(FontAwesomeIcons.checkCircle, color: Colors.green,),onPressed: () {
                                      //TODO: rimuovi insegnamento
                                      _unsubscribeTeaching(_teachings[i]).then((val) {
                                        if(val == true) {
                                          setState(() {
                                            _teachings.removeAt(i);
                                          });
                                        }
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    label: Text("Sì"),),
                                    FlatButton.icon(icon: Icon(FontAwesomeIcons.timesCircle, color: Colors.red,),onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    label: Text("No"),)
                                  ],
                                )
                              );
                            },
                          ),);
         }),
       ),
       )
    );
  }
}