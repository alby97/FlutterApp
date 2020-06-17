import 'dart:io';
import 'package:folder_picker/folder_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:youni_app/utils/utility.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportUserDataScreen extends StatefulWidget {
  @override
  _ExportUserDataScreenState createState() => _ExportUserDataScreenState();
}

class _ExportUserDataScreenState extends State<ExportUserDataScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<String> getUserData() async {
    http.Response response = await http.get(getUrlHome() + "exportUserData",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null; //!gestire errore nell'onTap
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
              side: BorderSide(
                  color: Colors.white, style: BorderStyle.solid, width: 2)),
          child: Text("Esporta dati",
              style: TextStyle(
                  fontFamily: 'Avenir Next',
                  fontSize: 20,
                  color: Colors.white)),
          onPressed: () async {
            String data = await getUserData();
            bool permissionOk = false;
            if (await PermissionHandler()
                    .checkPermissionStatus(PermissionGroup.storage) ==
                PermissionStatus.granted) {
              permissionOk = true;
            } else {
              PermissionHandler().requestPermissions(
                  [PermissionGroup.storage]).then((value) async {
                if (value[PermissionGroup.storage] ==
                    PermissionStatus.granted) {
                  permissionOk = true;
                }
              });
            }
            if (permissionOk) {
              Directory dir = await path.getExternalStorageDirectory();
              print(dir.path);
              print(dir.listSync());
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return FolderPickerPage(
                  rootDirectory: dir,
                  action: (context, folder) async {
                    File userData = new File(folder.path + "/userData.html");
                    userData.writeAsStringSync(data);
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Dati salvati correttamente"),
                              content: Column(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.checkCircle,
                                    color: Colors.green,
                                  ),
                                  Text(
                                      "Il file è stato salvato nella seguente cartella:\n" +
                                          userData.path)
                                ],
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ));
                  },
                );
              }));
            }

            //print(userData.readAsStringSync());
          },
        ),
      ),
    );
  }
}
