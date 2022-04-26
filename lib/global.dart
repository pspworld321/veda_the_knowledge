import 'dart:io';
import 'dart:ui';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'convertData.dart';

class Global {
  static var settings = {};

  static loadInitData() async {
    var box = await Hive.openBox('settings');
    // await box.clear();
    settings = box.toMap();
    if (settings.isEmpty) {
      settings['language'] = language[0];
      Global.settings['translateLanguage'] = language[2];
      Global.settings['gTransLangCode'] = 'hi';
      settings['theme'] = 'light';
      settings['textFontSize'] = 18.0;
      settings['loadingVedaFromAssets'] = 'notDone';
      saveSettings();
    }
  }

  static loadingVedaFromAssets() async {
    if (settings['loadingVedaFromAssets'] == 'notDone') {
      final byteData = await rootBundle.load("assets/veda.zip");
      final archive =
          ZipDecoder().decodeBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File((await getApplicationDocumentsDirectory()).path + '/hive/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory((await getApplicationDocumentsDirectory()).path + '/hive/' + filename)..create(recursive: true);
        }
      }
      settings['loadingVedaFromAssets'] = 'done';
      saveSettings();
    }
    return 'done';
  }

  static getDataDirectoryPath() async {
    if (Platform.isAndroid) {
      var directory = await getApplicationSupportDirectory();
      return directory.path;
    } else if (Platform.isWindows) {
      var directory = await getApplicationSupportDirectory();
      return directory.path;
    }
  }

  static saveSettings() async {
    var box = await Hive.openBox('settings');
    box.clear();
    box.putAll(settings);
    print(settings);
  }

  static bookmarkColor() {
    if (settings['theme'] == 'dark') {
      return Colors.lightBlueAccent;
    } else {
      return Colors.blue;
    }
  }

  static canvasColor() {
    if (settings['theme'] == 'dark') {
      return Color.fromRGBO(45, 45, 45, 1.0);
    } else {
      return Color.fromRGBO(253, 253, 253, 1.0);
    }
  }

  static normalTextColor() {
    if (settings['theme'] == 'dark') {
      return Color.fromRGBO(245, 245, 245, 1.0);
    } else {
      return Colors.black87;
    }
  }

  static List language = ['english', 'hindi', 'sanskrit'];

  static Map languageTitleMapGita = {
    'english': 'Bhagvad Gita',
    'hindi': 'श्रीमद्भगवद्‌गीता',
    'sanskrit': 'श्रीमद्भगवद्‌गीता'
  };

  static String gitaTitle() {
    return languageTitleMapGita[settings['language']];
  }

  static Map languageTitleMapUpanishad = {
    'english': 'Upanishad',
    'hindi': 'उपनिषद्',
    'sanskrit': 'उपनिषद्'
  };

  static String upanishadTitle() {
    return languageTitleMapUpanishad[settings['language']];
  }

  static Map languageVedaMap = {
    'english': ['rigveda', 'yajurveda', 'samaveda', 'atharvaveda'],
    'hindi': ['ऋग्वेद', 'यजुर्वेद', 'सामवेद', 'अथर्ववेद'],
    'sanskrit': ['ऋग्वेद:', 'यजुर्वेद:', 'सामवेद:', 'अथर्ववेद:']
  };

  static List veda() {
    return languageVedaMap[settings['language']];
  }

  static List listOfChakraImage = [
    'assets/images/AgyaChakra.png',
    'assets/images/VishudhhiChakra.png',
    'assets/images/HeartChakra.png',
    'assets/images/ManipurChakra.png',
    'assets/images/SacralChakra.png',
    'assets/images/RootChakra.png'
  ];

  static gTransWarningText() {
    Map text = {
      'hindi':
          'यह अनुवाद गूगल ट्रांसलेशन का उपयोग करता है, यह अनुवाद गलतियों और संदिग्धता से भरा हो सकता है, कृपया इसे गंभीरता से ना लें',
      'english':
          'This translation will be machine generated from google translation service.It may be confusing and erroneous. Please do not take it seriously... '
    };
    return text[settings['language']];
  }
}

extension CapExtension on String {
  String get inCaps => this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}' : '';

  String get allInCaps => this.toUpperCase();

  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
