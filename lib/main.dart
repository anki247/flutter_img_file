import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import './util/file_util.dart';

void main() async {
  FileUtil.init();
  Future.delayed(Duration(milliseconds: 500)).then((v) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(
        title: "Demo1",
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  final String title;

  MyHome({Key key, this.title}) : super(key: key) {}

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<String> _imgList = null;

  _MyHomeState() {
    _imgList = FileUtil.listImgs();
  }

  void _pickImgs() async {
    try {
      List<Asset> resultList = await MultiImagePicker.pickImages(
        maxImages: 30,
      );

      int count = FileUtil.getLastFileCount();
      print('--> start write img from $count');

      resultList.forEach((r) async {
          ByteData byteData = await r.requestOriginal();
          FileUtil.writeToFile(byteData, ++count);
          if (resultList.last == r) {
            setState(() {
              print('--> setState: load all imgs new');
              _imgList = FileUtil.listImgs();
            });
          }
      });

    } on PlatformException catch (e) {
      print('--> ' + e.message);
    }
  }

  _deleteImg(String path) {
    File(path).deleteSync();
    setState(() {
      print('--> img deleted -> setState: load all imgs new');
      _imgList = FileUtil.listImgs();
    });
  }

  Widget _buildItem(BuildContext context, int position) {
    return Container(
      padding: EdgeInsets.all(15),
      child: GestureDetector(
        onLongPress: () {
          _deleteImg(_imgList[position]);
        },
        child: Card(
          elevation: 10,
          child: Container(
            height: 250,
            padding: EdgeInsets.all(10),
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(
                File(_imgList[position]),
              ),
            )
          )
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: _imgList.length,
        itemBuilder: _buildItem,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImgs,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
