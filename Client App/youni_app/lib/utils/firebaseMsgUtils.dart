import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

FirebaseMessaging getInstance() {
  return _firebaseMessaging;
}

void setInstance(FirebaseMessaging fm) {
  _firebaseMessaging = fm;
}


void subscribeChatNew(String idChat, bool isAcademic) {
  if(isAcademic) {
    _firebaseMessaging.subscribeToTopic("chat_acc_"+idChat);
  }
  else {
    _firebaseMessaging.subscribeToTopic("chat_sv_"+idChat);
  }
}


void unsubscribeChatNew(String idChat, bool isAcademic) {
  if(isAcademic) {
    _firebaseMessaging.unsubscribeFromTopic("chat_acc_"+idChat);
  }
  else {
    _firebaseMessaging.unsubscribeFromTopic("chat_sv_"+idChat);
  }
}



void subscribeChatHome (String id) {
  _firebaseMessaging.subscribeToTopic(id);
}


void subscribeChat(String chatName) {
  String chatTopic = "CHAT_" + chatName;
  RegExp reg = new RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
  List<RegExpMatch> matches = reg.allMatches(chatTopic).toList();
  for (int i = 0; i < matches.length; i++) {
    print(matches[i].start);
    print(matches[i].end);
    //TODO:tmp.replaceRange(matches[i].start, matches[i].end, )
    String subTmp = chatTopic.substring(matches[i].start, matches[i].end);
    /*print(subTmp);
                            print(subTmp.codeUnits);
                            */
    List<int> codeUnits = subTmp.codeUnits;
    String stringToReplace = "";
    for (int i = 0; i < codeUnits.length; i++) {
      stringToReplace += codeUnits[i].toString();
      if (i < codeUnits.length - 1) {
        stringToReplace += "_";
      }
    }
    chatTopic = chatTopic.replaceRange(
        matches[i].start, matches[i].end, stringToReplace);
        chatTopic = chatTopic.replaceAll(new RegExp(' '), "_");
  }
  _firebaseMessaging.subscribeToTopic(chatTopic);
  print("Subscribed topic: " + chatTopic);
}

void unsubscribeChat(String chatName) {
  _firebaseMessaging.unsubscribeFromTopic(chatName);
  /*String chatTopic = "CHAT_" + chatName;
  RegExp reg = new RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
  List<RegExpMatch> matches = reg.allMatches(chatTopic).toList();
  for (int i = 0; i < matches.length; i++) {
    print(matches[i].start);
    print(matches[i].end);
    //TODO:tmp.replaceRange(matches[i].start, matches[i].end, )
    String subTmp = chatTopic.substring(matches[i].start, matches[i].end);
    print(subTmp);
                            print(subTmp.codeUnits);
                            
    List<int> codeUnits = subTmp.codeUnits;
    String stringToReplace = "";
    for (int i = 0; i < codeUnits.length; i++) {
      stringToReplace += codeUnits[i].toString();
      if (i < codeUnits.length - 1) {
        stringToReplace += "_";
      }
    }
    chatTopic = chatTopic.replaceRange(
        matches[i].start, matches[i].end, stringToReplace);
    chatTopic = chatTopic.replaceAll(new RegExp(' '), "_");
  }
  _firebaseMessaging.unsubscribeFromTopic(chatTopic);
  print("Unsubscribed topic: " + chatTopic);
  */
}

void subscribeTeaching (String teaching) async {
  RegExp reg = new RegExp(r"(?![a-zA-Z0-9-_.~%]+).");
  teaching = teaching.replaceAll(reg, "_");
  print(teaching);
  await _firebaseMessaging.subscribeToTopic(teaching);
}

void unsubscribeTeaching (String teaching) async {
  RegExp reg = new RegExp(r"(?![a-zA-Z0-9-_.~%]+).");
  teaching = teaching.replaceAll(reg, "_");
  print(teaching);
  await _firebaseMessaging.unsubscribeFromTopic(teaching);
}