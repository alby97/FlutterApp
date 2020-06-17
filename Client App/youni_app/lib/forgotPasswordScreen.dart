import 'package:flutter/material.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatelessWidget {
  TextEditingController _controller = new TextEditingController();

  static final  _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(),
        body: new Container(
            padding: EdgeInsets.all(5.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: 'Inserisci la tua email o il tuo username'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Per favore, inserire username o email';
                      } 
                      return null;
                    },
                  ),
                  new RaisedButton(
                    onPressed: () {
                      print(_controller.text);
                      print(_formKey.toString());
                      print(_formKey.currentState.toString());
                      if (_formKey.currentState.validate()) {
                        String url = getUrl() + "forgotPassword";
                        http.post(url, body: {
                          'nameOrEmail': _controller.text
                        }).then((response) {
                          print(response.body);
                          if (response.statusCode == 200) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                                      content: Text(response.body),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                              'Torna alla schermata iniziale',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Avenir Next',
                                                fontSize: 20
                                              ),),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    'firstScreen',
                                                    ((Route<dynamic> route) =>
                                                        false));
                                          },
                                        )
                                      ],
                                    ));
                          }
                        });
                      }
                    },
                    child: Text('Reset password'),
                  )
                ],
              ),
            )));
  }
}
