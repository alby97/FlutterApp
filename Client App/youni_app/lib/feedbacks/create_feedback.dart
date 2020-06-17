import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';

class CreateFeedbackScreen extends StatefulWidget {
  @override
  _CreateFeedbackScreenState createState() => _CreateFeedbackScreenState();
}

class _CreateFeedbackScreenState extends State<CreateFeedbackScreen> {
  TextEditingController _titleController = new TextEditingController(),
      _descriptionController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                autofocus: true,
                controller: _titleController,
                decoration: InputDecoration(
                    prefix: Text(
                  "Titolo",
                  style: TextStyle(fontFamily: 'Avenir Next'),
                )),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Inserire un titolo";
                  }
                },
              ),
              TextFormField(
                maxLines: 5,
                controller: _descriptionController,
                decoration: InputDecoration(
                    prefix: Text(
                  "Descrizione",
                  style: TextStyle(fontFamily: 'Avenir Next'),
                )),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Inserire una descrizione";
                  }
                },
              ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    http.Response response = await http
                        .post(getUrlHome() + "createFeedback", body: {
                      "title": _titleController.text,
                      "description": _descriptionController.text
                    }, headers: {
                      HttpHeaders.authorizationHeader: await getToken()
                    });
                    checkResponseStatus(response, context);
                    if (response.statusCode == 201) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text("Feedback inviato con successo"),
                              actions: <Widget>[
                                FlatButton(child: Text("Chiudi"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },)
                              ],
                              content: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.green,
                              )));
                    } else {
                      showDialog(
                          context: context,
                          
                          builder: (context) => AlertDialog(
                              title: Text("Feedback non inviato "),
                              actions: <Widget>[
                                FlatButton(child: Text("Chiudi"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },)
                              ],
                              content: Icon(
                                FontAwesomeIcons.timesCircle,
                                color: Colors.red,
                              )));
                    }
                  }
                },
                child: Text("Invia Feedback"),
              )
            ],
          ),
        ));
  }
}
