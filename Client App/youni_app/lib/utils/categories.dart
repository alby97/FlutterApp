import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:youni_app/utils/utility.dart';

import 'package:http/http.dart' as http;


class Category {
  final String name;

  Category(this.name);

  String toString() {
    return name;
  }

  Category.fromJson(Map<String, dynamic> json):
  name = json['name'];

  @override
  bool operator ==(Object other) => other is Category && other.name == this.name;

  @override
  int get hashCode => name.hashCode;

}


Future<List> getCategories() async {
    String token = await getToken();
    String url = getUrlHome()+'getCategories';
    http.Response response = await http.get(url, headers: {HttpHeaders.authorizationHeader : token});
    List l = json.decode(response.body)['categories'];
   // print(m);
    return l;
  }
List<Category> createCategoriesList(List<dynamic> jsonList) {
    List<Category> tmp = new List<Category>();
    for(int i = 0; i < jsonList.length; i++){
      tmp.add(Category.fromJson(jsonList[i]));
    }
    return tmp;
  }
