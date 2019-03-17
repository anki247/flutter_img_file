import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class FileUtil {

  static String _localPath = '';
  static Directory _directory = null;

  static void init () {
    getApplicationDocumentsDirectory().then((d) {
      _directory = d;
      _localPath = d.path;
    });
  }

  static void saveImg(File img, index) async {
    img.copySync('$_localPath/$index.jpg');
  }

  static void writeToFile(ByteData data, index) {
    final buffer = data.buffer;
    final path = '$_localPath/$index.jpg';
    print('--> save file $path');
    return new File(path).writeAsBytesSync(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static List<String> listImgs() {
    var imgList = _directory.listSync();
    imgList = imgList.where((p) => p.path.endsWith(".jpg")).toList();
    imgList.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    return imgList.map((e) =>  e.path).toList();
  }

  static int getLastFileCount() {
    var list = listImgs();

    if (list == null || list.length == 0) {
      return 0;
    }
    var count = list.last.split(Platform.pathSeparator).last.split('.').first;

    return int.parse(count);
  }

  static Future<List<File>> getImgsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.listSync().map((e) =>  e.path)
      .map((path) => File(path));
  }
}