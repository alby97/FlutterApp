import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';


class MaterialTeachingFile {

  String nomeFile, descrizione, corsoDiStudi, 
  dipartimento, url, professore, annoAccademico,
  insegnamento, timestamp, author, authorName, authorSurname; //forse il timestamp va fatto di un altro tipo
  Uint8List data;
  String id;

  MaterialTeachingFile({this.nomeFile, this.descrizione, this.corsoDiStudi,
  this.dipartimento, this.url, this.professore, this.annoAccademico,
  this.insegnamento, this.timestamp, this.author, this.authorName, this.authorSurname, this.data});


  @override
  String toString() {
  return nomeFile + " " + descrizione + " " + corsoDiStudi + " " + dipartimento;
   }

   MaterialTeachingFile.fromJson(Map<String, dynamic> json):
   nomeFile = json["file_name"],
   descrizione = json["description"],
   corsoDiStudi = json["course_of_study"],
   dipartimento = json["department"],
   url = json["url"],
   professore = json["professor"],
   annoAccademico = json["academic_year"],
   insegnamento = json["teaching"],
   timestamp = json["timestamp"],
   author = json["author"],
   authorName = json["author_name"],
   authorSurname = json["author_surname"],
   id = json["id"];

  String toJson() {
    Map<String, dynamic> jsonMaterialTeachingFile = {
      'file_name' : nomeFile,
      'description' : descrizione,
      'course_of_study' : corsoDiStudi,
      'department' : dipartimento,
      'url' : url,
      'professor' : professore,
      'academic_year' : annoAccademico,
      'teaching' : insegnamento,
      'timestamp' : timestamp,
      'author' : author,
      'author_name' : authorName,
      'author_surname' : authorSurname,
      'data' : data
    };
    return json.encode(jsonMaterialTeachingFile);
  }


}