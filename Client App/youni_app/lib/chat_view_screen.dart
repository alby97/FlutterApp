import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as prefix0;
import 'package:youni_app/chat.dart';
import 'package:youni_app/chats_screen.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatViewScreen extends StatefulWidget {
  final String categoryName;

  ChatViewScreen({this.categoryName});

  ChatViewScreenState createState() =>
      ChatViewScreenState(categoryName: categoryName);
}

class ChatViewScreenState extends State<ChatViewScreen>
    with WidgetsBindingObserver {
  final String categoryName;

  ChatViewScreenState({this.categoryName});

  bool getChatsDone = false;

  List<String> chats = new List<String>();
  List<String> chatIds = new List<String>();

  List<String> userJoinedChats, userChatsToNotify;

  GlobalKey<RefreshIndicatorState> _refKey = GlobalKey<RefreshIndicatorState>();

  static TextEditingController _filter = new TextEditingController();

  String _searchText = "";

  Widget appBarTitle = TextField(
    controller: _filter,
    decoration: new InputDecoration(
        prefixIcon: new Icon(Icons.search), 
        hintText: 'Cerca...', 
        
        ),
  );

  bool bottSearchPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getChatsForCategory(categoryName).then((l) {
      print("Ok1");
      if (l != null) {
        print(l.isNotEmpty);
        if (l.isNotEmpty) {
          for (int i = 0; i < l.length; i++) {
            chats.add(l[i]["title"]);
            chatIds.add(l[i]["id_chat"]);
          }
          setState(() {
            getChatsDone = true;
            print("Ok2");
            print(chats);
            getListString("joinedChats").then((list) {
              userJoinedChats = list;
            });
            getListString("chatsToNotify").then((list) {
              userChatsToNotify = list;
            });
          });
        } else {
          setState(() {
            getChatsDone = true;
          });
        }
      } else {
        setState(() {
          getChatsDone = true;
        });
      }
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

  void refresh() {
    getChatsForCategory(categoryName).then((l) {
      print("Ok1");
      if (l != null) {
        print(l.isNotEmpty);
        if (l.isNotEmpty) {
          chats.removeRange(0, chats.length);
          for (int i = 0; i < l.length; i++) {
            chats.add(l[i]["title"]);
            chatIds.add(l[i]["id_chat"]);
          }
          setState(() {
            getChatsDone = true;
            print("Ok2");
            print(chats);
            getListString("joinedChats").then((list) {
              userJoinedChats = list;
            });
            getListString("chatsToNotify").then((list) {
              userChatsToNotify = list;
            });
          });
        } else {
          setState(() {
            getChatsDone = true;
          });
        }
      } else {
        setState(() {
          getChatsDone = true;
        });
      }
    });
  }

  Future<List> getChatsForCategory(String categoryName) async {
    String token = await getToken();
    String url = getUrlHome() + "getChats";
    var payload = {'categoryName': categoryName};
    http.Response response = await http.post(url,
        headers: {HttpHeaders.authorizationHeader: token}, body: payload);
    print(response.body);
    checkResponseStatus(response, context);
    return json.decode(response.body);
  }

  List<Widget> _buildChatList() {
    List<String> tmp = new List<String>();
    List<String> tmpId = new List<String>();
    if (bottSearchPressed == true && _searchText != "") {
      for (int i = 0; i < chats.length; i++) {
        if (chats[i].toLowerCase().contains(_searchText.toLowerCase())) {
          tmp.add(chats[i]);
          tmpId.add(chatIds[i]);
        }
      }
    } else {
      tmp = chats;
      tmpId = chatIds;
    }
    return new List.generate(tmp.length, (index) {
      return ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) =>
                      Chat(chatName: tmp[index], id: tmpId[index])))
              .then((value) {
            refresh();
          });
        },
        title: Text(tmp[index], style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Avenir Next'),),
        trailing: userJoinedChats.contains(tmp[index])
            ? userChatsToNotify.contains(tmp[index])
                ? Icon(FontAwesomeIcons.volumeUp, color: Colors.white,)
                : Icon(FontAwesomeIcons.volumeOff, color: Colors.white,) //!da aggiustare facendo il contains con chat_acc_+id o chat_sv_+id vedi chat_favorite_screen per capire
            : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return  getChatsDone == false
          ? SpinKitPouringHourglass(
              color: Colors.white,
              size: 50.0,
            )
          : Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2),),
        title: bottSearchPressed == true
            ? appBarTitle
            : Text("Lista Chat",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Avenir Next',
                    fontSize: 20)),
        leading: IconButton(
          icon: bottSearchPressed == true
              ? Icon(Icons.close)
              : Icon(Icons.search),
          onPressed: () {
            setState(() {
              bottSearchPressed = !bottSearchPressed;
            });
          },
        ),
      ),
       backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
      body: Container(
              child: chats.isEmpty
                  ? Center(
                      child: Text("Nessuna chat presente"),
                    )
                  : RefreshIndicator(
                      key: _refKey,
                      onRefresh: () async {
                        setState(() {
                          //TODO: INSERIRE CODICE PER RIFARE LA RICHIESTA HTTP DELLE CHAT
                        });
                      },
                      child: ListView(
                          children:
                              _buildChatList() /*List.generate(chats.length, (index) {
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Chat(
                                        chatName: chats[index],
                                      )));
                            },
                            title: Text(chats[index]),
                          );
                        }),*/
                          ))),
      floatingActionButton: FloatingActionButton(
        heroTag: 'buttonAddChat',
        tooltip: 'Crea una nuova chat',
        onPressed: () {
          TextEditingController _chatTitleController =
              new TextEditingController();
          showDialog(
              context: context,
              child: AlertDialog(
                backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                title: Text('Crea una nuova chat',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Avenir Next',
                        fontSize: 20)),
                content: TextFormField(
                  controller: _chatTitleController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Inserisci un titolo';
                    }
                  },
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                        "Crea"), //!Gestire il fatto che ci può essere uno spazio alla fine, fare trim.
                    onPressed: () async {
                      String token = await getToken();
                      String url = getUrlHome() + "createChat";
                      http.Response response = await http.post(url, headers: {
                        HttpHeaders.authorizationHeader: token
                      }, body: {
                        'title': _chatTitleController.text.trim(),
                        'category': categoryName
                      });
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                            content: Text(json.decode(response.body)["message"],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20)),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Avenir Next',
                                    )),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  getChatsForCategory(categoryName).then((l) {
                                    print("Ok1");
                                    if (l != null) {
                                      print(l.isNotEmpty);
                                      if (l.isNotEmpty) {
                                        for (int i = 0; i < l.length; i++) {
                                          if (!chats.contains(l[i])) {
                                            chats.add(l[i]["title"]);
                                            chatIds.add(l[i]["id_chat"]);
                                          }
                                        }
                                      }
                                    }
                                  });
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                  )
                ],
              ));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
