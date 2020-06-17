import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youni_app/teaching_material/material_teaching_model.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';



class ShowFileSelected extends StatefulWidget {

  final File file;
  final String courseOfStudy, department;

  ShowFileSelected({this.file, this.courseOfStudy, this.department});

  @override
  _ShowFileSelectedState createState() => _ShowFileSelectedState(
      file: file, courseOfStudy: courseOfStudy, department: department);
}

class _ShowFileSelectedState extends State<ShowFileSelected> {
  final File file;
  MaterialTeachingFile mFile;
  final String courseOfStudy, department;

  _ShowFileSelectedState({this.file, this.courseOfStudy, this.department});

  bool _done = false;

  TextEditingController _descriptionController,
      _professorController,
      _academicYearController,
      _teachingController;
  FocusNode _professorNode, _academicYearNode, _teachingNode;

  @override
  void initState() {
    super.initState();
    setState(() {
      _descriptionController = new TextEditingController();
      _professorController = new TextEditingController();
      _academicYearController = new TextEditingController();
      _teachingController = new TextEditingController();
      _professorNode = new FocusNode();
      _academicYearNode = new FocusNode();
      _teachingNode = new FocusNode();
      mFile = new MaterialTeachingFile(
        data: file.readAsBytesSync(),
        dipartimento: department,
        corsoDiStudi: courseOfStudy,
        nomeFile: path.basename(file.path),
      );
      _done = true;
    });
  }

  List<String> allowedExtension = [
    '.docx',
    '.txt',
    '.zip',
    '.rar',
    '.pdf',
    '.pptx',
    '.xlsx',
    '.csv',
    '.jpg',
    '.jpeg',
    '.png'
  ];

  Icon getProperIcon(String extension) {
    Icon icon = null;
    switch (extension) {
      case '.docx':
        icon = new Icon(FontAwesomeIcons.fileWord);
        break;
      case '.zip':
        icon = new Icon(FontAwesomeIcons.fileArchive);
        break;
      case '.rar':
        icon = new Icon(FontAwesomeIcons.fileArchive);
        break;
      case '.pdf':
        icon = new Icon(FontAwesomeIcons.filePdf);
        break;
      case '.pptx':
        icon = new Icon(FontAwesomeIcons.filePowerpoint);
        break;
      case '.xlsx':
        icon = new Icon(FontAwesomeIcons.fileExcel);
        break;
      case '.csv':
        icon = new Icon(FontAwesomeIcons.fileCsv);
        break;
      case '.jpg':
        icon = new Icon(FontAwesomeIcons.fileImage);
        break;
      case '.jpeg':
        icon = new Icon(FontAwesomeIcons.fileImage);
        break;
      case '.png':
        icon = new Icon(FontAwesomeIcons.fileImage);
        break;
      default:
        icon = new Icon(FontAwesomeIcons.file);
        break;
    }
    return icon;
  }


  bool checkTextForm() {
    return _academicYearController.text.length > 0 && _descriptionController.text.length > 0 && _professorController.text.length > 0 && _teachingController.text.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: getProperIcon(path.extension(file.path)),
        ),
        //campi da completare: descrizione, professore, anno accademico
        //insegnamento
        ListTile(
          leading: Text("Descrizione: "),
          title: TextFormField(
            autofocus: true,
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Inserisci una descrizione',
            ),
            onFieldSubmitted:  (value) {
              FocusScope.of(context).requestFocus(_teachingNode);
            },
          ),
        ),
        ListTile(
          leading: Text("Insegnamento: "),
          title: TextFormField(
            controller: _teachingController,
            focusNode: _teachingNode,
            decoration: InputDecoration(
              hintText: 'Inserisci l\'insegnamento relativo al file',
            ),
            onFieldSubmitted:  (value) {
              FocusScope.of(context).requestFocus(_professorNode);
            },
          ),
        ),
        ListTile(
          leading: Text("Professore: "),
          title: TextFormField(
            controller: _professorController,
            focusNode: _professorNode,
            decoration: InputDecoration(
              hintText: 'Inserisci il professore responsabile del corso',
            ),
            onFieldSubmitted:  (value) {
              FocusScope.of(context).requestFocus(_academicYearNode);
            },
          ),
        ),
        ListTile(
          leading: Text("Anno Accademico: "),
          title: TextFormField(
            controller: _academicYearController,
            focusNode: _academicYearNode,
            decoration: InputDecoration(
              hintText: 'Inserisci l\'anno accademico relativo al file',
            ),
          ),
        ),
        Center(
          child: RaisedButton.icon(onPressed: () async {
            //!Valida i campi, completa il mFile e invia
            bool valid = checkTextForm();
            if(valid) {
              mFile.annoAccademico = _academicYearController.text;
              mFile.descrizione = _descriptionController.text;
              mFile.insegnamento = _teachingController.text;
              mFile.professore = _professorController.text;
              mFile.author = await getValue("Username");
              mFile.authorName = await getValue('name');
              mFile.authorSurname = await getValue('surname');
              mFile.timestamp = DateTime.now().toString();
              var url = Uri.encodeFull(getUrlHome()+"materialTeaching/departments/$department/courses/$courseOfStudy/uploadFiles");
              http.Response response = await http.post(url, headers: {HttpHeaders.authorizationHeader : await getToken()}, body: {
                'material_teaching_file' : mFile.toJson()
              });
              checkResponseStatus(response, context);
              if(response.statusCode == 201) {
                showDialog(context: context,
                builder: (context) => AlertDialog(
                  content: Column(children: <Widget>[
                    Icon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                    Text("Il file è stato caricato con successo!")
                  ],),
                  actions: <Widget>[
                    FlatButton(onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();//da vedere se ne servano 2 o più di due
                    }, child: Text("Torna indietro"))
                  ],

                )
                );
              }
              else {
                showDialog(context: context,
                builder: (context) => AlertDialog(
                  content: Column(children: <Widget>[
                    Icon(FontAwesomeIcons.checkCircle, color: Colors.green,),
                    Text("C'è stato un problema")
                  ],),
                  actions: <Widget>[
                    FlatButton(onPressed: () {
                      //riprovare
                    }, child: Text('Riprova')),
                    FlatButton(onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();//da vedere se ne servano 2 o più di due
                    }, child: Text("Torna indietro"))
                  ],

                )
                );
              }
            }
            else {
              showDialog(context: context,
              builder: (context) => AlertDialog(
                title: Text('Errore'),
                content: Text('Alcuni campi sono vuoti'),
                actions: <Widget>[
                  FlatButton(onPressed: () => Navigator.of(context).pop(), child: Text('Chiudi'))
                ],
              ));
            }
          }, icon: Icon(FontAwesomeIcons.upload), label: Text("Carica")),
        )
      ],
    ));
  }
}
