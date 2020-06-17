import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:youni_app/teaching_material/material_teaching_model.dart';
import 'package:youni_app/teaching_material/report_material.dart';


class ShowFileDetailsScreen extends StatefulWidget {
  
  final MaterialTeachingFile materialTeachingFile;

  ShowFileDetailsScreen({this.materialTeachingFile});

  @override
  _ShowFileDetailsScreenState createState() => _ShowFileDetailsScreenState(materialTeachingFile: materialTeachingFile);
}

class _ShowFileDetailsScreenState extends State<ShowFileDetailsScreen> {

  final MaterialTeachingFile materialTeachingFile;

  _ShowFileDetailsScreenState({this.materialTeachingFile});

  bool _done = false;

@override
  void initState() {
    super.initState();
    print(materialTeachingFile);
    setState(() {
      _done = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return _done == false ? SpinKitPouringHourglass(color: Colors.black, size: 50,) : Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          TextFormField(
            readOnly: true,
            initialValue: materialTeachingFile.nomeFile,
          ),TextFormField(
            readOnly: true,
            initialValue: materialTeachingFile.descrizione,
            maxLines: 5,
          ),TextFormField(
            readOnly: true,
            initialValue: materialTeachingFile.professore,
          ),TextFormField(
            readOnly: true,
            initialValue: materialTeachingFile.dipartimento + " - " + materialTeachingFile.corsoDiStudi + " - " + "A.A. " + materialTeachingFile.annoAccademico,
            maxLines: 2,
          ),TextFormField(
            readOnly: true,
            initialValue: "Insegnamento: " + materialTeachingFile.insegnamento,
          ),TextFormField(
            readOnly: true,
            initialValue: "Caricato il: " + DateTime.parse(materialTeachingFile.timestamp).toString() + ", da: " + materialTeachingFile.authorName + " " + materialTeachingFile.authorSurname,
            maxLines: 2,
          ),
          NiceButton(onPressed: () {}, text: "Download", background: Colors.black, icon: FontAwesomeIcons.download, elevation: 4.0,),
          NiceButton(onPressed: (){
            Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ReportMaterialScreen(materialTeachingFile: materialTeachingFile,)));
          }, text: "Segnala", background: Colors.black, icon: FontAwesomeIcons.exclamation, elevation: 4.0, mini: true,)
        ],
      ),
    );
  }
}