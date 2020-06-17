import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youni_app/utils/utility.dart';

class ShowFilesSelected extends StatefulWidget {
  final List<File> files;

  final List<String> filesName;

  final FileType fileType;

  final String myUsername, chatName, id;

  final SocketIO socket;

  final bool isAcademic;

  ShowFilesSelected(
      {this.files,
      this.filesName,
      this.fileType,
      this.myUsername,
      this.chatName,
      this.socket,
      this.isAcademic,
      this.id});

  _ShowFilesSelectedState createState() => _ShowFilesSelectedState(
      files: files,
      filesName: filesName,
      fileType: fileType,
      chatName: chatName,
      myUsername: myUsername,
      socket: socket,
      isAcademic: isAcademic,
      id: id);
}

class _ShowFilesSelectedState extends State<ShowFilesSelected>
    with WidgetsBindingObserver {
  final List<File> files;

  final List<String> filesName;

  final FileType fileType;

  final String myUsername, chatName, id;

  final SocketIO socket;

  final bool isAcademic;

  int currentIndex;

  _ShowFilesSelectedState(
      {this.files,
      this.filesName,
      this.fileType,
      this.myUsername,
      this.chatName,
      this.socket,
      this.isAcademic,
      this.id});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentIndex = 0;
  }

  Widget childToShow() {
    switch (fileType) {
      case FileType.IMAGE:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Expanded(
              child:*/ CarouselSlider(
                autoPlay: false,
                aspectRatio: 1.0,
                enlargeCenterPage: true,
                scrollPhysics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                items: List.generate(files.length, (i) {
                  return  Container(
                     //width: MediaQuery.of(context).size.width * 0.70,
                     //height: MediaQuery.of(context).size.height * 0.70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child:  Image.file(files[i]),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 3.0),
                  );
                }),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
          //  ),
          /*  Expanded(
              child:*/ Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(files.length, (i) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == i
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4)),
                  );
                }),
              ),
          //  )
          ],
        );
      case FileType.CUSTOM:
        return Container(
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            addSemanticIndexes: true,
            scrollDirection: Axis.horizontal,
            children: List.generate(files.length, (i) {
              return Container(
                child: Column(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.file),
                    Text(filesName[i]),
                  ],
                ),
                padding: EdgeInsets.all(15.0),
              );
            }),
          ),
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: childToShow(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () async {
          //send files
          int i = 0;
          for (File f in files) {
            var fileToSend;
            String msgType;
            if (fileType == FileType.IMAGE) {
              fileToSend = Uint8List.fromList(f.readAsBytesSync());
              msgType = "image";
            } else if (fileType == FileType.CUSTOM) {
              fileToSend = Uint8List.fromList(f.readAsBytesSync());
              msgType = "pdf";
            }
            print(fileToSend);
            String timestamp = DateTime.now().toString();
            print(id);
            print(isAcademic);
            socket.emit(("chat message"), [
              {
                "idChat": id,
                "author": myUsername,
                "chat": chatName,
                "timestamp": timestamp,
                "message_type": msgType,
                "file_name": filesName.elementAt(i),
                "file": fileToSend,
                "author_name": await getValue('name'),
                "author_surname": await getValue('surname'),
                "is_academic": isAcademic.toString()
              }
            ]);
            print("Message for file " + i.toString() + " emitted");
            Directory dir = await getApplicationDocumentsDirectory();
            File fTemp = new File(dir.path +
                "/" +
                chatName +
                "/" +
                timestamp.replaceAll(":", "_").replaceAll(' ', '_') +
                "_" +
                filesName.elementAt(i));
            fTemp.createSync(recursive: true);
            fTemp.writeAsBytesSync(f.readAsBytesSync());
            //f.deleteSync();
            i++;
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
