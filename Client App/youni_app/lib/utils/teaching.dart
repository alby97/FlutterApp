import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youni_app/utils/utility.dart';

class Teaching {
  final String nomeInsegnamento;
  final String indirizzo;
  final String cfu;

  Teaching(this.nomeInsegnamento, this.indirizzo, this.cfu);

  String toString() {
    return nomeInsegnamento + " " + indirizzo + " " + cfu;
  }

  Teaching.fromJson(Map<String, dynamic> json)
      : nomeInsegnamento = json['DES AD'],
        indirizzo = json['DES IND'],
        cfu = json['CFU AD'].toString();

  String toJson() {
    Map<String,dynamic> jsonTeaching = {
      'DES AD' : nomeInsegnamento,
      'DES IND': indirizzo,
      'CFU AD' : cfu
    };
    return json.encode(jsonTeaching);
  }
}

Future<List> getTeachings() async {
    String token = await getToken();
    http.Response response = await http.get(
        getUrlHome() + 'getTeachings',
        headers: {HttpHeaders.authorizationHeader: token});
    print("Fatto");
    print(response.statusCode);
    if (response.statusCode == 200) {
      List l = json.decode(response.body);
      print(l);
      return l;
    } else {
      //restituire errore
      return null;
    }
  }

List<Teaching> createTeachingsList(List<dynamic> jsonList) {
    List<Teaching> tmp = new List<Teaching>();
    for (int i = 0; i < jsonList.length; i++) {
      print(jsonList[i]);
      tmp.add(Teaching.fromJson(jsonList[i]));
    }
    return tmp;
  }

 Future<List> getTeachingsToNotify() async {
    String token = await getToken();
    var url = getUrlHome() + "getTeachingsToNotify";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    print(response.body);
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

Future<bool> saveTeachingListToNotify(List l) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("teachNotify", json.encode(l));
}

Future<List> getTeachingListToNotify() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String s = prefs.getString("teachNotify");
  return json.decode(s);
}