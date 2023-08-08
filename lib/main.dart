import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:veda/textReading.dart';

import 'adsUnits.dart';
import 'global.dart';
import 'titleList.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path + '/hive/');
  //await ConvertData.convert();
  await Global.loadInitData();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vedic Wisdom',
      theme: ThemeData(primaryColor: Colors.lightBlueAccent),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  MyHomePageState();

  static ValueNotifier adNotifier = ValueNotifier(0);
  AdsUnits adsUnits = AdsUnits();
  var ctx;

  languageDialog() {
    showDialog(
        builder: (BuildContext cntxt) {
          return Dialog(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (String item in Global.language)
                  ListTile(
                    onTap: () {
                      Global.settings['language'] = item;
                      print(Global.settings);
                      Global.saveSettings();
                      Navigator.pop(cntxt);
                      setState(() {});
                    },
                    title: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        item.toString().capitalizeFirstofEach,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
        context: ctx);
  }

  @override
  void initState() {
    super.initState();
    adsUnits.loadAds();
  }

  menuDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext cntxt) {
        return Dialog(
            insetPadding: EdgeInsets.fromLTRB(30, 50, 30, 30),
            child: ListView(
              shrinkWrap: true,
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.lightBlueAccent,
                      padding: EdgeInsets.fromLTRB(20, 25, 30, 20),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(children: [Image.asset(
                                    'assets/images/bluestone.png',
                                    width: 45,
                                    height: 45,
                                  ),
                                    Text(
                                      '  Blue Stone Studio',
                                      style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.start,
                                    )
                                  ])))
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/randomBack/${Random().nextInt(12).toString()}.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ],
                ),
                for (int j = 0; j < Global.titles['More...'].length; j++)
                  ListTile(
                    onTap: () {
                      // launchUrlString(Global.titles['More...'].values.toList()[j][0]);
                      launchUrl(Uri.parse(Global.titles['More...'].values.toList()[j][0]), mode: LaunchMode.externalApplication);
                    },
                    leading: Image.asset(
                      Global.titles['More...'].values.toList()[j][1],
                      height: 35,
                      width: 35,
                    ),
                    title: Text(Global.titles['More...'].keys.toList()[j]),
                    subtitle: Text(Global.titles['More...'].values.toList()[j][0], style: TextStyle(fontSize: 9)),
                  ),
                Container(
                    decoration: BoxDecoration(
                        //  color: Colors.green,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0))),
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(cntxt);
                                  launchUrlString("https://play.google.com/store/apps/developer?id=Blue+Stone+Studio");
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.apps,
                                      size: 28,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(
                                          'More Apps',
                                          style: TextStyle(fontSize: 12.0, color: Colors.black87),
                                        ))
                                  ],
                                )),
                            Spacer(),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(cntxt);
                                  launchUrlString("https://play.google.com/store/apps/details?id=com.totp.veda");
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 28,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(
                                          'Rate this app',
                                          style: TextStyle(fontSize: 12.0, color: Colors.black87),
                                        ))
                                  ],
                                )),
                            Spacer(),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(cntxt);
                                  Share.share(
                                      'Hey! Checkout this App.\nVeda, Upanishad & Geeta and more.. in three languages.\n\n'
                                      'https://play.google.com/store/apps/details?id=com.totp.veda',
                                      subject: 'Vedic Wisdom');
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.share,
                                      size: 27,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                                        child: Text(
                                          'Share this App',
                                          style: TextStyle(fontSize: 12.0, color: Colors.black87),
                                        ))
                                  ],
                                )),
                          ],
                        ))),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
        backgroundColor: Global.canvasColor(),
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          // leading: TextButton(
          //     onPressed: () {
          //       menuDialog(context);
          //     },
          //     child: Padding(
          //         padding: EdgeInsets.fromLTRB(15, 2, 0, 0),
          //         child: Icon(
          //           Icons.menu,
          //           size: 25,
          //           color: Colors.white,
          //         ))),
          iconTheme: IconThemeData(color: Colors.white),
          //  elevation: 0,
          title: Text(
            'Vedic Wisdom',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  languageDialog();
                },
                icon: Icon(Icons.translate, color: Colors.white)),
            IconButton(
                onPressed: () {
                  if (Global.settings['theme'] == 'dark') {
                    Global.settings['theme'] = 'light';
                  } else {
                    Global.settings['theme'] = 'dark';
                  }
                  Global.saveSettings();
                  setState(() {});
                },
                icon: Icon(Global.settings['theme'] == 'dark' ? Icons.wb_sunny : Icons.nights_stay, color: Colors.white))
          ],
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/treebranch_background.png',
                height: 100,
                width: 150,
                fit: BoxFit.fill,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/images/yogi_background.png',
                height: 270,
                width: 171,
              ),
            ),
            Flex(
              direction: Axis.vertical,
              children: [
                Expanded(flex: 0, child: adsUnits.googleBannerAd1()),
                Expanded(
                    flex: 1,
                    child: Container(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                        //  maxCrossAxisExtent: 150,
                        //crossAxisCount: 2,
                        shrinkWrap: true,
                        children: [
                          for (int i = 0; i < Global.titles.length; i++)
                            Global.titles.keys.toList()[i] == 'More...'
                                ? GestureDetector(
                                    onTap: () {
                                      menuDialog(context);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          children: [
                                            Image.asset(
                                              Global.listOfChakraImage[i + 2],
                                              height: 50,
                                              width: 50,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                              child: Text(Global.titles.keys.toList()[i].toString().capitalizeFirstofEach,
                                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Global.normalTextColor())),
                                            )
                                          ],
                                        )))
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TitleList(Global.titles.keys.toList()[i]),
                                          )).then((value) {
                                        adsUnits.showInterAd();
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          children: [
                                            Image.asset(
                                              Global.listOfChakraImage[i + 2],
                                              height: 50,
                                              width: 50,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                              child: Text(
                                                  Global.titles[Global.titles.keys.toList()[i]]['mainTitle'][Global.settings['language']]
                                                      .toString()
                                                      .capitalizeFirstofEach,
                                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Global.normalTextColor())),
                                            )
                                          ],
                                        )))
                        ],
                      ),
                    )),
              ],
            )
          ],
        ));
  }
}
