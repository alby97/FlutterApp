import 'package:flutter/material.dart';
import 'package:youni_app/animation_first_screen.dart';
import 'package:youni_app/loginScreen.dart';
import 'register_screen.dart';
import 'package:flutter/gestures.dart';

class FirstScreen extends StatelessWidget {

  
  Widget build (BuildContext context){
    return Scaffold(
      body: AnimationFirstScreen(),
      );
      /*home: Scaffold(
        appBar: AppBar(title: Text('')),
        body: 
          Center(
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/logo.jpg', width: 130, height: 400),
                RaisedButton(
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.black,
                  child: Text('Login', style: TextStyle(fontFamily: 'Avenir Next', fontSize: 20.0)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  }
                ),
                SizedBox(height: 6.0,),
                RichText(
                  text: TextSpan(
                    text: "Non sei registrato?",
                    style: TextStyle(color: Colors.black, fontSize: 18.0, fontFamily: 'Avenir Next'),
                    children: [
                      TextSpan(
                        text: " Registrati!",
                        style: TextStyle(color: Colors.blue, fontSize: 18.0),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, '/registerScreen')
                      )
                    ]
                  ),

                )
              ],//Aggiungere 'Non sei registrato? Registrati'
            ),
          ),
      )*/
    
  }
}


