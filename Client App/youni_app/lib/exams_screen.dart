import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youni_app/utils/utility.dart' as utils;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';

class ExamsScreen extends StatefulWidget {
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> with WidgetsBindingObserver {
  /*
  * Si deve mostrare l'elenco degli esami (prendendoli con il corretto anno accademico)
  * A fianco di ogni insegnamento si mette un bottone che abilita/disabilita le notifiche per quell'insegnamento
  */
  List<_Teaching> teachings;
  bool opCOmplete = false;
  List<bool> switchersValues;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getTeachings().then((list) {
      print("Ok1");
      teachings = _createTeachingsList(list);

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
        print("Ok3");
        setState(() {
          print("SetState");
          opCOmplete = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
          child: opCOmplete == false
              ? Container(
                  child: SpinKitPouringHourglass(
                    color: Colors.white,
                    size: 50.0,
                  ))
              : ListView(
                  children: List.generate(teachings.length, (i) {
                    return ListTile(
                      title: Text("Nome: " +
                          teachings[i].nomeInsegnamento +
                          ", indirizzo: " +
                          teachings[i].indirizzo +
                          ", CFU: " +
                          teachings[i].cfu),
                      trailing: Switch(
                        onChanged: (bool value) {
                          if (value == true) {
                            _subscribeTeaching(teachings[i]).then((val) {
                              setState(() {
                                switchersValues[i] = true;
                              });
                            });
                          } else {
                            _unsubscribeTeaching(teachings[i]).then((val) {
                              setState(() {
                                switchersValues[i] = false;
                              });
                            });
                          }
                        },
                        value: switchersValues[i],
                      ),
                    );
                  }),
                )),
    );
  }

/* 
TODO: Bisogna fare un metodo che quando si accede a questa schermata controlla per quali corsi è stata abilitata la notifica quindi va mandata una 
TODO: richiesta http che contatti poi il database e restituisca la lista dei corsi di cui si è abilitata la notifica
TODO: in questo modo poi si devono settare i valori booleani dell'array che viene utilizzato per gli switcher
TODO: Inoltre va capito bene il fatto dei deviceIds: Se una volta rimosso il deviceId (quando si fa il logout) bisogna fare l'unsubscribe
TODO: di tutti i corsi oppure no.
! Da verificare questa cosa qui sopra
*/

  Future<Widget> _subscribeTeaching(_Teaching t) async {
    String teaching = t.toString();
    FirebaseMessaging _fMessaging = FirebaseMessaging();
    _fMessaging.subscribeToTopic(teaching.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_'));
    print("Subscription done");
    var url = utils.getUrlHome() + "subscribeTeaching";
    var token = await utils.getToken();
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {'teaching': teaching});
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      return SimpleDialog(
        title: Text(response.body),
        children: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => {Navigator.of(context).pop()},
          )
        ],
      );
    } else if (response.statusCode == 400) {
      return SimpleDialog(
        title: Text(response.body),
        children: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => {Navigator.of(context).pop()},
          )
        ],
      );
    }
  }

  Future<Widget> _unsubscribeTeaching(_Teaching t) async {
    String teaching = t.toString();
    FirebaseMessaging _fMessaging = FirebaseMessaging();
    _fMessaging.unsubscribeFromTopic(teaching.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_'));
    print('Unsubscription done');
    var url = utils.getUrlHome() + "unsubscribeTeaching";
    var token = await utils.getToken();
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {'teaching': teaching});
        checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      return SimpleDialog(
        title: Text(response.body),
        children: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => {Navigator.of(context).pop()},
          )
        ],
      );
    } else if (response.statusCode == 400) {
      return SimpleDialog(
        title: Text(response.body),
        children: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => {Navigator.of(context).pop()},
          )
        ],
      );
    }
  }

  Future<List> _getTeachingsToNotify() async {
    String token = await utils.getToken();
    var url = utils.getUrlHome() + "getTeachingsToNotify";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      print("if 200");
      List teachsToNotify = json.decode(response.body);
      return teachsToNotify;
    } else {
      print('Errore');
      //TODO: gestire errore
      return new List();
    }
  }

  Future<List> _getTeachings() async {
    String token = await utils.getToken();
    http.Response response = await http.get(utils.getUrlHome() + 'getTeachings',
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

  List<_Teaching> _createTeachingsList(List<dynamic> jsonList) {
    List<_Teaching> tmp = new List<_Teaching>();
    for (int i = 0; i < jsonList.length; i++) {
      print(jsonList[i]);
      tmp.add(_Teaching.fromJson(jsonList[i]));
    }
    return tmp;
  }
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
      : nomeInsegnamento = json['DES AD'],
        indirizzo = json['DES IND'],
        cfu = json['CFU AD'].toString();
}
