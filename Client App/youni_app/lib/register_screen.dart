import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youni_app/loginScreen.dart';
import 'package:youni_app/utils/utility.dart';
import 'home_screen.dart';
import 'dart:async';
import 'complete_profile_screen.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MyScaffold();
  }
}

class _MyScaffold extends StatelessWidget {
  @override
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
      body: _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm>
    with WidgetsBindingObserver {
  static final _formKey = GlobalKey<FormState>();

  static final controllerTextUsername = TextEditingController();
  static final controllerTextEmail = TextEditingController();
  static final controllerTextPassword = TextEditingController();
  static bool pswInvisible = true;
  static bool buttonPressed = false;

  static final _focusUsername = FocusNode();
  static final _focusEmail = FocusNode();
  static final _focusPassword = FocusNode();

  _RegisterFormState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

/*
  HttpClient client;

  _RegisterFormState() {
    super.initState();
    _initializeHttpClient();
  }
*/

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
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
                        style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
                        textAlign: TextAlign.start,
                        controller: controllerTextUsername,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Avenir Next',
                                fontSize: 20.0),
                            hintText: 'Username',
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.white, size: 30.0),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                        focusNode: _focusUsername,
                        onFieldSubmitted: (term) {
                          _focusUsername.unfocus();
                          FocusScope.of(context).requestFocus(_focusEmail);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Si prega di inserire l\'username';
                          } else {
                            Pattern pattern = r"/\w+/";
                            RegExp reg = RegExp(pattern);
                            if (!reg.hasMatch(value)) {
                              return 'Caratteri non permessi';
                            }
                          }
                        },
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(65.0, 20.0, 60.0, 0),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
                          controller: controllerTextEmail,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Avenir Next',
                                fontSize: 20.0),
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline,
                                color: Colors.white, size: 30.0),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Avenir Next',
                                fontSize: 20.0),
                          ),
                          focusNode: _focusEmail,
                          onFieldSubmitted: (term) {
                            _focusEmail.unfocus();
                            FocusScope.of(context).requestFocus(_focusPassword);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Si prega di inserire l\'email';
                            } else {
                              RegExp reg = RegExp(
                                  "^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}\$",
                                  caseSensitive: false);
                              if (!reg.hasMatch(value)) {
                                return 'La mail inserita non è corretta, inserire un\'email valida.';
                              }
                            }
                          },
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(65.0, 20.0, 60.0, 0),
                      child: TextFormField(
                        controller: controllerTextPassword,
                        style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next', fontSize: 17.0),
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Inserire la password';
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
                              ),
                              onPressed: () {
                                _toggle();
                              }),
                        ),
                        focusNode: _focusPassword,
                        obscureText: pswInvisible,
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
                        padding: EdgeInsets.only(left: 100.0, right: 100.0),
                        color: Colors.white70,
                        textColor: Colors.red[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60.0)),
                        child: Text(
                          'Registrati',
                          style: TextStyle(
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            buttonPressed = true;
                          });
                          _register(context);
                        }),
                    RichText(text: TextSpan(text: "")),
                    RichText(
                      text: TextSpan(
                        text: "",
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "",
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "",
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                          text: "Hai già un account?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontFamily: 'Avenir Next')),
                    ),
                    FlatButton(
                      padding: EdgeInsets.only(left: 120.0, right: 120.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60.0),
                          side: BorderSide(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: Text('Login',
                          style: TextStyle(
                              fontFamily: 'Avenir Next',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      color: Colors.transparent,
                    ),
                    getProperWidget(),
                  ],
                ),
              ),

              /*
                    if (_formKey.currentState.validate()) {
                      FutureBuilder(
                        future: _register(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            http.Response response = snapshot.data;
                            if (response.statusCode == 201) {
                              _saveToken(response).then((saved) {
                                if (saved == true) {
                                  return AlertDialog(
                                    title: Text('Registrazione effettuata'),
                                    content: Text(
                                        'La registrazione è stata effettuata con successo, verrai reindirizzato/a nella tua home.'),
                                    actions: <Widget>[
                                      RaisedButton(
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CompleteProfileScreen()),
                                              (Route<dynamic> route) => false);
                                        },
                                      )
                                    ],
                                  );
                                } else {
                                  return AlertDialog(
                                    title: Text('Errore'),
                                    content: Text('Errore interno, riprovare.'),
                                    actions: <Widget>[
                                      RaisedButton(
                                        child: Text("Chiudi"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                }
                              });
                            } else {
                              return AlertDialog(
                                title: Text('Errore'),
                                content: Text(response.body),
                                actions: <Widget>[
                                  RaisedButton(
                                    child: Text('Chiudi'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            }
                          } else if (snapshot.hasError) {
                            return AlertDialog(
                              title: Text('Errore'),
                              content: Text('Errore interno, riprovare.'),
                              actions: <Widget>[
                                RaisedButton(
                                  child: Text("Chiudi"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          } else {
                            return new CircularProgressIndicator();
                          }
                        },
                      );
                    }*/
            ],
          ),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      pswInvisible = !pswInvisible;
    });
  }

  Future<bool> _saveToken(/*http.Response*/ String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("token", content);
  }

/*
  Future<String> _getToken() async {
    String key = "token";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(key);
    return token;
  }
*/

  Widget getProperWidget() {
    if (buttonPressed) return new CircularProgressIndicator();
    return SizedBox();
  }
/*
void _initializeHttpClient() async {
  ByteData data = await rootBundle.load('assets/certs/cert.pem');
  SecurityContext con = SecurityContext.defaultContext;
  con.setTrustedCertificatesBytes(data.buffer.asUint8List());
  client = HttpClient(context: con);
  ByteData cert = await rootBundle.load('assets/certs/cert.pem');
  SecurityContext clientContext = new SecurityContext()..setTrustedCertificatesBytes(cert.buffer.asUint8List());
  client = new HttpClient(context: clientContext);
}
*/

  Future<void> _register(BuildContext context
      /*
      String username, String email, String password*/
      ) async {
    print("Register");
    var username = controllerTextUsername.text;
    var email = controllerTextEmail.text;
    var password = controllerTextPassword.text;
    var url = getUrl() + "register";
    final response = await http.post(url, body: {
      "username": "$username",
      "email": "$email",
      "password": "$password",
    });
    setState(() {
      buttonPressed = false;
    });
    if (response.statusCode == 201) {
      _saveToken(json.decode(response.body)["token"]).then((saved) {
        if (saved == true) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                  title: Text('Registrazione effettuata',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Avenir Next',
                    fontSize: 20
                  ),),
                  content: Text(
                      'La registrazione è stata effettuata con successo, verrai reindirizzato/a nella tua home.'),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text(
                        'Ok',
                        style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next'),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompleteProfileScreen()),
                            (Route<dynamic> route) => false);
                      },
                    )
                  ],
                );
              });
        } else {
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
                  content: Text('Errore interno, riprovare.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Avenir Next',
                    fontSize: 20
                  ),),
                  actions: <Widget>[
                    RaisedButton(
                      child:
                          Text("Chiudi", style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next')),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
      });
    } else {
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
              content: Text(response.body),
              actions: <Widget>[
                RaisedButton(
                  child: Text('Chiudi', style: TextStyle(color: Colors.white, fontFamily: 'Avenir Next')),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }
}

/*

var username = controllerTextUsername.text;
    var email = controllerTextEmail.text;
    var password = controllerTextPassword.text;
    var url = "https://10.0.2.2:5000/register";
    client.getUrl(Uri.parse(url)).then((request) {
      request.add(utf8.encode(json.encode({
      "username": "$username",
      "email": "$email",
      "password": "$password",
    })));
    request.close();
    }).then((HttpClientResponse response){  
      setState(() {
       buttonPressed = false; 
      });
      var content;
      response.transform(utf8.decoder).listen((onData){
        content = onData;
      });
    if (response.statusCode == 201) {
      _saveToken(content).then((saved) {
      });
    
    print("Response resceived");
    }
    });
    

    
        if (saved == true) {
          return AlertDialog(
            title: Text('Registrazione effettuata'),
            content: Text(
                'La registrazione è stata effettuata con successo, verrai reindirizzato/a nella tua home.'),
            actions: <Widget>[
              RaisedButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CompleteProfileScreen()),
                      (Route<dynamic> route) => false);
                },
              )
            ],
          );
        } else {
          return AlertDialog(
            title: Text('Errore'),
            content: Text('Errore interno, riprovare.'),
            actions: <Widget>[
              RaisedButton(
                child: Text("Chiudi"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      });
    } else {
      return AlertDialog(
        title: Text('Errore'),
        content: Text(content),
        actions: <Widget>[
          RaisedButton(
            child: Text('Chiudi'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    }

*/
