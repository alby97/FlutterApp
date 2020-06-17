import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/cardMenu.dart';
import 'package:youni_app/cardMenu.dart' as prefix0;
import 'package:youni_app/chat.dart';
import 'package:youni_app/chat_view_screen.dart';
import 'package:youni_app/classrooms_screen.dart';
import 'package:youni_app/feedbacks/create_feedback.dart';
import 'package:youni_app/lesson_change_details_screen.dart';
import 'package:youni_app/lessons_changes.dart';
import 'package:youni_app/prova_nice_button.dart';
import 'package:youni_app/teaching_material/departments_screen.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/homeScreenArguments.dart';
import 'package:youni_app/utils/teaching.dart';
import 'package:youni_app/utils/utility.dart';

import 'colors.dart' as myColor;
import 'teaching_materials_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

import 'package:youni_app/utils/firebaseMsgUtils.dart' as fireBaseMsgUtils;
import 'utils/connectivityUtilities.dart' as connectivity;
import 'package:connectivity/connectivity.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  GlobalKey<NavigatorState> navigatorKey;

  HomeScreen(GlobalKey<NavigatorState> navKey) {
    this.navigatorKey = navKey;
    setLastRoute('/homeScreen');
  }

  HomeScreenState createState() => HomeScreenState(navigatorKey: navigatorKey);
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  GlobalKey<NavigatorState> navigatorKey;

  HomeScreenState({this.navigatorKey});

  FirebaseMessaging _firebaseMessaging = fireBaseMsgUtils.getInstance();

  Connectivity _connectivity = connectivity.getConnectivityInstance();

  bool _deviceIdSetted = false;
  bool _firstAccess;
  bool done = false;

  List teachsNotify;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Ricevuta notifica");
        print('on message $message');
        /* TODO: Aggiungere campo username nella notifica, in questo modo si può fare il controllo che se l'username dell'utente è lo stesso di chi manda
          la notifica la notifica non viene mostrata.
        */
        print(message['data']);
        print(await getValue("Username"));
        if (message['data']['type_of_notification'] == 'Lesson Change' &&
            message['data']['author'] != await getValue('Username')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              content: ListTile(
                title: Text(message['notification']['title'], style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Avenir Next',
                  fontSize: 20
                ),),
                subtitle: Text(message['data']['description'],
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Avenir Next',
                  fontSize: 20),
              )),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text('Visualizza'),
                  onPressed: () {
                    print("Tap");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LessonChangeDetailsScreen(
                              id: message['data']['id'],
                            )));
                  },
                )
              ],
            ),
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        print("MyUsername: " + await getValue("Username"));
        if (message['data']['type_of_notification'] == 'Chat Message' &&
            message['data']['author'] != await getValue('Username')) {
          navigatorKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                  //questo serve in modo tal da evitare che se si apre una notifica, porta alla chat, poi si preme il tasto home, poi arriva un'altra notifica e ci saranno due schermate di quella chat nel Navigator
                  builder: (context) => Chat(
                        chatName: message['data']['chat'],
                      )), (Route<dynamic> route) {
            print(route.settings.toString());
            print(route.settings.name);
            return route.settings.name != "/chat";
          });
        } else if (message['data']['type_of_notification'] ==
                'Created Interest Chat' &&
            message['data']['author'] != await getValue('Username')) {
          navigatorKey.currentState.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => ChatViewScreen(
                        categoryName: message['data']['category'],
                      )), (Route<dynamic> route) {
            print(route.settings.toString());
            print(route.settings.name);
            return route.settings.name != "/chatsView";
          });
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    if (!_deviceIdSetted) {
      fireBaseMsgUtils.setInstance(_firebaseMessaging);
      _firebaseMessaging.getToken().then((token) {
        print("Token-------------");
        print(token);
        setDeviceId(token).then((newToken) {
          saveFToken(token).then((onValue) {
            if (newToken != "") {
              saveToken(newToken);
            }
            _deviceIdSetted = true;
            print("Token salvati");
            getBool("firstAccess").then((value) {
              print("Value: " + value.toString());
              if (value == true || value == null) {
                _firstAccess = true;
                print("True");
              } else {
                _firstAccess = false;
                print("False");
              }
              print("FA1 " + _firstAccess.toString());
              /*_connectivity.onConnectivityChanged.listen((result) {
                print(result.toString());
                print("V: " + value.toString());
                print(_firstAccess);
                if (value == false || _firstAccess == false) {
                  if (result == ConnectivityResult.none) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Icon(
                              FontAwesomeIcons.exclamationCircle,
                              color: Colors.red,
                            ),
                            contentPadding:
                                EdgeInsets.all(15.0),
                            content: Text(
                                "Non sei connesso/a alla rete, finché non tornerai online non riceverai più messaggi e notifiche"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Ok"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.green,
                              ),
                              contentPadding:
                                EdgeInsets.all(15.0),
                              content: Text(
                                  "Sei ritornato online, buona permanenza!"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]);
                        });
                  }
                }
              });
              */
              if (_firstAccess == true) {
                print("If ok");
                getTeachingsToNotify().then((jlist) {
                  teachsNotify = jlist;
                  saveTeachingListToNotify(teachsNotify).then((bVal) {
                    //List<Teaching> tmpList = new List<Teaching>();
                    if (teachsNotify != null) {
                      for (int i = 0; i < teachsNotify.length; i++) {
                        print(teachsNotify[i]);
                        Teaching tmpT =
                            Teaching.fromJson(json.decode(teachsNotify[i][0]));
                        String tmp = tmpT.toString(); // teachsNotify[i];
                        print(tmp);
                        tmp = tmp.replaceAll(
                            new RegExp(r"(?![a-zA-Z0-9-_.~%]+)."), '_');
                        print("Tmp: " + tmp);
                        _firebaseMessaging.subscribeToTopic(tmp);
                      }
                    }
                      getListString('joinedChats').then((list) {
                        if (list != null) {
                          List<String> joinedChats = list;
                          for (int i = 0; i < joinedChats.length; i++) {
                            //fireBaseMsgUtils.subscribeChat(joinedChats[i]);
                            fireBaseMsgUtils.subscribeChatHome(joinedChats[i]);
                            /*
                         String tmp = "CHAT_" + joinedChats[i];
                          tmp = tmp.replaceAll(new RegExp(' '), '_');
                          print("Tmp: " + tmp);
                          print(utf8.encode(tmp).toString());
                          RegExp reg = new RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
                          List<RegExpMatch> matches = reg.allMatches(tmp).toList();                          
                          for(int i = 0; i < matches.length; i++) {
                            print(matches[i].start);
                            print(matches[i].end);
                            //TODO:tmp.replaceRange(matches[i].start, matches[i].end, )
                            String subTmp = tmp.substring(matches[i].start, matches[i].end);
                            print(subTmp);
                            print(subTmp.codeUnits);
                            
                            List<int> codeUnits = subTmp.codeUnits;
                            String stringToReplace = "";
                            for(int i = 0; i < codeUnits.length; i++) {
                              stringToReplace += codeUnits[i].toString();
                              if(i < codeUnits.length-1) {
                                stringToReplace += "_";
                                
                              }
                            }
                            tmp = tmp.replaceRange(matches[i].start, matches[i].end, stringToReplace);
                          }
                          print(tmp);
                          _firebaseMessaging.subscribeToTopic(tmp);
                          */
                          }
                        }
                        getInterests().then((list) {
                          for (int i = 0; i < list.length; i++) {
                            String tmp = "CATEGORIA_" + list[i];
                            tmp = tmp.replaceAll(new RegExp(' '), '_');
                            print("Tmp: " + tmp);
                            _firebaseMessaging.subscribeToTopic(tmp);
                          }
                          print("Done");
                          setState(() {
                            done = true;
                          });
                          //fireBaseMsgUtils.setInstance(_firebaseMessaging);
                        });
                      });
                    
                  });
                });
                final HomeScreenArguments args =
                    ModalRoute.of(context).settings.arguments;
                print(args);
                print(args.getTime());
                _firstAccess = false;
                print(_firstAccess);
                saveBool('firstAccess', _firstAccess);
                if (args.getTime() == "3h") {
                  print("Entrato");
                  Timer timer = new Timer(
                      Duration(hours: 2, minutes: 57, seconds: 52),
                      () async => {
                            //in questo modo si può effettuare la richiesta http, se il token scade ci sarà un errore
                            this.logout()
                          });
                }
              } else {
                setState(() {
                  fireBaseMsgUtils.setInstance(_firebaseMessaging);
                  done = true;
                });
              }
            });
          });
        });
      });
    }
  }

  Future<List<String>> getInterests() async {
    String token = await getToken();
    String url = getUrlHome() + "getUserInterests";
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
        checkResponseStatus(response, context);
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

  /*void _chooseAction(BuildContext context, int index) async {
    /*
    0: Chat
    1: Variazione Lezioni
    2: Profilo
    3: Logout
    */
    switch (index) {
      case 0:
        //TODO: implementa chat
        Navigator.of(context).pushNamed('/chats');
        break;
      case 1:
        Navigator.of(context).pushNamed('/lessonsChangesScreen');
        break;
      case 2:
        //  navigatorKey.currentState.pushNamed("/userProfileScreen");
        Navigator.of(context).pushNamed("/userProfileScreen");
        //TODO: Implementa profilo
        break;
      case 3: //lOGOUT
        await logout();
        break;
      default:
        break;
    }
  }*/



  List<Widget> _buildChildren () {
    List<Widget> _cardsMenu = new List<Widget>();
    CardMenu _chats = new CardMenu(
      text: "Chat",
      color: Colors.blue,
      image: Image.asset('assets/images/chat-2-icon.png', height: 92.0, width: 92.0,),
      onTapFunction: () => Navigator.of(context).pushNamed('/chats')
    );
    _cardsMenu.add(_chats);
    CardMenu _lessonchanges = new CardMenu(
      text: "Variazione lezione",
      color: Colors.red,
      image: Image.asset('assets/images/Arrow-reload-4-icon.png', height: 92.0, width: 92.0,),
      onTapFunction: () => Navigator.of(context).pushNamed('/lessonsChangesScreen')
    );
    _cardsMenu.add(_lessonchanges);
    CardMenu _userProfileScreen = new CardMenu(
      text: "Profilo",
      color: Colors.yellow,
      image: Image.asset('assets/images/User-icon.png', height: 92.0, width: 92.0,),
      onTapFunction: () => Navigator.of(context).pushNamed('/userProfileScreen')
    );
    _cardsMenu.add(_userProfileScreen);
    CardMenu _classroom = new CardMenu(
      text: "Aule",
      color: Colors.green,
      image: Image.asset('assets/images/Home-icon.png', height: 92.0, width: 92.0),
      onTapFunction: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ClassroomsScreen())),
    ); 
    _cardsMenu.add(_classroom);
    CardMenu _teachingMaterial = new CardMenu(
      text: "Materiale Didattico",
      color: Colors.amber,
      image: Image.asset('assets/images/book.png', height: 92.0, width: 92.0,),
      onTapFunction: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DepartmentsScreen())),
    );
    _cardsMenu.add(_teachingMaterial);
    CardMenu _logout = new CardMenu(
      text: "Logout",
      color: Colors.purple,
      image: Image.asset('assets/images/Arrow-inside-icon.png', height: 92.0, width: 92.0,),
      onTapFunction: logout,
    );
    _cardsMenu.add(_logout);
    return _cardsMenu;
  }

  /*List<Card> _buildCards(BuildContext context, int count) {
    List<Card> cards = List.generate(
        count,
        (int index) => Card(

            shape: RoundedRectangleBorder(
              
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: listColor[index],
                  width: 3.0
                  
                ),
                ),
            elevation: 6.0,
            
            //margin: EdgeInsets.only(top: 30, left: 10, right: 10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                _chooseAction(context, index);
              },
              child: Container(
                child: CardMenu(),
                ),
                /*decoration: BoxDecoration(
                  image: DecorationImage(
                      image: _chooseImage(index),
                      fit: BoxFit.fill,
                      colorFilter:
                          ColorFilter.mode(myColor.grey15, BlendMode.modulate)),
                ),*/
                
                    ),
                    /*
                    SizedBox(
                      height: 75.0,
                    ),
                    _chooseIcon(index),
                    Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 20.0),
                        child: Text(
                          options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: 'Avenir Next',
                              fontStyle: FontStyle.normal),
                        ))*/
                  
              ),
            );
    return cards;
  }*/


  

  

  List<String> listIconImage = [
    "assets/images/chat-2-icon.png",
    "assets/images/Arrow-reload-4-icon.png",
    "assets/images/User-icon.png"
    "assets/images/Arrow-inside-icon.png",
  ];

  List<Color> listColor = [
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.blue
  ];

  List<String> options = [
    "Chat",
    "Variazione Lezione",
    //"Materiale Didattico",
    "Profilo",
    "Logout"
  ];
  List<String> imagesAsset = [
    "assets/images/chat.jpg",
    "assets/images/varialez.jpeg",
    "assets/images/black.jpg",
    //  "assets/images/black.jpg",
    "assets/images/ajardoor.jpg"
  ];

  Icon _chooseIcon(int index) {
    /*
    0: Chat
    1: Variazione Lezioni
    2: Profilo
    3: Logout
    */
    switch (index) {
      case 0:
        return Icon(
          Icons.chat,
          color: Colors.white,
          size: 40.0,
        );
      case 1:
        return Icon(
          Icons.report,
          color: Colors.white,
          size: 40.0,
        );
      case 2:
        return Icon(Icons.person, color: Colors.white, size: 40.0);
      case 3:
        return Icon(
          Icons.exit_to_app,
          color: Colors.white,
          size: 40.0,
        );
      default:
        return null;
    }
  }

  AssetImage _chooseImage(int index) {
    return AssetImage(imagesAsset[index]);
  }
/*
  Future<bool> _removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove('token');
  }
*/

  Future<String> setDeviceId(String ftoken) async {
    var url = getUrlHome() + "setDeviceId";
    String token = await getToken();
    bool refreshTokenNeeded;
    if (_firstAccess == true) {
      HomeScreenArguments args = ModalRoute.of(context).settings.arguments;
      refreshTokenNeeded = args.getPreviousRoute() == "registration";
    } else {
      refreshTokenNeeded = false;
    }
    print(refreshTokenNeeded);
    http.Response response = await http.post(url, headers: {
      HttpHeaders.authorizationHeader: token
    }, body: {
      "deviceId": ftoken,
      "refreshTokenNeeded": "$refreshTokenNeeded"
    });
    print("Status: " + response.statusCode.toString());
    print(response.body);
    checkResponseStatus(response, context);
    await saveValue("name", json.decode(response.body)["name"]);
    await saveValue("surname", json.decode(response.body)["surname"]);
    return refreshTokenNeeded ? json.decode(response.body)["token"] : "";
  }

  Future<void> logout() async {
    print("Logout");
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
        fireBaseMsgUtils.unsubscribeChat(joinedChats[i]);
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
      Navigator.of(context).pushNamedAndRemoveUntil(
          "firstScreen", (Route<dynamic> route) => false);
    }
  }

  MethodChannel platform = new MethodChannel("homeButton");

  @override
  Widget build(BuildContext context) {
    return done == false
        ? SpinKitPouringHourglass(
          color: Colors.white,
          size: 50.0,
        )
        : WillPopScope(
            onWillPop: () async {
              await platform.invokeMethod("homeButton");
              print("Invoked");
              //return false;
            },
            child: Scaffold(
              drawer: Drawer(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text("Prova"),
                      onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ProvaButton())),
                    )
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.feedback),
                tooltip: 'Feedback',
                onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => CreateFeedbackScreen()))),
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              body: Center(
                  child: ListView(
                children: _buildChildren()
              )

                  /* GridView.count(
                  crossAxisCount: 1,
                  padding: EdgeInsets.fromLTRB(7.0, 50.0, 7.0, 15.0),
                  childAspectRatio: 8.0 / 9.0,
                  children: _buildCards(context, options.length),
                ),
                */
                  ),
              /*ActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builfloatingder: (context) => ClassroomsScreen()));
                },
                child: Column(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.building),
                    Text('Aule')
                  ],
                ),
              ),*/
              /*drawer: Drawer(
                child: Container(
              color: myColor.scaffoldCol2,
              child: Column(children: <Widget>[
                ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(25.0),
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Mostra profilo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0,
                              color: Colors.white70),
                        ),
                        onTap: () {
                          //TODO: Aggiungere il blocco con la richiesta HTTP che reinderizza al profilo
                        },
                        trailing: SizedBox(
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white70,
                          ),
                          width: 18.0,
                        ),
                        leading: Icon(
                          Icons.person,
                          color: Colors.white70,
                        ),
                      )
                    ]),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomLeft,
                    child: FlatButton(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(1.0, 4.0, 35.0, 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(
                              Icons.exit_to_app,
                              size: 30.0,
                              color: Colors.white70,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white70,
                                  fontFamily: 'Avenir Next'),
                            )
                          ],
                        ),
                      ),
                      onPressed: () {
                        //TODO: Implementa logout
                      },
                    ),
                  ),
                )
              ]),
            ))*/
            ));
  }
}

/* Questo pezzo deve essere rivisto, l'immagine in particolare non si vede molto bene
Vedi https://codelabs.developers.google.com/codelabs/mdc-104-flutter/#7 per mettere il logo sull'appbar
class _HomeTitle extends AnimatedWidget {

  _HomeTitle({
    Listenable listenable,
  }) : super(listenable : listenable);


  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;

    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false, //TODO: Approfondire
      overflow: TextOverflow.ellipsis,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72.0,
            child: IconButton(
              padding: EdgeInsets.only(right: 8.0),
              onPressed: () {},
              icon: Stack(
                children: <Widget>[
                  Opacity(opacity: animation.value, child: Icon(Icons.menu)),
                  FractionalTranslation(
                    translation: Tween<Offset> (
                      begin: Offset.zero,
                      end: Offset(1.0, 0.0)
                    ).evaluate(animation),
                    child: ImageIcon(AssetImage('assets/images/logotras.png')),
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
*/


