import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/teaching_material/material_teaching_model.dart';
import 'package:youni_app/teaching_material/show_file_details.dart';
import 'package:youni_app/teaching_material/show_file_selected.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class MaterialTeachings extends StatefulWidget {
  

  final String courseOfStudy, department;

  MaterialTeachings({this.courseOfStudy, this.department});

  @override
  _MaterialTeachingsState createState() => _MaterialTeachingsState(courseOfStudy: courseOfStudy, department: department);
}

class _MaterialTeachingsState extends State<MaterialTeachings> with WidgetsBindingObserver {

  final String courseOfStudy, department;

  bool _done = false;

  List<MaterialTeachingFile> files = new List<MaterialTeachingFile> ();

  List<String> allowedExtension = ['.docx', '.txt', '.zip', '.rar', '.pdf', '.pptx', '.xlsx','.csv', '.jpg', '.jpeg', '.png'];

  _MaterialTeachingsState({this.courseOfStudy, this.department});


  Future<List<MaterialTeachingFile>> getFiles() async {
    List<MaterialTeachingFile> files = new List<MaterialTeachingFile> ();
    var url = Uri.encodeFull(getUrlHome()+"materialTeaching/departments/$department/courses/$courseOfStudy/files");
    http.Response response = await http.get(url, headers: {HttpHeaders.authorizationHeader : await getToken()});
    checkResponseStatus(response, context);
    if(response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      for(int i = 0; i < jsonData.length; i++) {
        files.add(MaterialTeachingFile.fromJson(jsonData[i]));
      }
    }
    else {
      //!errore
    }
    print(files);
    return files;
  }

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getFiles().then((list) {
      files = list;
      setState(() {
        _done = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //da fare l'appbar con la ricerca e i filtri
      body: ListView(
        children: List.generate(files.length, (i) => ListTile(
          title: Text(files[i].nomeFile), subtitle: Text(files[i].insegnamento), isThreeLine: true, onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ShowFileDetailsScreen(materialTeachingFile: files[i],)))
        )),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FontAwesomeIcons.plus),
        onPressed: () {
        showDialog(context: context,
        builder: (context) => AlertDialog(
          content: Text('Le possibili estensioni di file selezionabili sono: docx, txt, zip, rar, pdf, pptx, csv, jpg, jpeg, png'),
          actions: <Widget>[
            FlatButton(onPressed: () async {
              File file = await FilePicker.getFile(type: FileType.ANY);
              String extension = path.extension(file.path);
              if(!allowedExtension.contains(extension)){
                Navigator.of(context).pop();
                showDialog(context: context,
                builder: (context) => AlertDialog(
                  content: Text('Hai scelto dei file con un\'estensione non ammessa. Per favore, riprova con altri file.'),
                  actions: <Widget>[
                    FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Chiudi'))
                  ],
                ));
              }
              else {
                //show files with carousel
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ShowFileSelected(courseOfStudy: courseOfStudy, department: department, file: file)));
              }
            }, child: Text('Seleziona file')),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annulla'),
            )
          ],
        )
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
