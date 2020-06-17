import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/chat_academic_screen.dart';
import 'package:youni_app/chat_favorite_screen.dart';
import 'package:youni_app/chat_svago_screen.dart';


class ChatScreen extends StatefulWidget {
  
  ChatScreenState createState() => ChatScreenState();

}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Avenir Next',
          fontSize: 20
        )),
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(25, 25, 25, 1.0),
          border: Border(top: BorderSide(color: Colors.blue, style: BorderStyle.solid, width: 2))
        ),
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(FontAwesomeIcons.userGraduate, color: Colors.white, size: 25),
              title: Text('Chat Accademiche',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Avenir Next'
              )),
              
              onTap: () => {
                //TODO: Implementa Chat Accademiche
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ChatAcademicScreen()))
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.users, color: Colors.white),
              title: Text('Chat Svago',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20
              ),),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  ChatSvagoScreen()))
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.heart, color: Colors.white),
              title: Text("Chat Preferite",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20
              )),
              onTap: () => {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  ChatFavoriteScreen())) 
              },
            )
          ],
        ),
      ),
    );
  }

}