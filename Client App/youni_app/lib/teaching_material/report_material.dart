import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/teaching_material/material_teaching_model.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';

class ReportMaterialScreen extends StatefulWidget {
  
  final MaterialTeachingFile materialTeachingFile;

  ReportMaterialScreen({this.materialTeachingFile});

  @override
  _ReportMaterialScreenState createState() => _ReportMaterialScreenState(materialTeachingFile: materialTeachingFile);
}



class _ReportMaterialScreenState extends State<ReportMaterialScreen> {


  final MaterialTeachingFile materialTeachingFile;


  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _titleController = new TextEditingController(), _descriptionController = new TextEditingController();

  String _selectedType = null;
  List<String> reportTypes = ["Spam", "Abuso", "Violenza", "Contenuto inappropriato","Altro"];


  _ReportMaterialScreenState({this.materialTeachingFile});

  List<DropdownMenuItem<String>> buildDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for(String type in reportTypes){
      items.add(DropdownMenuItem(child: Text(type), value: type,),);
    }
    return items;
  }

  onChangeDropDownItem(String type) {
    setState(() {
      _selectedType = type;
    });
  }

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
             DropdownButton(value: _selectedType, items: buildDropDownMenuItems(), onChanged: onChangeDropDownItem, hint: Text("Selezione il tipo di segnalazione"),),
             NiceButton(onPressed: () async {/**invia segnalazione */
             if(_formKey.currentState.validate()){
               http.Response response = await http.post(getUrlHome()+"createReport", headers: {HttpHeaders.authorizationHeader : await getToken()},body: {
                 "title" : _titleController.text,
                 "description" : _descriptionController.text,
                 "type" : _selectedType,
                 "material_teaching_id" : materialTeachingFile.id
               });
               checkResponseStatus(response, context);
               if(response.statusCode == 201) {
                 showDialog(context: context, builder: (context) => AlertDialog(
                   title: Text("Segnalazione inviata con successo inviato con successo"),
                              actions: <Widget>[
                                FlatButton(child: Text("Chiudi"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },)
                              ],
                              content: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.green,
                 )));
               }
               else {
                 showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text("Segnalazione non inviata"),
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
             
             }, text: "Invia", background: Colors.black, icon: Icons.send,)
           ],
         )),
    );
  }
}