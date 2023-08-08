import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ConvertData {
  static convert() async {
    print('Converting  Started----------------');
    print(DateTime.now());
    List files = [];

    String path = (await getApplicationDocumentsDirectory()).path + '/allText/veda/';
    Directory dir = Directory(path);
    files = await dir.list().toList();
    for (int j = 0; j < files.length; j++) {
      if (p.extension(files[j].path) == '.txt') {
        List finalData = [];

        List dataList = await File(files[j].path).readAsLines();
        for (int i = 0; i < dataList.length; i++) {
          if (dataList[i].toString().contains('title1::')) {
            Map map = {'type': 'title1', 'data': dataList[i].toString().replaceAll('title1::', '').trim()};
            finalData.add(map);
          } else if (dataList[i].toString().contains('title2::')) {
            Map map = {'type': 'title2', 'data': dataList[i].toString().replaceAll('title2::', '').trim()};
            finalData.add(map);
          } else if (dataList[i].toString().contains('title3::')) {
            Map map = {'type': 'title3', 'data': dataList[i].toString().replaceAll('title3::', '').trim()};
            finalData.add(map);
          } else /*if (dataList[i].toString().contains('verse::'))*/ {
            Map map = {'type': 'verse', 'data': dataList[i].toString().replaceAll('verse::', '').trim()};
            finalData.add(map);
          }
        }
        var box = await Hive.openBox(p.basenameWithoutExtension(files[j].path));
        await box.clear();
        await box.addAll(finalData);
      }
    }

    print(DateTime.now());
    print('Converting  Finished----------------');
  }
}
