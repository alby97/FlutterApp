import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youni_app/academic_chat.dart';
import 'package:youni_app/utils/academic_chat_class.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:youni_app/utils/utility.dart';
import 'package:youni_app/chat.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class ChatFavoriteScreen extends StatefulWidget {
  _ChatFavoriteScreenState createState() => _ChatFavoriteScreenState();
}

class _ChatFavoriteScreenState extends State<ChatFavoriteScreen>
    with WidgetsBindingObserver {
  List<String> chats, chatsToNotify, ids;
  List<bool>
      areAcademics; //lista che mi serve per capire se la chat i-esima è accademica o no

  String _searchText = "";
  static TextEditingController _filter = new TextEditingController();

  bool done = false;

  bool bottSearchPressed = false;

  Widget appBarTitle = TextField(
    controller: _filter,
    decoration: new InputDecoration(
        prefixIcon: new Icon(Icons.search), hintText: 'Cerca...'),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getListString("joinedChats").then((list) {
      areAcademics = new List<bool>();
      getListString("chatsToNotify").then((list2) {
        chatsToNotify = list2;
        print(chatsToNotify);
        List<int> accTmp =
            new List<int>(); //lista dell'id delle chat accademiche preferite
        List<int> svTmp =
            new List<int>(); //lista dell'id delle chat di svago preferite
        ids = new List<String>();
        for (int i = 0; i < list.length; i++) {
          //print(list[i].substring(list[i].length-2));
          String tmp = list[i].replaceAll(new RegExp(r"[a-z]_*"), "");
          if (list[i].contains("acc")) {
            accTmp.add(int.parse(tmp));
          } else {
            svTmp.add(int.parse(tmp));
          }
          ids.add(tmp);
        }
        getAcademicChats(accTmp).then((listAcc) {
          chats = new List<String>();
          chats.addAll(listAcc);
          areAcademics.addAll(List.generate(chats.length, (i) => true));
          print(areAcademics);
          getChats(svTmp).then((listSv) {
            chats.addAll(listSv);
            areAcademics.addAll(
                List.generate(chats.length - listAcc.length, (i) => false));
            print("AreAc: " + areAcademics.toString());
            print("Done: " + done.toString());
            setState(() {
              done = true;
            });
          });
        });
      });
    });
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Future<List<String>> getAcademicChats(List<int> accTmp) async {
    List<dynamic> tmp = new List<dynamic>();
    List<String> chatsName = new List<String>();
    print(json.encode(accTmp));
    http.Response response = await http.post(
        getUrlHome() + "getAcademicChatsFromId",
        headers: {HttpHeaders.authorizationHeader: await getToken()},
        body: {"chats": json.encode(accTmp)});
    if (response.statusCode == 201) {
      tmp = (json.decode(response.body));
      print(tmp);
      for (int i = 0; i < tmp.length; i++) {
        AcademicChatModel chatModel = AcademicChatModel.fromJson(tmp[i]);
        chatsName.add(chatModel.toString());
      }
    } else {
      //errore
    }
    return chatsName;
  }

  Future<List<String>> getChats(List<int> svTmp) async {
    List<dynamic> tmp = new List<dynamic>();
    List<String> chatsName = new List<String>();
    print(json.encode(svTmp));
    http.Response response = await http.post(getUrlHome() + "getChatsFromId",
        headers: {HttpHeaders.authorizationHeader: await getToken()},
        body: {"chats": json.encode(svTmp)});
    if (response.statusCode == 201) {
      tmp = (json.decode(response.body));
      print(tmp);
      for (int i = 0; i < tmp.length; i++) {
        chatsName.add(tmp[i]["title"]);
      }
      print(chatsName);
    } else {
      //errore
    }
    return chatsName;
  }

  void refresh() {
   /* getListString("joinedChats").then((list) {
      chats = list;
      print(chats);
      getListString("chatsToNotify").then((list2) {
        chatsToNotify = list2;
        setState(() {
          done = true;
        });
      });
    });
    */
    setState(() {
      done = false;
    });
    getListString("joinedChats").then((list) {
      areAcademics = new List<bool>();
      getListString("chatsToNotify").then((list2) {
        chatsToNotify = list2;
        print(chatsToNotify);
        List<int> accTmp =
            new List<int>(); //lista dell'id delle chat accademiche preferite
        List<int> svTmp =
            new List<int>(); //lista dell'id delle chat di svago preferite
        ids = new List<String>();
        for (int i = 0; i < list.length; i++) {
          //print(list[i].substring(list[i].length-2));
          String tmp = list[i].replaceAll(new RegExp(r"[a-z]_*"), "");
          if (list[i].contains("acc")) {
            accTmp.add(int.parse(tmp));
          } else {
            svTmp.add(int.parse(tmp));
          }
          ids.add(tmp);
        }
        getAcademicChats(accTmp).then((listAcc) {
          chats = new List<String>();
          chats.addAll(listAcc);
          areAcademics.addAll(List.generate(chats.length, (i) => true));
          print(areAcademics);
          getChats(svTmp).then((listSv) {
            chats.addAll(listSv);
            areAcademics.addAll(
                List.generate(chats.length - listAcc.length, (i) => false));
            print("AreAc: " + areAcademics.toString());
            print("Done: " + done.toString());
            setState(() {
              done = true;
            });
          });
        });
      });
    });
  }

  List<Widget> _buildChatList() {
    List<String> tmp = new List<String>();
    List<String> tmpIds = new List<String>();
    List<bool> tmpAreAcademics = new List<bool>();
    if (bottSearchPressed == true && _searchText != "") {
      for (int i = 0; i < chats.length; i++) {
        if (chats[i].toLowerCase().contains(_searchText.toLowerCase())) {
          tmp.add(chats[i]);
          tmpIds.add(ids[i]);
          tmpAreAcademics.add(areAcademics[i]);
        }
      }
    } else {
      tmp = chats;
      tmpIds = ids;
      tmpAreAcademics = areAcademics;
    }
    return new List.generate(tmp.length, (index) {
      return ListTile(
          onTap: () {
            if (areAcademics[index]) {
              Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (context) => AcademicChat(
                            chatName: tmp[index],
                            id: tmpIds[index],
                          )))
                  .then((value) {
                refresh();
              });
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => Chat(
                            chatName: tmp[index],
                            id: tmpIds[index]
                          )))
                  .then((value) {
                refresh();
              }); //aggiungere .then e richiamare le stesse cose di initState... Continua a cercare se c'è un modo più efficiente e migliore per farlo
            }
          },
          title: Text(tmp[index], style: TextStyle(color: Colors.white)),
          trailing: _retrieveTrailing(tmpIds[index], tmpAreAcademics[index]));
    });
  }

  Icon _retrieveTrailing(String id, bool isAcademic) {
    if (isAcademic) {
      String x = "chat_acc_" + id;
      print(x);
      print(chatsToNotify);
      if (chatsToNotify.contains(x)) {
        return Icon(FontAwesomeIcons.volumeUp, color: Colors.white,);
      } else {
        return Icon(FontAwesomeIcons.volumeOff, color: Colors.white,);
      }
    } else {
      String x = "chat_sv_" + id;
      if (chatsToNotify.contains(x)) {
        return Icon(FontAwesomeIcons.volumeUp, color: Colors.white,);
      } else {
        return Icon(FontAwesomeIcons.volumeOff, color: Colors.white,);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
          bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2)),
          title: bottSearchPressed == true ? appBarTitle : Text("Chat Preferite", 
          style: TextStyle(
            color: Colors.white, 
            fontFamily: 'Avenir Next',
            fontSize: 20)),
          leading: IconButton(
            icon: bottSearchPressed == true
                ? Icon(FontAwesomeIcons.times, size: 20, color: Colors.white)
                : Icon(FontAwesomeIcons.search, size: 20, color: Colors.white,),
            onPressed: () {
              setState(() {
                bottSearchPressed = !bottSearchPressed;
              });
            },
          ),
        ),
        body: done == false
            ? SpinKitPouringHourglass(
                    color: Colors.white,
                    size: 50.0,
                  )
            : Container(
                child: chats.isEmpty
                    ? Center(
                        child: Text("Nessuna chat presente"),
                      )
                    : ListView(
                        children: _buildChatList(),
                      ),
              ));
  }
}
