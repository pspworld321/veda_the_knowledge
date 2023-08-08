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
      // settings['loadingVedaFromAssets'] = 'notDone';
      saveSettings();
    }
  }

  static List assetsZip = ['geeta', 'upanishad', 'veda'];

  static loadingZipFromAssets() async {
    for (String zipName in assetsZip) {
      if (settings['loading${zipName.capitalizeFirstofEach}FromAssets'] == null) {
        final byteData = await rootBundle.load("assets/$zipName.zip");
        final archive = ZipDecoder().decodeBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
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
        settings['loading${zipName.capitalizeFirstofEach}FromAssets'] = 'done';
        saveSettings();
      }
    }
    return 'done';
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

  static Map titles = {
    'Geeta': {
      'mainTitle': {'english': 'Geeta', 'hindi': 'गीता', 'sanskrit': '‌गीता'},
      'textTitles': {
        'english': ['Ashtavakra Geeta', 'Bhagavata Geeta'],
        'hindi': ['अष्टावक्र गीता', 'श्रीमद्भगवद्‌गीता'],
        'sanskrit': ['अष्टावक्र गीता', 'श्रीमद्भगवद्‌गीता']
      }
    },
    'Upanishad': {
      'mainTitle': {'english': 'Upanishad', 'hindi': 'उपनिषद्', 'sanskrit': 'उपनिषद्'},
      'textTitles': {
        'english': [
          'Ishavasya Upanishad',
          'Kena Upanishad',
          'Katha Upanishad',
          'Aitareya Upanishad',
          'Taittiriya Upanishad',
          'Mundaka Upanishad',
          'Mandukya Upanishad',
          'Prashna Upanishad',
          'Shvetashvatara Upanishad',
          'Chhandogya Upanishad',
          'Brihdaranyaka Upanishad',
          'Adhyatma Upanishad',
          'Adwayataraka Upanishad',
          'Akshamalika Upanishad',
          'Akshi Upanishad',
          'Amritbindu Upanishad',
          'Amritnada Upanishad',
          'Arunika Upanishad',
          'Atharvashiras Upanishad',
          'Atma Upanishad',
          'Atmabodha Upanishad',
          'Avadhuta Upanishad',
          'Bahvricha Upanishad',
          'Bhikshuka Upanishad',
          'Brahmavidya Upanishad',
          'Devi Upanishad',
          'Dhyanabindu Upanishad',
          'Ekakshara Upanishad',
          'Ganapati Upanishad',
          'Garbha Upanishad',
          'Yogatattva Upanishad',
          'Jaabaal Upanishad',
          'Sanyasa Upanishad',
          'Mahavakya Upanishad',
          'Niralamba Upanishad',
          'Tripura Upanishad',
          'Kshurika Upanishad',
          'Kaivalya Upanishad',
          'Kaushitaki Upanishad',
          'Skanda Upanishad',
          'Katharudra Upanishad',
          'Naadbindu Upanishad',
          'Yogakundalini Upanishad',
          'Mandalabrahmana Upanishad',
          'Nirvana Upanishad',
          'Kalisantarana Upanishad',
          'Narayana Upanishad',
          'Kalagnirudra Upanishad',
          'Mudgala Upanishad',
          'Parabrahma Upanishad',
          'Kundika Upanishad',
          'Paingala Upanishad',
          'Paramahansaparivrajaka Upanishad',
          'Maitreya Upanishad',
          'Paramahansa Upanishad',
          'Yagyavalkya Upanishad',
          'Sita Upanishad',
          'Vajrasuchika Upanishad',
          'Turiyateeta Upanishad',
          'Sarvasara Upanishad'
        ],
        'hindi': [
          'ईशावास्य उपनिषद',
          'केन उपनिषद',
          'कठ उपनिषद',
          'ऐतरेय उपनिषद',
          'तैत्तिरीय उपनिषद',
          'मुण्डक उपनिषद',
          'माण्डूक्य उपनिषद',
          'प्रश्न उपनिषद',
          'श्वेताश्वतर उपनिषद',
          'छान्दोग्य उपनिषद',
          'बृहदारण्यक उपनिषद',
          'अध्यात्म उपनिषद',
          'अद्वयतारक उपनिषद',
          'अक्षमालिका उपनिषद',
          'अक्षि उपनिषद',
          'अमृतबिन्दु उपनिषद',
          'अमृतनाद उपनिषद',
          'आरुणिक उपनिषद',
          'अथर्वशिरस उपनिषद',
          'आत्म उपनिषद',
          'आत्मबोध उपनिषद',
          'अवधूत उपनिषद',
          'बह्वृच उपनिषद',
          'भिक्षुक उपनिषद',
          'ब्रह्मविद्या उपनिषद',
          'देवी उपनिषद',
          'ध्यानबिन्दु उपनिषद',
          'एकाक्षर उपनिषद',
          'गणपति उपनिषद',
          'गर्भ उपनिषद',
          'योगतत्त्व उपनिषद',
          'जाबाल उपनिषद',
          'संन्यास उपनिषद',
          'महावाक्य उपनिषद',
          'निरालम्ब उपनिषद',
          'त्रिपुर उपनिषद',
          'क्षुरिका उपनिषद',
          'कैवल्य उपनिषद',
          'कौषीतकि उपनिषद',
          'स्कन्द उपनिषद',
          'कठरूद्र उपनिषद',
          'नादबिन्दु उपनिषद',
          'योगकुण्डलिनी उपनिषद',
          'मण्डलब्राह्मण उपनिषद',
          'निर्वाण उपनिषद',
          'कलिसंतरण उपनिषद',
          'नारायण उपनिषद',
          'कालाग्निरुद्र उपनिषद',
          'मुद्गल उपनिषद',
          'परब्रह्म उपनिषद',
          'कुण्डिका उपनिषद',
          'पैङ्गल उपनिषद',
          'परमहंसपरिव्राजक उपनिषद',
          'मैत्रेय उपनिषद',
          'परमहंस उपनिषद',
          'याज्ञवल्क्य उपनिषद',
          'सीता उपनिषद',
          'वज्रसूचिका उपनिषद',
          'तुरीयातीत उपनिषद',
          'सर्वसार उपनिषद'
        ],
        'sanskrit': [
          'ईशावास्योपनिषद्',
          'केनोपनिषद्',
          'कठोपनिषद्',
          'ऐतरेयोपनिषद्',
          'तैत्तिरीयोपनिषद्',
          'मुण्डकोपनिषद्',
          'माण्डूक्योपनिषद्',
          'प्रश्नोपनिषद्',
          'श्वेताश्वतरोपनिषद्',
          'छान्दोग्योपनिषद्',
          'बृहदारण्यकोपनिषद्',
          'अध्यात्मोपनिषद',
          'अद्वयतारकोपनिषद्',
          'अक्षमालिकोपनिषद्',
          'अक्ष्युपनिषद्',
          'अमृतबिन्दूपनिषद्',
          'अमृतनादोपनिषद्',
          'आरुणिकोपनिषद्',
          'अथर्वशिरसोपनिषद्',
          'आत्मोपनिषद्',
          'आत्मबोधोपनिषद्',
          'अवधूतोपनिषद्',
          'बह्वृचोपनिषद्',
          'भिक्षुकोपनिषद्',
          'ब्रह्मविद्योपनिषद्',
          'देव्युपनिषद्',
          'ध्यानबिन्दूपनिषद्',
          'एकाक्षरोपनिषद्',
          'गणपत्युपनिषद्',
          'गर्भोपनिषद्',
          'योगतत्त्वोपनिषद्',
          'जाबालोपनिषद्',
          'संन्यासोपनिषद्',
          'महावाक्योपनिषद्',
          'निरालम्बोपनिषद्',
          'त्रिपुरोपनिषद्',
          'क्षुरिकोपनिषद्',
          'कैवल्योपनिषद्',
          'कौषीतकिब्राह्मणोपनिषद्',
          'स्कन्दोपनिषद्',
          'कठरुद्रोपनिषद्',
          'नादबिन्दोपनिषद्',
          'योगकुण्डलिन्युपनिषद्',
          'मण्डलब्राह्मणोपनिषद्',
          'निर्वाणोपनिषद्',
          'कलिसंतरणोपनिषद्',
          'नारायणोपनिषद्',
          'कालाग्निरुद्रोपनिषद्',
          'मुद्गलोपनिषद्',
          'परब्रह्मोपनिषद्',
          'कुण्डिकोपनिषद्',
          'पैङ्गलोपनिषद्',
          'परमहंसपरिव्राजकोपनिषद्',
          'मैत्रेय्युपनिषद्',
          'परमहंसोपनिषद्',
          'याज्ञवल्क्योपनिषद्',
          'सीतोपनिषद्',
          'वज्रसूचिकोपनिषद्',
          'तुरीयातीतोपनिषद्',
          'सर्वसारोपनिषद्'
        ]
      }
    },
    'Veda': {
      'mainTitle': {'english': 'Veda', 'hindi': 'वेद', 'sanskrit': 'वेद'},
      'textTitles': {
        'english': ['rigveda', 'yajurveda', 'samaveda', 'atharvaveda'],
        'hindi': ['ऋग्वेद', 'यजुर्वेद', 'सामवेद', 'अथर्ववेद'],
        'sanskrit': ['ऋग्वेद:', 'यजुर्वेद:', 'सामवेद:', 'अथर्ववेद:']
      }
    },
    'More...': {
      'Youtube': ['https://www.youtube.com/@_BlueStoneStudio_','assets/images/youtube.png'],
      'Instagram': ['https://www.instagram.com/_thebluestone_','assets/images/instagram.png'],
      'Blog': ['https://the-blue-stone.blogspot.com/','assets/images/blogger.png']
    }
  };

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
      'hindi': 'यह अनुवाद गूगल ट्रांसलेशन का उपयोग करता है, यह अनुवाद गलतियों और संदिग्धता से भरा हो सकता है, कृपया इसे गंभीरता से ना लें',
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
