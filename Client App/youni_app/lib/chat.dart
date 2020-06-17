import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bubble/bubble.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathUtil;
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youni_app/photo_view_screen.dart';
import 'package:youni_app/showFilesSelected.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/firebaseMsgUtils.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class Chat extends StatefulWidget {
  final String chatName, id;

  Chat({this.chatName, this.id});

  ChatState createState() => ChatState(chatName: chatName, id: id);
}

class ChatState extends State<Chat> with WidgetsBindingObserver {
  TextEditingController _textController = TextEditingController();

  String myUsername;
  final String chatName, id;

  ChatState({this.chatName, this.id});

  List<_ChatMessage> _messages = <_ChatMessage>[];
  List<String> chatsJoined, chatsToNotify;

  bool joined = false;
  bool done = false;
  bool messageListCreated = false;
  bool _isWriting = false;
  bool _attachButtonPressed = false;
  bool _showAppBarOptions = false;

  SocketIOManager manager;
  SocketIO socket;

  FileType _pickingType;

  List<File> files;
  List<String> filesName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getValue("Username").then((value) {
      myUsername = value;
      SharedPreferences.getInstance().then((prefs) {
        chatsJoined = prefs.getStringList('joinedChats');
        chatsToNotify = prefs.getStringList("chatsToNotify");
        print(chatsJoined);
        manager = SocketIOManager();
        joined = chatsJoined.contains("chat_sv_" + id);
        if (joined == true) {
          initSocket();
        }
      });
    });
    //mi prendo tutti i messaggi
    getToken().then((token) {
      http.post(getUrlHome() + "getMessages",
          headers: {HttpHeaders.authorizationHeader: token},
          body: {"chat_id": id}).then((response) {
            checkResponseStatus(response, context);
        if (response.statusCode == 201) {
          print("Body" + response.body);
          var jsonData = response.body.isEmpty
              ? null
              : json.decode(response.body); //["messages"];
          print(jsonData);
          if (jsonData != null) {
            _createMessageList(_messages, jsonData);
            setState(() {
              messageListCreated = true;
              print("True mes");
            });
          } else {
            setState(() {
              messageListCreated = true;
              print("True mes");
            });
          }
        } else {
          //TODO: gestire errore
        }
      });
    });
    _textController.addListener(() {
      if (_textController.text.isNotEmpty) {
        setState(() {
          _isWriting = true;
        });
      }
      if (_textController.text.isEmpty) {
        setState(() {
          _isWriting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    if (socket != null) {
      socket.emit("disconnect", []);
      print("Disconnected");
      manager.clearInstance(socket);
    }
    super.dispose();
  }

  void initSocket() async {
    socket = await manager.createInstance(SocketOptions(getUrl() + "chat"));
    socket.onConnect((data) {
      print("Connected");
      print(data);
      print("Chats Joined");
      print(chatsJoined);
      if (chatsJoined != null /*&& !chatsJoined.contains(chatName)*/) {
        var j = chatsJoined.contains("chat_sv_" + id);
        socket.emit("join", [
          {
            "chatName": chatName,
            "username": myUsername,
            "joined": j,
            "idChat": id,
            "is_academic": false.toString()
          }
        ]);
        if (j == false) {
          subscribeChatNew(id, false);
          chatsJoined.add("chat_sv_" + id);
          saveListString('joinedChats', chatsJoined);
          chatsToNotify.add("chat_sv_" + id);
          saveListString('chatsToNotify', chatsToNotify);
        }
        setState(() {
          joined = true;
          done = true;
          print("Twin true");
        });
      }
    });
    socket.on('chat message', (data) {
      print("Chat message event");
      data[0]["myUsername"] = myUsername;
      data[0]["chatName"] = chatName;
      print(data);
      /*
      String author = data[0]["author"];
      String message = data[0]["message"];
      String timestamp = data[0]["timestamp"];
      String messageType = data[0]["message_type"];
      String url = data[0]["url"];
      */
      _ChatMessage msg = new _ChatMessage.fromJson(data[0]);
      /*new _ChatMessage(
        username: author,
        text: message,
        timestamp: timestamp,
        url: url != null ? url : "",
        messageType: messageType,
        fileName: data[0]["file_name"] != null ? data[0]["file_name"] : "",
        myUsername: myUsername,
      );*/
      print("Ok message");
      setState(() {
        _messages.insert(0, msg);
      });
    });
    setState(() {
      joined = true;
      done = true;
      print("Twin true");
    });
    socket.connect();
  }

  Widget _sendButton() {
    IconButton sendButton = IconButton(
        icon: new Icon(Icons.send),
        onPressed: () {
          _handleSubmitted(_textController.text /*, context*/);
        });
    return sendButton;
  }

  Widget _imageButton() {
    return IconButton(
      icon: Icon(Icons.image),
      onPressed: () async {
        _pickingType = FileType.IMAGE;
        files = await FilePicker.getMultiFile(type: _pickingType);
        if (files != null) {
          filesName = new List<String>();
          for (File f in files) {
            String fileName = pathUtil.basename(f.path);
            filesName.add(fileName);
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ShowFilesSelected(
                    id: id,
                    chatName: chatName,
                    files: files,
                    filesName: filesName,
                    fileType: _pickingType,
                    myUsername: myUsername,
                    socket: socket,
                    isAcademic: false,
                  )));
        }
      },
    );
  }

  Widget _cameraButton() {
    return IconButton(
      icon: Icon(FontAwesomeIcons.camera),
      onPressed: () async {
        File image = await ImagePicker.pickImage(source: ImageSource.camera);
        String fileName = pathUtil.basename(image.path);
        _pickingType = FileType.IMAGE;
        files = new List<File>();
        files.add(image);
        filesName = new List<String>();
        filesName.add(fileName);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShowFilesSelected(
                  id: id,
                  isAcademic: false,
                  chatName: chatName,
                  files: files,
                  filesName: filesName,
                  fileType: _pickingType,
                  myUsername: myUsername,
                  socket: socket,
                )));
      },
    );
  }

  Widget _videoButton() {
    return IconButton(
      icon: Icon(Icons.videocam),
      onPressed: () async {
        _pickingType = FileType.VIDEO;
        files = await FilePicker.getMultiFile(type: _pickingType);
        filesName = new List<String>();
        for (File f in files) {
          String fileName = pathUtil.basename(f.path);
          filesName.add(fileName);
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShowFilesSelected(
                  id: id,
                  isAcademic: false,
                  chatName: chatName,
                  files: files,
                  filesName: filesName,
                  fileType: _pickingType,
                  myUsername: myUsername,
                  socket: socket,
                )));
      },
    );
  }

  Widget _fileButton() {
    return IconButton(
      icon: Icon(Icons.description),
      onPressed: () async {
        _pickingType = FileType.CUSTOM;
        files = await FilePicker.getMultiFile(
            type: _pickingType, fileExtension: 'pdf');
        filesName = new List<String>();
        for (File f in files) {
          String fileName = pathUtil.basename(f.path);
          filesName.add(fileName);
        }
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ShowFilesSelected(
                  id: id,
                  isAcademic: false,
                  chatName: chatName,
                  files: files,
                  filesName: filesName,
                  fileType: _pickingType,
                  myUsername: myUsername,
                  socket: socket,
                )));
      },
    );
  }

  List<IconButton> _buildAppBarOptions() {
    IconButton enableDisableNotifications = new IconButton(
      icon: Icon(
        messageListCreated == false
            ? null
            : chatsToNotify.contains("chat_sv_"+id)
                ? Icons.volume_up
                : Icons.volume_off,
      ),
      onPressed: () async {
        if (chatsToNotify.contains("chat_sv_"+id)) {
          http.Response response = await http.post(
              getUrlHome() + "disableNotificationChat",
              headers: {HttpHeaders.authorizationHeader: await getToken()},
              body: {chatName: "chat_sv_"+id});
              checkResponseStatus(response, context);
          if (response.statusCode == 201) {
            unsubscribeChatNew(id, false);
            //showDialog (?)
            chatsToNotify.remove("chat_sv_"+id);
            await saveListString("chatsToNotify", chatsToNotify);
            setState(() {});
          } else {
            //showError
          }
        } else {
          http.Response response = await http.post(
              getUrlHome() + "enableNotificationChat",
              headers: {HttpHeaders.authorizationHeader: await getToken()},
              body: {chatName: "chat_sv_"+id});
              checkResponseStatus(response, context);
          if (response.statusCode == 201) {
            subscribeChatNew(id, false);
            chatsToNotify.add("chat_sv_"+id);
            await saveListString("chatsToNotify", chatsToNotify);
            setState(() {});
          } else {
            //showError
          }
        }
      },
    );
    IconButton leaveChat = new IconButton(
      icon: Icon(FontAwesomeIcons.signOutAlt),
      onPressed: () async {
        //TODO: Implement leave chat
        http.Response response = await http.post(getUrlHome() + "leaveChat",
            headers: {HttpHeaders.authorizationHeader: await getToken()},
            body: {"chatName": chatName});
            checkResponseStatus(response, context);
        if (response.statusCode == 201) {
          chatsToNotify.remove(chatName);
          await saveListString("chatsToNotify", chatsToNotify);
          chatsJoined.remove(chatName);
          await saveListString("joinedChats", chatsJoined);
          unsubscribeChatNew(id, false);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
                  content: Text(
                      "Hai lasciato la chat, clicca ok per tornare al menu delle chat.",
                      style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                fontSize: 20)),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok',style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next',
                )),
                      onPressed: () {
                        Navigator.popUntil(
                            context, ModalRoute.withName('/chats'));
                      },
                    )
                  ],
                );
              });
        } else {
          //TODO show error
        }
      },
    );
    List<IconButton> appBarOptions = new List<IconButton>();
    appBarOptions.add(enableDisableNotifications);
    appBarOptions.add(leaveChat);
    return appBarOptions;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
      appBar: new AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
        bottom: PreferredSize(child: Container(color: Colors.blue, height: 2), preferredSize: Size.fromHeight(2)),
        title: new Text(chatName,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Avenir Next',
          fontSize: 20
        )),
        actions: joined == false
            ? null
            : <Widget>[
                PopupMenuButton<IconButton>(
                  icon: Icon(FontAwesomeIcons.ellipsisV),
                  itemBuilder: (BuildContext context) {
                    return _buildAppBarOptions().map((IconButton button) {
                      return PopupMenuItem<IconButton>(
                        value: button,
                        child: button,
                      );
                    }).toList();
                  },
                ), /*
          IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisV),
            onPressed: () {
              _showAppBarOptions = !_showAppBarOptions;
            },
          ),*/
              ],
      ),
      body: messageListCreated == false
          ? Center(child: SpinKitPouringHourglass(
            color: Colors.white,
          ))
          : new Column(
              children: <Widget>[
                new Flexible(
                  child: new ListView.builder(
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length,
                  ),
                ),
                new Divider(height: 1.0),
                _attachButtonPressed == true
                    ? Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            _imageButton(),
                            _cameraButton()
                            // _videoButton(),
                            // _fileButton()
                          ],
                        ),
                      )
                    : Container(),
                new Container(
                  decoration:
                      new BoxDecoration(color: Color.fromRGBO(25, 25, 25, 1.0)),
                  child: _buildTextComposer(context),
                ),
              ],
            ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    return joined == false
          ? FlatButton(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(60.0)
            ),
              child: Text("Unisciti alla chat",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Avenir Next'
              )),
              onPressed: () {
                initSocket();
              },
            )
          : new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child:  new Row(
              children: <Widget>[
                new Flexible(child: LayoutBuilder(
                  builder: (context, size) {
                    TextSpan text = new TextSpan(
                      text: _textController.text,
                    );
                    TextPainter tp = new TextPainter(
                      text: text,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    );
                    tp.layout(maxWidth: size.maxWidth);
                    int lines =
                        (tp.size.height / tp.preferredLineHeight).ceil();
                    int maxLines = 5;
                    return new TextField(
                      maxLines: lines < maxLines ? null : maxLines,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _textController,
                      //onSubmitted:  //_handleSubmitted(context),
                      decoration: new InputDecoration.collapsed(
                          hintText: "Send a message"),
                    );
                  },
                )),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: _isWriting == false
                      ? IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: () {
                            setState(() {
                              _attachButtonPressed = !_attachButtonPressed;
                            });
                            //TODO:
                          },
                        )
                      : SizedBox(),
                ),
                new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 3.0),
                    child: _isWriting
                        ? _sendButton()
                        : MicButton(
                            socket: socket,
                            myUsername: myUsername,
                            chatName: chatName,
                            idChat: id,
                          )),
              ],
            ),
    );
  }

  void _handleSubmitted(String text /*, BuildContext context*/) async {
    if (socket != null) {
      //vedere se implementarlo con l'ACK
      print("Sending message");
      String timestamp = DateTime.now().toString();
      socket.emit /*WithAck*/ (("chat message"), [
        {
          "idChat": id,
          "author": myUsername,
          "message": text,
          "chat": chatName,
          "timestamp": timestamp,
          "message_type": "text",
          "author_name": await getValue('name'),
          "author_surname": await getValue('surname'),
          "is_academic": false.toString()
        }
      ]);
      /*.then((data) {
        print(data);
        var jsonData = json.decode(data)["response"];
        print(jsonData);
        if (jsonData == "Ok") {
          //se è ok allora*/
      print("Message emitted");
      /*_ChatMessage message = new _ChatMessage(
            text: text,
            username: myUsername,
            timestamp: timestamp,
          );
          */
      setState(() {
        //_messages.insert(0, message);
        _textController.clear();
      });
      /*}
        else {
          //altrimenti gestire in caso di messaggio non inviato
          _textController.clear();
        }
      });*/
    }
  }

  void _createMessageList(
      List<_ChatMessage> _messages, List<dynamic> jsonList) {
    print(jsonList);
    for (int i = 0; i < jsonList.length; i++) {
      print(jsonList[i]);
      print("J");
      //print(json.decode(jsonList[i]));
      //print(jsonList[i][0]);
      // print("J2");
      // print(jsonList[i]);
      Map<String, dynamic> x = jsonList[i];
      x["myUsername"] = myUsername;
      x["chatName"] = chatName;
      print(x);
      _messages.insert(
          i, _ChatMessage.fromJson(x /*json.decode(jsonList[i][0])*/));
    }
    for (int i = 0; i < _messages.length; i++) {
      print(_messages[i].text);
    }
  }
}

/*
class _ChatMessage extends StatelessWidget {

  _ChatMessage(
      {this.text,
      this.username,
      this.timestamp,
      this.messageType,
      this.url,
      this.fileName});
  final String text;
  final String username;
  final String timestamp;
  final String messageType;
  final String url;
  final String fileName;

  _ChatMessage.fromJson(Map<String, dynamic> jsonData)
      : text = jsonData["message"],
        username = jsonData["author"],
        timestamp = jsonData["timestamp"],
        messageType = jsonData["message_type"],
        url = jsonData["url"] == null ? "" : jsonData["url"],
        fileName = jsonData["file_name"] == null ? "" : jsonData["file_name"];


        Future<Uint8List> getFile() async {
          http.Response response = await http.post(getUrlHome()+"chats/getFile", headers: {HttpHeaders.authorizationHeader : await getToken()}, body: {"timestamp" : timestamp, "file_name" : fileName});
          print(response);
          print(response.body);
          if(response.statusCode == 200){
            Uint8List fileData = Uint8List.fromList(List<int>.from(json.decode(response.body))) ;
            return fileData;
          }
          else {
            //TODO: gestisci errore
            return null;
          }

        }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(username[0])),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(username, style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: messageType == "text" ? new Text(text) : messageType == "image" ? getFile().then((data) {
                 return Image.memory(data);
                })  : SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

class _ChatMessage extends StatefulWidget {
  _ChatMessage(
      {this.text,
      this.username,
      this.timestamp,
      this.messageType,
      this.url,
      this.fileName,
      this.myUsername,
      this.key,
      this.authorName,
      this.authorSurname,
      this.chatName,
      this.audioDuration});

  final String text;
  final String username;
  final String timestamp;
  final String messageType;
  final String url;
  final String fileName;
  final String myUsername;
  final String authorName;
  final String authorSurname;
  final Key key;
  final String chatName;
  final String audioDuration;

  _ChatMessage.fromJson(Map<String, dynamic> jsonData)
      : text = jsonData["message"],
        username = jsonData["author"],
        timestamp = jsonData["timestamp"],
        messageType = jsonData["message_type"],
        url = jsonData["url"] == null ? "" : jsonData["url"],
        fileName = jsonData["file_name"] == null ? "" : jsonData["file_name"],
        myUsername = jsonData["myUsername"],
        authorName = jsonData["author_name"],
        authorSurname = jsonData["author_surname"],
        key = new Key(jsonData["author"] + " " + jsonData["timestamp"]),
        chatName = jsonData["chatName"],
        audioDuration = jsonData["audio_duration"] == null
            ? ""
            : jsonData["audio_duration"];

  __ChatMessageState createState() => __ChatMessageState(chatMessage: this);
}

class __ChatMessageState extends State<_ChatMessage> {
  _ChatMessage chatMessage;

  __ChatMessageState({this.chatMessage});

//! DA AGGIUNGERE PER I MESSAGGI AUDIO : LA DURATA DELL'AUDIO E LA POSSIBILITA' DI TORNARE INDIETRO (IL SEEK), VEDERE COME FARE

  //bool _done = false;
  bool _fileDownloaded = false;

  Uint8List fileData;
  String _filePath;
  String directory;

  bool _isPlaying = false; //per i messaggi audio
  FlutterSound flutterSound;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  String _playerTxt = '00:00:00';
  double _dbLevel;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  @override
  void initState() {
    super.initState();
    print(chatMessage.authorName);
    print(chatMessage.authorSurname);
    getApplicationDocumentsDirectory().then((dir) {
      directory = dir.path.toString();
      if (chatMessage.messageType == "audio") {
        flutterSound = new FlutterSound();
        flutterSound.setSubscriptionDuration(0.01);
        flutterSound.setDbPeakLevelUpdate(0.8);
        flutterSound.setDbLevelEnabled(true);
        initializeDateFormatting();
      }
      if (chatMessage.messageType != "text") {
        checkIfFileExists().then((onValue) {
          print(onValue);
          File f = new File(directory +
              '/' +
              chatMessage.chatName +
              "/" +
              chatMessage.timestamp.replaceAll(":", "_").replaceAll(' ', '_') +
              "_" +
              chatMessage.fileName);
          if (onValue == true) {
            this.fileData = f.readAsBytesSync();
            this._filePath = f.path;
            this.setState(() {
              _fileDownloaded = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (chatMessage.messageType == "audio") {
      if (_isPlaying == true) {
        print(_isPlaying);
        flutterSound.stopPlayer();
      }
    }
    super.dispose();
  }

  Future<bool> checkIfDirectoryExists() async {
    Directory d = Directory(directory + "/" + chatMessage.chatName);
    print(d.path);
    return await d.exists();
  }

  Future<bool> checkIfFileExists() async {
    File f = new File(directory +
        '/' +
        chatMessage.chatName +
        "/" +
        chatMessage.timestamp.replaceAll(":", "_").replaceAll(' ', '_') +
        "_" +
        chatMessage.fileName);
    print(f.path);
    return await f.exists();
  }

  void getFile() async {
    http.Response response = await http.post(getUrlHome() + "chats/getFile",
        headers: {
          HttpHeaders.authorizationHeader: await getToken()
        },
        body: {
          "timestamp": chatMessage.timestamp,
          "file_name": chatMessage.fileName
        });
    print(response);
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      //File f = File.fromRawPath(response.bodyBytes);
      this.fileData = response.bodyBytes;
      _filePath = (directory +
          '/' +
          chatMessage.chatName +
          "/" +
          chatMessage.timestamp.replaceAll(":", "_").replaceAll(' ', '_') +
          "_" +
          chatMessage.fileName);
      File f = new File(_filePath);
      f.createSync(recursive: true);
      f.writeAsBytesSync(fileData);
      this.setState(() {
        _fileDownloaded = true;
      });
    } else {
      //TODO: gestisci errore
      return null;
    }
  }

  Widget imageCase() {
    if (_fileDownloaded == false) {
      return new Container(
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: Text(chatMessage.fileName),
            ),
            new IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                getFile();
              },
            )
          ],
        ),
      );
    } else {
      return GestureDetector(
        child: new Image.memory(
        fileData,
        height: 200.0,
        width: 200.0,
      ),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) => PhotoViewScreen(data: fileData)));
      },
      );
    }
  }

  /*Widget fileCase() {
    if (_fileDownloaded == false) {
      return Container(
        child: Row(
          children: <Widget>[
            Text(chatMessage.fileName),
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                getFile();
              },
            )
          ],
        ),
      );
    } else {
      return new Container(
        child: InkWell(
          child: Row(
            children: <Widget>[Icon(Icons.description)],
          ),
          onTap: () {
            OpenFile.open(fileData);
          },
        ),
      );
    }
  }*/

  void startPlayer() async {
    print(_filePath);
    try {
      String path = await flutterSound.startPlayer(_filePath);
      await flutterSound.setVolume(1.0);
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          sliderCurrentPosition = e.currentPosition;
          maxDuration = e.duration;
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
          );
          String txt = DateFormat('mm:ss:SS', "it_IT").format(date);
          this.setState(() {
            this._playerTxt = txt.substring(0, 8);
            if (_isPlaying == false) {
              _isPlaying = true;
            }
          });
        } else {
          this.setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      print("Exception");
      print(e);
    }
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      print("Res: " + result);
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      this.setState(() {
        _isPlaying = false;
      });
    } catch (e) {}
  }

  void pausePlayer() async {
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async {
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async {
    //!siccome il seek funziona solo se il player è in stato di play provare a far partire qui il player in caso non sia già partito e vedere se funziona
    //! in modo tale da farlo come whatsapp o telegram
    //await startPlayer();
    String result = await flutterSound.seekToPlayer(milliSecs);
    //await pausePlayer();
    print('seekToPlayer: $result');
  }

  Widget _messageDateTime() {
    DateTime dateTime = DateTime.parse(chatMessage.timestamp);
    String weekDay;
    switch (DateFormat('EEEE').format(dateTime)) {
      case "Monday":
        weekDay = "Lunedì";
        break;
      case "Tuesday":
        weekDay = "Martedì";
        break;
      case "Wednesday":
        weekDay = "Mercoledì";
        break;
      case "Thursday":
        weekDay = "Giovedì";
        break;
      case "Friday":
        weekDay = "Venerdì";
        break;
      case "Saturday":
        weekDay = "Sabato";
        break;
      case "Sunday":
        weekDay = "Domenica";
        break;
      default:
        null;
        break;
    }
    String month;
    switch (DateFormat('MMMM').format(dateTime)) {
      case "January":
        month = "Gennaio";
        break;
      case "February":
        month = "Febbraio";
        break;
      case "March":
        month = "Marzo";
        break;
      case "April":
        month = "Aprile";
        break;
      case "May":
        month = "Maggio";
        break;
      case "June":
        month = "Giugno";
        break;
      case "July":
        month = "Luglio";
        break;
      case "August":
        month = "Agosto";
        break;
      case "September":
        month = "Settembre";
        break;
      case "October":
        month = "Ottobre";
        break;
      case "November":
        month = "Novembre";
        break;
      case "December":
        month = "Dicembre";
        break;
      default:
        null;
        break;
    }
    return Text(
        weekDay +
            ", " +
            dateTime.day.toString() +
            " " +
            month +
            " " +
            dateTime.hour.toString() +
            ":" +
            dateTime.minute.toString(),
        textAlign: TextAlign.right);
  }

  Widget retrieveProperChild() {
    print("Type: " + chatMessage.messageType);

    switch (chatMessage.messageType) {
      case "text":
        return new Bubble(
            alignment: chatMessage.username == chatMessage.myUsername
                ? Alignment.topRight
                : Alignment.topLeft,
            margin: BubbleEdges.only(top: 10),
            nip: chatMessage.myUsername == chatMessage.username
                ? BubbleNip.rightTop
                : BubbleNip.leftTop,
            color: chatMessage.myUsername == chatMessage.username
                ? Color.fromRGBO(225, 255, 199, 1.0)
                : null,
            child: Column(
              children: <Widget>[
                chatMessage.username != chatMessage.myUsername
                    ? new Text(
                        chatMessage.authorName +
                            " " +
                            chatMessage.authorSurname,
                        style: TextStyle(color: Colors.red),
                      )
                    : new SizedBox(),
                chatMessage.username != chatMessage.myUsername
                    ? SizedBox(
                        height: 2.0,
                      )
                    : SizedBox(),
                new Text(
                  chatMessage.text,
                  style: TextStyle(fontSize: 16.0),
                  textAlign: chatMessage.myUsername == chatMessage.username
                      ? TextAlign.right
                      : TextAlign.left,
                ),
                _messageDateTime(), //Text(dateTime.hour.toString() + ":" + dateTime.minute.toString())
              ],
            ));
      case "image":
        return new Bubble(
          alignment: chatMessage.myUsername == chatMessage.username
              ? Alignment.topRight
              : Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              chatMessage.username != chatMessage.myUsername
                  ? new Text(
                      chatMessage.authorName + " " + chatMessage.authorSurname)
                  : new SizedBox(),
              imageCase(),
              SizedBox(
                height: 4.0,
              ),
              _messageDateTime(),
            ],
          ),
          margin: BubbleEdges.only(top: 10),
          nip: chatMessage.myUsername == chatMessage.username
              ? BubbleNip.rightTop
              : BubbleNip.leftTop,
          color: chatMessage.myUsername == chatMessage.username
              ? Color.fromRGBO(225, 255, 199, 1.0)
              : null,
        );
      case "video":
        return new Container(
          child: Row(
            children: <Widget>[
              Text(chatMessage.fileName),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  //TODO:
                },
              )
            ],
          ),
        );
      case "file":
        return new Container(
          child: Row(
            children: <Widget>[
              Text(chatMessage.fileName),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  //TODO:
                },
              )
            ],
          ),
        );
      case "audio":
        return new Bubble(
          alignment: chatMessage.myUsername == chatMessage.username
              ? Alignment.topRight
              : Alignment.topLeft,
          margin: BubbleEdges.only(top: 10),
          nip: chatMessage.myUsername == chatMessage.username
              ? BubbleNip.rightTop
              : BubbleNip.leftTop,
          color: chatMessage.myUsername == chatMessage.username
              ? Color.fromRGBO(225, 255, 199, 1.0)
              : null,
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  chatMessage.myUsername == chatMessage.username
                      ? SizedBox()
                      : Expanded(child: Text(
                          chatMessage.authorName +
                              " " +
                              chatMessage.authorSurname,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  IconButton(
                    icon: _fileDownloaded == false
                        ? Icon(FontAwesomeIcons.download)
                        : _isPlaying == false
                            ? Icon(FontAwesomeIcons.play)
                            : Icon(FontAwesomeIcons.pause),
                    onPressed: () {
                      if (_fileDownloaded == false) {
                        getFile();
                      } else {
                        if (_isPlaying == false) {
                          startPlayer();
                        } else {
                          stopPlayer();
                        }
                      }
                    },
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  _fileDownloaded == false
                      ? Container()
                      : Container(
                          height: 45.0,
                          child: Slider(
                              value: sliderCurrentPosition,
                              min: 0.0,
                              max: maxDuration,
                              onChanged: (double value) async {
                                //await flutterSound.seekToPlayer(value.toInt());
                                await seekToPlayer(value.toInt());
                              },
                              divisions: maxDuration.toInt())),
                  Row(
                    children: <Widget>[
                      _fileDownloaded == false
                          ? SizedBox()
                          : _isPlaying
                              ? Text(_playerTxt)
                              : Text(chatMessage.audioDuration),
                      SizedBox(
                        width: _fileDownloaded == false ? 0.0 : 80.0,
                      ),
                      _messageDateTime()
                      /*  _fileDownloaded == false
                          ? SizedBox()
                          : Text(chatMessage.audioDuration)
                          */
                    ],
                  )
                ],
              ),
            ],
          ),
        );
        break;
      default:
        return null;
        break; //!da gestire meglio
    }
  }

  @override
  Widget build(BuildContext context) {
    return retrieveProperChild();
    /* new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(child: new Text(chatMessage.username[0])),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(chatMessage.username,
                  style: Theme.of(context).textTheme.subhead),
                  retrieveProperChild()
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: retrieveProperChild(),
              ),
              
            ],
          ),
        ],
      ),
    );*/
  }
}

class MicButton extends StatefulWidget {
  final SocketIO socket;
  final String myUsername, chatName, idChat;

  MicButton({this.socket, this.myUsername, this.chatName, this.idChat});

  _MicButtonState createState() => _MicButtonState(
      socket: socket,
      chatName: chatName,
      myUsername: myUsername,
      idChat: idChat);
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  _MicButtonState({this.socket, this.myUsername, this.chatName, this.idChat});

  final String myUsername, chatName, idChat;

  bool _micButtonPressed = false;
  Animation<double> _animation;
  AnimationController _animationController;
  SocketIO socket;

  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  double _dbLevel;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';

  String _path;
  Directory directory;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() => setState(() {}));
    /*..addStatusListener((status) {
      print("Ok1");
      print(_micButtonPressed);
      if(_micButtonPressed == true){
        print("Ok");
        if(status == AnimationStatus.completed){
          _animationController.reverse();
        }
        else {
          _animationController.forward();
        }
        
      }
    });*/
    _animation =
        new Tween<double>(begin: 45.0, end: 65.0).animate(_animationController);
    _animationController.forward();

    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
    getApplicationDocumentsDirectory().then((dir) {
      directory = dir;
    });
  }

  @override
  void dispose() {
    if (flutterSound.isRecording) {
      flutterSound.stopRecorder();
    }
    super.dispose();
  }

  void startRecorder() async {
    try {
      print("Start");
      print(directory.path);
      /* Directory tmp = new Directory(directory.path + "/tmp");
      tmp.createTempSync();
      */
      _path = await flutterSound.startRecorder(/*'audio.m4a'*/);
      print("Ok1");
      print(_path);
      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        print("e " + e.toString());
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
          );
          String txt = DateFormat('mm:ss:SS', 'it_IT').format(date);
          setState(() {
            _recorderTxt = txt.substring(0, 8);
          });
        }
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        setState(() {
          _dbLevel = value;
        });
      });
      /* this.setState(() {
        print("Registration begins");
       _micButtonPressed = true; 
      });
      */
    } catch (err) {
      print("1");
      print(err);
    }
  }

  void stopRecorder() async {
    try {
      print("Stop");
      String result = await flutterSound.stopRecorder();
      print("Stop recorder: " + result);
      String timestamp = DateTime.now().toString();
      if(Platform.isIOS) {
        _path = _path.replaceAll("file://", '');
      }
      String fileName = pathUtil.basename(_path);
      File f = new File(_path);
      File fAudio = File(directory.path +
          "/" +
          chatName +
          "/" +
          timestamp.replaceAll(":", "_").replaceAll(' ', '_') +
          "_" +
          fileName);
      print("Record time: " + _recorderTxt);
      socket.emit('chat message', [
        {
          "idChat": idChat,
          "author": myUsername,
          "chat": chatName,
          "timestamp": timestamp,
          "message_type": "audio",
          "file_name": pathUtil.basename(_path),
          "file": f.readAsBytesSync(),
          "author_name": await getValue('name'),
          "author_surname": await getValue('surname'),
          "audio_duration": _recorderTxt,
          "is_academic": false.toString()
        }
      ]);
      print("Message emitted");
      fAudio.createSync(recursive: true);
      fAudio.writeAsBytesSync(f.readAsBytesSync());
      f.deleteSync();
      print("Recorder text" + _recorderTxt);
      print("Final file path: " + fAudio.path);
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
      setState(() {
        print("Ok2");
        _micButtonPressed = false;
      });
    } catch (err) {
      print("2");
      print(err);
    }
  }

  void showOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: 50.0,
        child: Text("Tieni premuto per registrare",
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              background: Paint()..color = Colors.grey,
              decoration: TextDecoration.none,
            )),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(seconds: 2));
    overlayEntry.remove();
  }

  Widget _micButton() {
    return new GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          showOverlay(context);
        },
        onLongPressStart: (e) async {
          print("Long press begins");
          setState(() {
            print("Registration begins");
            _micButtonPressed = true;
            print(_micButtonPressed);
          });
          startRecorder();
          //START recording
        },
        onLongPressEnd: (e) async {
          print("Long press ends");
          setState(() {
            print("Registration begins");
            _micButtonPressed = false;
            print(_micButtonPressed);
          });
          return stopRecorder();
          //STOP recording
        },
        child: _micButtonPressed == true
            ? Container(
                height: _animation.value,
                width: _animation.value,
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              )
            : Container(
                height: 45.0,
                width: 45.0,
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                ),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return _micButton();
  }
}
