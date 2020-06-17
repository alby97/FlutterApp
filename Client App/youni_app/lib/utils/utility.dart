import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart' as devInfo;
import 'package:http/http.dart' as http;
import 'package:youni_app/utils/firebaseMsgUtils.dart' as firebaseMsgUtils;
import 'package:youni_app/utils/teaching.dart';
/**
 * Qui verranno inseriti i metodi che sono utilizzati in più classi
 * Come getToken
 * 
 */

Future<String> getToken() async {
  final String key = "token";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(key);
  print("Token utils");
  print(token);
  //print(token.substring(10, token.length - 2));
  return token; //.substring(10, token.length -2);
}

Future<bool> saveToken(/*http.Response*/ String content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("token", content);
}

Future<bool> saveFToken(String ftoken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("ftoken", ftoken);
}

Future<String> getFToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("ftoken");
}

Future<bool> saveValue(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
}

Future<String> getValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(key);
  return value;
}

Future<bool> removeValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
}

String getCourseKey() {
  return 'CdS';
}

String getCourseTypeKey() {
  return 'CdT';
}

String getUserKey() {
  return 'Username';
}

Future<String> getDeviceInfo() async {
  devInfo.DeviceInfoPlugin deviceInfo = devInfo.DeviceInfoPlugin();
  if (Platform.isAndroid) {
    devInfo.AndroidDeviceInfo andrInfo = await deviceInfo.androidInfo;
    return andrInfo.androidId;
  } else if (Platform.isIOS) {
    devInfo.IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor;
  }
}

String getUrl() {
  return "https://youniserverlabeu.herokuapp.com/";
  /*"http://10.0.2.2:5000/"*/
}

String getUrlHome() {
  return "https://youniserverlabeu.herokuapp.com/home/"; /*"http://10.0.2.2:5000/home/"; */
}

Future<bool> setLastRoute(String name) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.setString("lastRoute", name);
}

Future<String> getProperHomeRoute() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String lastRoute = sp.getString("lastRoute");
  return lastRoute;
}

Future<bool> saveListString(String key, List list) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> toSave;
  if(list != null) {
    toSave = list.cast<String>();
  }
  else {
    toSave = new List<String>();
  }
  return prefs.setStringList(key, toSave);
}

Future<List<String>> getListString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> tmp = prefs.getStringList(key);
  return tmp;
}

Future<bool> removeListString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
}

Future<bool> saveBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool(key, value);
}

Future<bool> getBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

Future<bool> removeBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(key);
}

Future<bool> removeToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove("token");
}

Future<String> properFirstRoute() async {
  String route;
  //await removeToken();
  String token = await getToken();
  if (token != null) {
    http.Response response = await http.get(getUrlHome() + "verLogin",
        headers: {HttpHeaders.authorizationHeader: token});
    if (response.statusCode == 200) {
      route = "homeScreen";
    } else {
      print("Logout needed, token expired");
      FirebaseMessaging _firebaseMessaging = firebaseMsgUtils.getInstance();
      List teachsNotify = await getTeachingListToNotify();
      for (int i = 0; i < teachsNotify.length; i++) {
        String tmp = teachsNotify[i];
        tmp = tmp.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_');
        print(tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
      }
      List<String> joinedChats = await getListString("joinedChats");
      for (int i = 0; i < joinedChats.length; i++) {
        String tmp = /*"CHAT_" +*/ joinedChats[i];
        tmp = tmp.replaceAll(new RegExp(' '), '_');
        print("Tmp: " + tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
      }
      var url = getUrlHome() + "removeDeviceId";
      var token = await getToken();
      var deviceId = await getFToken();
      await http.post(url,
          headers: {HttpHeaders.authorizationHeader: token},
          body: {'deviceId': deviceId});
      bool ver = await removeToken();
      await removeBool("firstAccess");
      await saveBool("logoutDone", true);
      await removeValue("Username");
      await removeValue("name");
      await removeValue("surname");
      route = "firstScreen";
    }
  } else {
    if (await getBool("logoutDone") == false) {
      FirebaseMessaging _firebaseMessaging = firebaseMsgUtils.getInstance();
      List teachsNotify = await getTeachingListToNotify();
      for (int i = 0; i < teachsNotify.length; i++) {
        String tmp = teachsNotify[i];
        tmp = tmp.replaceAll(RegExp(' '), '_');
        print(tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
      }
      List<String> joinedChats = await getListString("joinedChats");
      for (int i = 0; i < joinedChats.length; i++) {
        firebaseMsgUtils.unsubscribeChat(joinedChats[i]);
        /*String tmp = "CHAT_" + joinedChats[i];
        tmp = tmp.replaceAll(new RegExp(' '), '_');
        print("Tmp: " + tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
        */
      }
      var url = getUrlHome() + "removeDeviceId";
      var token = await getToken();
      var deviceId = await getFToken();
      await http.post(url,
          headers: {HttpHeaders.authorizationHeader: token},
          body: {'deviceId': deviceId});
      bool ver = await removeToken();
      await removeBool("firstAccess");
      await saveBool("logoutDone", true);
      await removeValue("Username");
      await removeValue("name");
      await removeValue("surname");
      route = "firstScreen";
    }
    else {
      route = "firstScreen";
    }
  }

  return route;
}


Future<void> logout(BuildContext context) async {
    print("Logout");
    FirebaseMessaging _firebaseMessaging = firebaseMsgUtils.getInstance();
    List teachsNotify = await getTeachingListToNotify();
    if (teachsNotify != null) {
      for (int i = 0; i < teachsNotify.length; i++) {
        Teaching tmpT = Teaching.fromJson(json.decode(teachsNotify[i][0]));
        String tmp = tmpT.toString(); //teachsNotify[i];
        tmp = tmp.replaceAll(RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_');
        print(tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
      }
    }
    List<String> joinedChats = await getListString("joinedChats");
    if (joinedChats != null) {
      for (int i = 0; i < joinedChats.length; i++) {
        firebaseMsgUtils.unsubscribeChat(joinedChats[i]);
        /*String tmp = "CHAT_" + joinedChats[i];
        tmp = tmp.replaceAll(new RegExp(' '), '_');
        print("Tmp: " + tmp);
        print(utf8.encode(tmp).toString());
        print(utf8.decode(utf8.encode(tmp)));
        _firebaseMessaging.unsubscribeFromTopic(tmp);
        */
      }
    }
    List<String> interests = await getInterests();
    if (interests != null) {
      for (int i = 0; i < interests.length; i++) {
        String tmp = "CATEGORIA_" + interests[i];
        tmp.replaceAll(new RegExp(' '), '_');
        print("Tmp: " + tmp);
        _firebaseMessaging.unsubscribeFromTopic(tmp);
      }
    }
    var url = getUrlHome() + "removeDeviceId";
    var token = await getToken();
    var deviceId = await getFToken();
    await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {'deviceId': deviceId});
    bool ver = await removeToken();
    await removeBool("firstAccess");
    await removeValue("Username");
    await removeValue("name");
    await removeValue("surnname");
    await removeListString("joinedChats");
    await saveBool("logoutDone", true);
    if (ver == true) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("C'è stato un errore di autenticazione, probabilmente la sessione è scaduta. Per favore esegui nuovamente il login"),
            actions: <Widget>[
              FloatingActionButton(
                child: Text("Ok"),
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
          "firstScreen", (Route<dynamic> route) => false),
              )
            ],
          );
        }
      );
      /*Navigator.of(context).pushNamedAndRemoveUntil(
          "firstScreen", (Route<dynamic> route) => false);
          */
    }
  }

   Future<List<String>> getInterests() async {
    String token = await getToken();
    String url = getUrlHome() + "getUserInterests";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    if (response.statusCode == 200) {
      print(response.body);
      if (response.body != null && response.body != "") {
        List<String> tmp = ((json.decode(response.body))).cast<String>();
        return tmp;
      } else {
        return new List<String>();
      }
    } else {
      //TODO: gestisci errore
      print("Error interests");
      return new List<String>();
    }
  }
