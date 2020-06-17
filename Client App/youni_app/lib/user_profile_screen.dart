import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:youni_app/changeCourseOfStudy.dart';
import 'package:youni_app/export_user_data_screen.dart';
import 'package:youni_app/image_cropper_screen.dart';
import 'package:youni_app/interests_screen.dart';
import 'package:youni_app/photo_view_screen.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/utility.dart';
import 'dart:io';
import 'dart:convert';
import 'colors.dart' as myColor;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'exams_screen.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'customClipPath.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class _User {
  String username;
  String email;
  String courseStudy;
  String courseType;
  String courseAddress;
  int rating;
  String name;
  String surname;

  _User(
      {this.username,
      this.email,
      this.courseStudy,
      this.courseType,
      this.courseAddress,
      this.rating,
      this.name,
      this.surname});

  factory _User.fromJson(Map<String, dynamic> json) {
    print(json);
    return _User(
        username: json['username'],
        email: json['email'],
        courseStudy: json['courseStudy'],
        courseType: json['courseType'],
        courseAddress:
            json['courseAddress'] == null ? "" : json['courseAddress'],
        rating: json['rating'],
        name: json['name'],
        surname: json['surname']);
  }

  @override
  String toString() {
    return "username: " +
        username +
        ", email: " +
        email +
        ", type: " +
        courseType;
  }
}

Future<String> _getToken() async {
  final String key = "token";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(key);
  print("us" + token);
  return token; //.substring(10, token.length - 2);
}

Future<_User> _getUserInfo() async {
  final String token = await _getToken();
  http.Response response = await http.get(getUrlHome() + 'userInfo',
      headers: {HttpHeaders.authorizationHeader: token});
  if (response.statusCode == 200) {
    print(response.body);
    return _User.fromJson(json.decode(response.body));
  } else {
    //TODO: Gestisci l'errore
    return null;
  }
}

class UserProfileScreen extends StatefulWidget {
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with WidgetsBindingObserver {
  File _image;
  _User _user;
  bool _waitingResp = true;
  bool _nameFieldReadOnly = true;
  bool _fieldSurnameEnabled = false;
  bool defaultImage = false;

  FocusNode _focusName = FocusNode(), _focusSurname = FocusNode();

  TextEditingController _nameController = TextEditingController(),
      _surnameController = TextEditingController();

  void _getImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    /*
    Directory appDir = await getApplicationDocumentsDirectory();
    var path = appDir.path;
    File savedImage = await image.copy("$path/userImage");
    */
    String fileName = path.basename(image.path);
    var url = getUrlHome() + "saveImage";
    print("Url: " + url);
    String token = await _getToken();
    /* var stream  = new http.ByteStream(DelegatingStream.typed(image.openRead()));
    var length = await image.length();
    http.MultipartRequest request = new http.MultipartRequest('POST', Uri.parse(url));
    http.MultipartFile multipartFile = new http.MultipartFile('image', stream, length, filename: fileName);
    request.files.add(multipartFile);
    request.headers[HttpHeaders.authorizationHeader] = token;
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 201) {
      print('Ok');
      Directory appDir = await getApplicationDocumentsDirectory();
      File newImage = new File(appDir.path+"/" + "userProfileImage"+"/"+ fileName);
      newImage.createSync();
      newImage.writeAsBytesSync(image.readAsBytesSync());
      saveValue("userProfileImagePath", newImage.path);
      setState(() {
        _image = image;
      });
    } else {
      //_showError();
    }
*/
/*
    String base64Image = base64Encode(image.readAsBytesSync());
    final http.Response response = await http.put(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {"image": base64Image, "fileName": fileName});
    print("Response");
    print(response.body);
    checkResponseStatus(response, context);
    if (response.statusCode == 201) 
      print('Ok');
      Directory appDir = await getApplicationDocumentsDirectory();
      File newImage =
          new File(appDir.path + "/" + "userProfileImage" + "/" + fileName);
      newImage.createSync(recursive: true);
      newImage.writeAsBytesSync(image.readAsBytesSync());
      saveValue("userProfileImagePath", newImage.path);
      */
    /*setState(() {
        _image = image;
      });
      */
    Directory appDir = await getApplicationDocumentsDirectory();
    //print(appDir.path);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                "Vuoi ritagliare/modificare la tua immagine?",
                style: TextStyle(fontFamily: 'Avenir Next'),
              ),
              actions: <Widget>[
                FlatButton.icon(
                  label: Text("Sì"),
                  icon: Icon(
                    FontAwesomeIcons.checkCircle,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    print("Path: " + image.path);
                    print(appDir.path);
                    File croppedImage = await ImageCropper.cropImage(
                      sourcePath: image.path,
                      aspectRatioPresets: Platform.isAndroid
                          ? [
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio16x9
                            ]
                          : [
                              CropAspectRatioPreset.original,
                              CropAspectRatioPreset.square,
                              CropAspectRatioPreset.ratio3x2,
                              CropAspectRatioPreset.ratio4x3,
                              CropAspectRatioPreset.ratio5x3,
                              CropAspectRatioPreset.ratio5x4,
                              CropAspectRatioPreset.ratio7x5,
                              CropAspectRatioPreset.ratio16x9
                            ],
                    );
                    String croppedFileName = path.basename(croppedImage.path);
                    print("Cropped");
                    print(croppedFileName);
                    Directory userProfile = new Directory(appDir.path+"/userProfileImage");
                    if(!userProfile.existsSync()){
                      userProfile.createSync();
                    }
                    File croppedImageSaved = croppedImage.copySync(appDir.path +
                        "/" +
                        "userProfileImage" +
                        "/" +
                        croppedFileName);
                    String base64Image =
                        base64Encode(croppedImageSaved.readAsBytesSync());
                    final http.Response response = await http.put(url,
                        headers: {HttpHeaders.authorizationHeader: token},
                        body: {"image": base64Image, "fileName": fileName});
                    print("Response");
                    print(response.body);
                    checkResponseStatus(response, context);
                    await saveValue("userProfileImagePath", croppedImageSaved.path);
                    setState(() {
                      _image = croppedImageSaved;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton.icon(
                  label: Text("No"),
                  icon: Icon(
                    FontAwesomeIcons.timesCircle,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    //come prima
                    String base64Image = base64Encode(image.readAsBytesSync());
                    final http.Response response = await http.put(url,
                        headers: {HttpHeaders.authorizationHeader: token},
                        body: {"image": base64Image, "fileName": fileName});
                    print("Response");
                    print(response.body);
                    checkResponseStatus(response, context);
                    if (response.statusCode == 201) {
                      print('Ok');
                      Directory appDir =
                          await getApplicationDocumentsDirectory();
                      File newImage = new File(appDir.path +
                          "/" +
                          "userProfileImage" +
                          "/" +
                          fileName);
                      newImage.createSync(recursive: true);
                      newImage.writeAsBytesSync(image.readAsBytesSync());
                      saveValue("userProfileImagePath", newImage.path);
                    } else {
                      //_showError();
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
    //Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ImageCropperScreen()));
  }

  void _getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.toString());
    /*
    Directory appDir = await getApplicationDocumentsDirectory();
    var path = appDir.path;
    //File savedImage = await image.copy(image.path);
    */
    var url = getUrlHome() + "saveImage";
    print("Path" + image.path);
    String token = await getToken();
    final http.Response response = await http.put(url,
        headers: {HttpHeaders.authorizationHeader: token},
        body: {"imagePath": "${image.path}"});
    print(response.statusCode);
    checkResponseStatus(response, context);
    if (response.statusCode == 201) {
      Directory appDir = await getApplicationDocumentsDirectory();
      File newImage = new File(appDir.path +
          "/" +
          "userProfileImage" +
          "/" +
          path.basename(image.path));
      newImage.createSync();
      newImage.writeAsBytesSync(image.readAsBytesSync());
      saveValue("userProfileImagePath", newImage.path);
      setState(() {
        print("Okk");
        _image = image;
      });
    } else {
      //_showError();
    }
  }

  Future<File> getImage() async {
    File image = await _getImageFromLocalStorage();
    if (image == null) {
      image = await _getImageFromPath();
    }
    return image;
  }

  Future<File> _getImageFromLocalStorage() async {
    String imagePath = await getValue('userProfileImagePath');
    File image = null;
    if (imagePath != null) {
      image = File(imagePath);
    }
    return image;
  }

  Future<File> _getImageFromPath() async {
    /*
    final String key = "imagePath";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString(key);
    File image = File(path);
    return image;
    */
    String token = await _getToken();
    var url = getUrlHome() + "getImage";
    final http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token});
    checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        //var jsonBody = json.decode(response.body);
        print(response.bodyBytes);
        Directory d = await getApplicationDocumentsDirectory();
        File image = new File(d.path +
            "/myProfileImage"); // File.fromRawPath(response.bodyBytes);
        image.writeAsBytesSync(response.bodyBytes);
        saveValue("userProfileImagePath", image.path);
        if (image != null) {
          return image;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserInfo().then((user) {
      print(user.toString());
      setState(() {
        _user = user;
        _user.name == null
            ? _nameController.text = "Nessun nome"
            : _nameController.text = _user.name;
        _user.surname == null
            ? _surnameController.text = "Nessun cognome"
            : _surnameController.text = _user.surname;
      });
      getImage().then((image) {
        print("GetIm");
        if (image != null) {
          setState(() {
            _image = image;
            _waitingResp = false;
            print("Fatto");
          });
        } else {
          /*rootBundle.load('assets/images/profilePicture.png').then((byte){
          getTemporaryDirectory().then((directory) {
            File tmp = new File(directory.path + '/profilePicture.png');
            _image = tmp;*/

          //print(tmp.path);
          //print(directory.path);
          print("fatto due");
          setState(() {
            defaultImage = true;
            _waitingResp = false;
          });
          //});

          //});

        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _waitingResp == true
        ? Center(
            child: SpinKitPouringHourglass(color: Colors.white, size: 50.0))
        : Scaffold(
            appBar: AppBar(
              title: Text("Profilo",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Avenir Next',
                      fontSize: 20)),
              backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
              bottom: PreferredSize(
                child: Container(color: Colors.yellow, height: 2),
                preferredSize: Size.fromHeight(2),
              ),
            ),
            body: ListView(shrinkWrap: true, children: <Widget>[
              Container(
                color: Color.fromRGBO(25, 25, 25, 1.0),

                alignment: Alignment.center,
                //height: 900,
                //padding: EdgeInsets.fromLTRB(0, 50.0, 3.0, 190.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20.0,
                          ),
                          //_image == null
                          /*defaultImage == true
                            ? Container(
                                padding: EdgeInsets.all(0.0),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "Non è stata selezionata alcuna immagine",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          onPressed: _getImageFromCamera,
                                          tooltip:
                                              'Scatta una foto dalla fotocamera',
                                          child: Icon(Icons.camera_alt,
                                              color: Colors.black),
                                          heroTag: "bottCam",
                                        ),
                                        SizedBox(
                                          width: 12.0,
                                        ),
                                        FloatingActionButton(
                                          backgroundColor: Colors.white,
                                          onPressed: _getImageFromGallery,
                                          tooltip:
                                              'Scegli un\'immagine dalla galleria',
                                          child: Icon(Icons.camera,
                                              color: Colors.black),
                                          heroTag: "bottGall",
                                        ),
                                      ],
                                    )
                                  ],
                                ))
                            :*/
                          Stack(
                            children: <Widget>[
                              Container(
                                child: defaultImage == true
                                    ? Image.asset(
                                        "assets/images/profilePicture.png",
                                        height: 150,
                                        width: 150)
                                    : GestureDetector(
                                      child: Image.file(
                                        _image,
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 150,
                                      ),
                                      onTap: () {
                                                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => PhotoViewScreen(data: _image.readAsBytesSync())));
                                      },
                                    ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Padding(
                                  padding: EdgeInsets.all(0),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white,
                                    onPressed: _getImageFromCamera,
                                    tooltip: 'Scatta una foto dalla fotocamera',
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.black),
                                    heroTag: "bottCam",
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(0),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      onPressed: _getImageFromGallery,
                                      tooltip:
                                          'Scegli un\'immagine dalla galleria',
                                      child: Icon(Icons.camera,
                                          color: Colors.black),
                                      heroTag: "bottGall",
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      /*margin: EdgeInsets.fromLTRB(35, 50, 40, 0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, style: BorderStyle.solid, width: 2)*/

                      child: Column(
                        children: <Widget>[
                          /*ClipPath(
                          child: Container(
                           color: Colors.red,
                            height: 40.0,
                            margin: EdgeInsets.fromLTRB(0, 0, 40, 0),
                            //color: Color.fromRGBO(25, 25, 25, 1.0),
                          ),
                          clipper: WaveClipperOne(reverse: true, )
                        ),*/
                          Container(
                            height: 520,
                            //color: Color.fromRGBO(25, 25, 25, 1.0),

                            /*decoration: BoxDecoration(
                            border: Border.all(color: Colors.yellow),

                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(60), topRight: Radius.circular(60))
                            //color: Color.fromRGBO(25, 25, 25, 1.0),
                            //border: Border(top: BorderSide(color: Colors.yellow, style: BorderStyle.solid, width: 2), 
                            //bottom: BorderSide(color: Colors.yellow, style: BorderStyle.solid, width: 2), 
                            //right: BorderSide(color: Colors.yellow, style: BorderStyle.solid, width: 2)),
                            //border: Border(top: BorderSide(color: Colors.yellow, style: BorderStyle.solid)),
                            //
                            //borderRadius: BorderRadius.only(bottomRight: Radius.circular(60), topRight: Radius.circular(60))
                            
                          ),*/

                            margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: TextFormField(
                                    initialValue: _user.username,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Avenir Next',
                                        fontSize: 20.0),
                                    enabled: true,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38)),
                                      labelText: "Username",
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Avenir Next"),
                                      prefixIcon: Icon(
                                        FontAwesomeIcons.user,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(FontAwesomeIcons.pencilAlt,
                                            size: 25),
                                        onPressed: () => {},
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: TextFormField(
                                    initialValue: _user.email,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Avenir Next',
                                        fontSize: 20.0),
                                    enabled: true,
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38)),
                                        labelText: "Email",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir Next"),
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.envelope,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(FontAwesomeIcons.pencilAlt,
                                              size: 25),
                                          onPressed: () => {},
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                                Container(
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: _focusName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Avenir Next',
                                        fontSize: 20.0),
                                    enabled: true,
                                    //readOnly: _nameFieldReadOnly,
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38)),
                                        labelText: "Nome",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir Next"),
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.user,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(FontAwesomeIcons.pencilAlt,
                                              size: 25),
                                          tooltip: "Cambia il nome",
                                          onPressed: () {
                                            print("Tap edit");
                                            _nameFieldReadOnly = false;
                                            FocusScope.of(context)
                                                .requestFocus(_focusName);
                                          },
                                          color: Colors.white,
                                        )),
                                    onEditingComplete: () async {
                                      String url =
                                          getUrlHome() + "profile/updateName";
                                      String token = await getToken();
                                      http.put(url, headers: {
                                        HttpHeaders.authorizationHeader: token
                                      }, body: {
                                        "name": _nameController.text
                                      }).then((response) {
                                        print(response);
                                        if (response.statusCode == 201) {
                                          setState(() {
                                            _nameFieldReadOnly = true;
                                            FocusScope.of(context).unfocus();
                                          });
                                        } else {
                                          //show error
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  child: TextField(
                                    controller: _surnameController,
                                    focusNode: _focusSurname,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Avenir Next',
                                        fontSize: 20.0),
                                    enabled: true,
                                    //readOnly: _nameFieldReadOnly,
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38)),
                                        labelText: "Cognome",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir Next"),
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.user,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(FontAwesomeIcons.pencilAlt,
                                              size: 25),
                                          tooltip: "Cambia il cognome",
                                          onPressed: () {
                                            print("Tap edit");
                                            //_nameFieldReadOnly = false;
                                            FocusScope.of(context)
                                                .requestFocus(_focusSurname);
                                          },
                                          color: Colors.white,
                                        )),
                                    onEditingComplete: () async {
                                      String url = getUrlHome() +
                                          "profile/updateSurname";
                                      String token = await getToken();
                                      http.put(url, headers: {
                                        HttpHeaders.authorizationHeader: token
                                      }, body: {
                                        "surname": _surnameController.text
                                      }).then((response) {
                                        print(response);
                                        if (response.statusCode == 201) {
                                          setState(() {
                                            //_nameFieldReadOnly = true;
                                            FocusScope.of(context).unfocus();
                                          });
                                        } else {
                                          //show error
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  child: TextFormField(
                                      initialValue: _user.courseStudy,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 20.0),
                                      enabled: true,
                                      decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black38)),
                                          labelText: "Corso di studi",
                                          labelStyle: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Avenir Next"),
                                          prefixIcon: Icon(
                                            FontAwesomeIcons.userGraduate,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                                FontAwesomeIcons.pencilAlt,
                                                size: 25,
                                                color: Colors.white),
                                            onPressed: () {
                                              //TODO
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChangeCourseOfStudyScreen()));
                                            },
                                          ))),
                                ),
                                Container(
                                  child: TextFormField(
                                      initialValue: _user.courseType,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 20.0),
                                      enabled: true,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black38)),
                                        labelText: "Tipo di corso",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir Next"),
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.userGraduate,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      )),
                                ),
                                Container(
                                  child: TextFormField(
                                      initialValue: _user.courseAddress,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir Next',
                                          fontSize: 20.0),
                                      enabled: true,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        labelText: "Indirizzo",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir Next"),
                                        prefixIcon: Icon(
                                          FontAwesomeIcons.userGraduate,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                                side: BorderSide(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 2)),
                            child: Text("Visualizza i tuoi interessi",
                                style: TextStyle(
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20,
                                    color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => InterestsScreen()));
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                                side: BorderSide(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 2)),
                            child: Text("Esporta i tuoi dati",
                                style: TextStyle(
                                    fontFamily: 'Avenir Next',
                                    fontSize: 20,
                                    color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ExportUserDataScreen()));
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]));
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mio Profilo'),
        backgroundColor: myColor.appbarCol2,
      ),
      backgroundColor: myColor.scaffoldCol2,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FutureBuilder(
            future: _getImageFromPath(),
            builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  _image = snapshot.data;
                } else {
                  _image = null;
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (_image != null) {
                return Image.file(
                  _image,
                  height: 300,
                  width: 300,
                );
              } else {
                return Text("Nessuna immagine selezionata");
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _getImageFromCamera,
                tooltip: 'Scatta una foto dalla fotocamera',
                child: Icon(Icons.camera_alt),
                heroTag: "bottCam",
              ),
              FloatingActionButton(
                onPressed: _getImageFromGallery,
                tooltip: 'Scegli un\'immagine dalla galleria',
                child: Icon(Icons.camera),
                heroTag: "bottGall",
              )
            ],
          ),
          FutureBuilder(
            future: getUserInfo(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.connectionState == ConnectionState.done) {
                if(snapshot.hasData){
                  _user = snapshot.data;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Username: " + _user.username, style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),),
                      Text("Nome: " + _user.name, style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),),
                      Text("Cognome: " + _user.surname, style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),),
                      Text("Email: " + _user.email, style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),),
                      Text("Rating: " + _user.rating + "%", style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),),
                      Text("Corso di studi: " + _user.courseStudy, style: TextStyle(fontSize: 18.0,
                              color: Colors.white70,
                              fontFamily: 'Avenir Next'),)
                    ],
                  );
                }else {
                  _showError();
                }
              }else{
                return CircularProgressIndicator();
              }
            },
          )
          //TODO: Implementare il cambia password
        ],
      ),
    );
  }*/
}
