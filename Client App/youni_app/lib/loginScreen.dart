import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youni_app/first_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/forgotPasswordScreen.dart';
import 'package:youni_app/home_screen.dart';
import 'package:device_info/device_info.dart' as devInfo;
import 'package:youni_app/register_screen.dart';
import 'package:youni_app/utils/homeScreenArguments.dart';
import 'package:youni_app/utils/homeScreenArguments.dart' as prefix0;
import 'package:youni_app/utils/utility.dart' as utils;

//TODO: LIMITARE IL NUMERO DI TENTATIVI CHE SI PUO' FARE INSERENDO LA PASSWORD ERRATA
class LoginScreen extends StatelessWidget {
  LoginScreen() {
    utils.setLastRoute('/loginScreen');
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 50.0),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.red[100]])),
        ),
      ),
      body: LoginForm(),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class LoginForm extends StatefulWidget {
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  final controllerName = TextEditingController();
  final controllerPsw = TextEditingController();

  bool pswInvisible = true;
  bool rememberMe = false;

  static final _focusUsername = FocusNode();
  static final _focusPassword = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 850.0,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.red[100], Colors.red[700]])),
                  child: Column(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      Image.asset('assets/images/LogoNoSfondoResize.png',
                          width: 80, height: 140, alignment: Alignment.center),
                      RichText(
                        text: TextSpan(
                            text: "YoUni",
                            style: TextStyle(
                              fontFamily: 'Avenir Next',
                              fontSize: 40.0,
                            )),
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Semplifica la vita degli studenti",
                            style: TextStyle(
                                fontFamily: 'Avenir Next', fontSize: 20.0)),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(65.0, 40.0, 60.0, 0),
                        child: TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Avenir Next',
                                fontSize: 17.0),
                            textAlign: TextAlign.start,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Si prega di inserire il nome';
                              }
                            },
                            decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20.0),
                                hintText: 'Username',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: Colors.white, size: 30.0),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20.0)),
                            controller: controllerName,
                            textInputAction: TextInputAction.next,
                            focusNode: _focusUsername,
                            onFieldSubmitted: (term) {
                              _focusUsername.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_focusPassword);
                            }),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(65.0, 40.0, 60.0, 0),
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Avenir Next',
                              fontSize: 17.0),
                          textAlign: TextAlign.start,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Si prega di inserire la password';
                            }
                          },
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Avenir Next',
                                  fontSize: 20.0),
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Colors.white, size: 30.0),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Avenir Next',
                                  fontSize: 20.0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    pswInvisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                    size: 30.0),
                                onPressed: () {
                                  _toggle();
                                },
                              )),
                          controller: controllerPsw,
                          obscureText: pswInvisible,
                          focusNode: _focusPassword,
                          onFieldSubmitted: (term) {
                            _focusPassword.unfocus();
                          },
                        ),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.only(left: 115.0, right: 115.0),
                        color: Colors.white70,
                        textColor: Colors.red[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60.0)),
                        child: Text('Login',
                            style: TextStyle(
                                fontFamily: 'Avenir Next',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            var url = utils.getUrl() + "login";
                            devInfo.DeviceInfoPlugin deviceInfo =
                                devInfo.DeviceInfoPlugin();
                            if (Platform.isAndroid) {
                              var info = await deviceInfo.androidInfo;
                              var deviceId = info.androidId;
                              http.post(url, body: {
                                "username": "${controllerName.text}",
                                "password": "${controllerPsw.text}",
                                "rememberMe": "$rememberMe"
                                //"deviceId": "$deviceId"
                              }).then((response) {
                                print("Body");
                                print(response.body);
                                if (response.statusCode == 200) {
                                  _saveToken(response).then((saved) async {
                                    if (saved) {
                                      var jsonData = json.decode(response.body);
                                      print(jsonData);
                                      await utils.saveValue(
                                          'CdS',
                                          jsonData[
                                              'course_study']); //! aggiungere queste due righe anche per la registrazione
                                      await utils.saveValue(
                                          'CdT',
                                          jsonData[
                                              'course_type']); //! controllare se c'è bisogno di aggiornare il codice lato server per quanto riguarda la registrazione (vedi quando si restituisce la risposta in login, ho aggiunto altri 2 campi per cds e cdt)
                                      await utils.saveValue(
                                          'Username', controllerName.text);
                                  /*    await utils.saveValue("Name",
                                          jsonData["name"]);
                                      await utils.saveValue(
                                          "Surname",
                                         jsonData["surname"]);
                                         */
                                      await utils.saveListString(
                                          "joinedChats",
                                          jsonData["joinedChats"]);
                                      await utils.saveListString(
                                          "chatsToNotify",
                                          jsonData["chatsToNotify"]);
                                      await utils.saveBool("logoutDone", false);
                                      HomeScreenArguments args =
                                          HomeScreenArguments(
                                              rememberMe == true
                                                  ? "Illimitate"
                                                  : "3h",
                                              "login");
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          'homeScreen',
                                          (Route<dynamic> route) => false,
                                          arguments: args);
                                    } else {
                                      //Gestire l'errore per il token non salvato
                                    }
                                  });
                                } else {
                                  _showNameOrPswErrorDialog(context);
                                }
                              });
                            } else {
                              var info = await deviceInfo.iosInfo;
                              var deviceId = info.identifierForVendor;
                              http.post(url, body: {
                                "username": "${controllerName.text}",
                                "password": "${controllerPsw.text}",
                                "rememberMe": "$rememberMe",
                                //"deviceId": "$deviceId"
                              }).then((response) {
                                if (response.statusCode == 200) {
                                  _saveToken(response).then((saved) async {
                                    print(saved);
                                    if (saved) {
                                      await utils.saveValue(
                                          'CdS',
                                          json.decode(response.body)[
                                              'course_study']); //! aggiungere queste due righe anche per la registrazione
                                      await utils.saveValue(
                                          'CdT',
                                          json.decode(response.body)[
                                              'course_type']); //! controllare se c'è bisogno di aggiornare il codice lato server per quanto riguarda la registrazione (vedi quando si restituisce la risposta in login, ho aggiunto altri 2 campi per cds e cdt)
                                      await utils.saveValue(
                                          'Username', controllerName.text);
                                      await utils.saveListString(
                                          'joinedChats',
                                          json.decode(
                                              response.body)["joinedChats"]);
                                      await utils.saveListString(
                                          "chatsToNotify",
                                          json.decode(
                                              response.body)["chatsToNotify"]);
                                      await utils.saveBool('logoutDone', false);
                                      HomeScreenArguments args =
                                          HomeScreenArguments(
                                              rememberMe == true
                                                  ? "Illimitate"
                                                  : "3h",
                                              "login");
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          'homeScreen',
                                          (Route<dynamic> route) => false,
                                          arguments: args);
                                    } else {
                                      //Gestire l'errore per il token non salvato
                                    }
                                  });
                                }
                                if (response.statusCode != 200)
                                  _showNameOrPswErrorDialog(context);
                              });
                            }
                          }
                        },
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(50, 20, 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Checkbox(
                                value: rememberMe,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    rememberMe = !rememberMe;
                                  });

                                  print(rememberMe);
                                },
                                activeColor: Colors.black,
                              ),
                            ),
                            Text(
                              "Ricordami",
                              style: TextStyle(
                                  fontFamily: "Avenir Next",
                                  fontSize: 20,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Non sei registrato?",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontFamily: 'Avenir Next')),
                      ),
                      FlatButton(
                          padding:
                              const EdgeInsets.only(left: 95.0, right: 95.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60.0),
                              side: BorderSide(
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: Text('Registrati',
                              style: TextStyle(
                                  fontFamily: 'Avenir Next',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()));
                          },
                          color: Colors.transparent),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                        text: TextSpan(text: ""),
                      ),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontFamily: 'Avenir Next', fontSize: 15.0),
                              text: 'Hai dimenticato la password? ',
                              children: [
                            TextSpan(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Avenir Next',
                                    fontSize: 17.0),
                                text: 'Clicca qui',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPasswordScreen())))
                          ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<bool> _saveToken(http.Response response) async {
    print("Save token");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(json.decode(response.body)['token']);
    return prefs.setString("token", json.decode(response.body)['token']);
  }

  void _toggle() {
    setState(() {
      pswInvisible = !pswInvisible;
    });
  }

  void _showNameOrPswErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
            title: Text('Errore',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Avenir Next',
              fontSize: 20
            ),),
            content: Text(
                'Il nome o la password inseriti sono errati. Inserire il nome o la password corretti',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Avenir Next',
                  fontSize: 20
                ),),
            actions: <Widget>[
              FlatButton(
                child: Text('Chiudi'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
