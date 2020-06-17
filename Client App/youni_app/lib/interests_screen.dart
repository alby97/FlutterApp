import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youni_app/utils/categories.dart';
import 'package:youni_app/utils/errors.dart';
import 'package:youni_app/utils/firebaseMsgUtils.dart';
import 'package:youni_app/utils/utility.dart';
import 'package:http/http.dart' as http;

class InterestsScreen extends StatefulWidget {
  _InterestsScreenState createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  List<Category> categories;
  List<Category> userInterests;
  List<bool> checkBoxValues;

  Map<Category, bool> interestsCheckBoxValues;

  bool _done = false;

  @override
  void initState() {
    super.initState();
    getCategories().then((list) {
      categories = createCategoriesList(list);
      print(categories);
      interestsCheckBoxValues = new Map<Category, bool>();
      getUserInterests().then((val) {
        setState(() {
          _done = true;
        });
      });
    });
  }

  Future<void> getUserInterests() async {
    String token = await getToken();
    String url = getUrlHome() + "getUserInterests";
    List<Category> tmp = new List<Category>();
    checkBoxValues = new List<bool>();
    http.Response response =
        await http.get(url, headers: {HttpHeaders.authorizationHeader: token}); 
        checkResponseStatus(response, context);
    if (response.statusCode == 200) {
      print("JAJSJ");
      print(response.body);
      if(response.body != null && response.body.isNotEmpty) {
        List list = json.decode(response.body);
      //print(list);
      for (int i = 0; i < list.length; i++) {
        tmp.add(Category(list[i]));
      }
      }
      print(tmp);
      for (int i = 0; i < categories.length; i++) {
        print(categories.elementAt(i));
        if(tmp.contains(categories.elementAt(i))){
          print("True");
          interestsCheckBoxValues[categories.elementAt(i)] = true;
        }
        else {
          print("False");
          interestsCheckBoxValues[categories.elementAt(i)] = false;
        }
        
      }
      print(interestsCheckBoxValues);
    } else {
      //errore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: _done == false ? SpinKitPouringHourglass(
          color: Colors.white,
          size: 50.0,
        ) : ListView(
          children: categories
              .map((category) => CheckboxListTile(
                    value: interestsCheckBoxValues[category],
                    onChanged: (newValue) async {
                      if (newValue == true) {
                        //TODO: Bisogna aggiungerlo agli interessi
                        //TODO: Il setstate va fatto se va a buon fine l'operazione
                        String token = await getToken();
                        String url = getUrlHome() + "addUserInterest";
                        http.Response response = await http.post(url,
                            headers: {HttpHeaders.authorizationHeader: token},
                            body: {"interest": category.name});
                            checkResponseStatus(response, context);
                        if (response.statusCode == 201) {
                          String tmp = "CATEGORIA_"+ category.name;
                          tmp.replaceAll(new RegExp(' '), '_');
                          getInstance().subscribeToTopic(tmp);
                          setState(() {
                            //TODO: AGGIUNGERE SUBSCRIBE TOPIC
                            interestsCheckBoxValues[category] = newValue;
                          });
                        }
                        else {
                          //return errore
                        }
                      } else {
                        //TODO: Bisogna rimuoverlo dagli interessi
                        //TODO: Il setstate va fatto se va a buon fine l'operazione
                        String token = await getToken();
                        String url = getUrlHome() + "removeUserInterest";
                        http.Response response = await http.post(url,
                            headers: {HttpHeaders.authorizationHeader: token},
                            body: {"interest": category.name});
                            checkResponseStatus(response, context);
                        if(response.statusCode == 201) {
                          String tmp = "CATEGORIA_"+ category.name;
                          tmp.replaceAll(new RegExp(' '), '_');
                          getInstance().unsubscribeFromTopic(tmp);
                          setState(() {
                            //TODO: AGGIUNGI UNSUBSCRIBETOPIC
                          interestsCheckBoxValues[category] = newValue;
                        });
                        }
                        else {
                          //errore
                        }
                        
                      }
                    },
                    title: Text(
                      category.name,
                      style: TextStyle(fontFamily: 'Avenir Next'),
                    ),
                  ))
              .toList(),
        ));
  }
}
