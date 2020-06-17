import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';


class PhotoViewScreen extends StatefulWidget {
  
  final Uint8List data;

  PhotoViewScreen({this.data});

  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState(data: data);
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  
  final Uint8List data;

  _PhotoViewScreenState({this.data});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PhotoView(
          imageProvider: MemoryImage(data),
          loadingChild: SpinKitCircle(
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ),

    );
  }
}