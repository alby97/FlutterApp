import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/chat_view_screen.dart';
import 'package:youni_app/utils/categories.dart';
import 'dart:io';

import 'package:youni_app/utils/utility.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatSvagoScreen extends StatefulWidget {
  ChatSvagoScreenState createState() => ChatSvagoScreenState();
}

class ChatSvagoScreenState extends State<ChatSvagoScreen>
    with WidgetsBindingObserver {
  bool getCategoriesDone = false;

  List<Category> categories;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCategories().then((list) {
      categories = _createCategoriesList(list);
      categories.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        getCategoriesDone = true;
      });
    });
  }

  Future<List> getCategories() async {
    String token = await getToken();
    String url = getUrlHome() + 'getCategories';
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    List l = json.decode(response.body)['categories'];
    // print(m);
    return l;
  }

  List<Category> _createCategoriesList(List<dynamic> jsonList) {
    List<Category> tmp = new List<Category>();
    for (int i = 0; i < jsonList.length; i++) {
      tmp.add(Category.fromJson(jsonList[i]));
    }
    return tmp;
  }


   Icon _listIcon (int index) {
    switch (index) {
      case 0: return Icon(
        FontAwesomeIcons.paw,
        color: Colors.white,
        size: 20);
      case 1: return Icon(
        FontAwesomeIcons.palette,
        color: Colors.white,
        size: 20);
      case 2: return Icon(
        FontAwesomeIcons.film,
        color: Colors.white,
        size: 20);
        case 3: return Icon(
        FontAwesomeIcons.utensils,
        color: Colors.white,
        size: 20);
        case 4: return Icon(
        FontAwesomeIcons.newspaper,
        color: Colors.white,
        size: 20);
        case 5: return Icon(
        FontAwesomeIcons.tools,
        color: Colors.white,
        size: 20);
        case 6: return Icon(
        FontAwesomeIcons.cameraRetro,
        color: Colors.white,
        size: 20);
        case 7: return Icon(
        FontAwesomeIcons.music,
        color: Colors.white,
        size: 20);
        case 8: return Icon(
        FontAwesomeIcons.flask,
        color: Colors.white,
        size: 20);
        case 9: return Icon(
        FontAwesomeIcons.volleyballBall,
        color: Colors.white,
        size: 20);
        case 10: return Icon(
        FontAwesomeIcons.theaterMasks,
        color: Colors.white,
        size: 20);
        case 11: return Icon(
        FontAwesomeIcons.globeEurope,
        color: Colors.white,
        size: 20);
        case 12: return Icon(
        FontAwesomeIcons.gamepad,
        color: Colors.white,
        size: 20);
    }
  }




  @override
  Widget build(BuildContext context) {
    return getCategoriesDone == false
        ? SpinKitPouringHourglass(
            color: Colors.white,
            size: 50.0,
          )
        : Scaffold(
             appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2),),
        title: Text("Chat Svago", style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Avenir Next'),),
      ),
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
            body: Container(
            child: ListView(
              children: List.generate(categories.length, (index) {
                return ListTile(
                  title: Text(categories[index].name, style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17)),
                  leading: _listIcon(index),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatViewScreen(
                            categoryName: categories[index].name)));
                    //!aggiungere anche qui il then e poi creare una funzione refresh in cui si fanno le stesse cose di initState
                    //!da fare anche in academic chats
                  },
                );
              }),
            ),
          ));
  }
}
