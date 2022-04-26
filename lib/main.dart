import 'dart:math';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veda/textReading.dart';

import 'adsUnits.dart';
import 'global.dart';

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
      title: 'Veda - Knowledge',
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
                      padding: EdgeInsets.fromLTRB(30, 25, 30, 20),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                      onPressed: null,
                                      child: Text(
                                        'The Knowledge',
                                        style:
                                        TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.start,
                                      ))))
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
                ListTile(
                  leading: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Icon(
                        Icons.star,
                        color: Colors.lightBlueAccent,
                        size: 32,
                      )),
                  title: Text(
                    'Rate this App',
                    style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text('Help us Make it Better'),
                  onTap: () async {
                    Navigator.pop(cntxt);
                    launch("https://play.google.com/store/apps/details?id=com.totp.veda");
                  },
                ),
                ListTile(
                  leading: Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Icon(
                        Icons.share,
                        color: Colors.lightBlueAccent,
                        size: 32,
                      )),
                  title: Text(
                    'Share this App',
                    style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  onTap: () async {
                    Navigator.pop(cntxt);
                    Share.share(
                        'Hey! Checkout this App.\nVeda, Upanishad & Gita in three languages.\n\n'
                            'https://play.google.com/store/apps/details?id=com.totp.veda',
                        subject: 'Bhagvad Gita');
                  },
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: ListTile(
                      leading: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Icon(
                            Icons.apps,
                            color: Colors.lightBlueAccent,
                            size: 30,
                          )),
                      title: Text(
                        'More Apps',
                        style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                      onTap: () async {
                        Navigator.pop(cntxt);
                        launch("https://play.google.com/store/apps/developer?id=Blue+Stone+Studio");
                      },
                    )),
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
        appBar: AppBar( leading: TextButton(
            onPressed: () {
              menuDialog(context);
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(15, 2, 0, 0),
                child: Icon(
                  Icons.menu,
                  size: 25,
                  color: Colors.white,
                ))),
          iconTheme: IconThemeData(color: Colors.white),
          //  elevation: 0,
          title: Text(
            'The Knowledge',
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
                icon:
                    Icon(Global.settings['theme'] == 'dark' ? Icons.wb_sunny : Icons.nights_stay, color: Colors.white))
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
                Expanded(
                    flex: 1,
                    child: FutureBuilder(
                        future: Global.loadingVedaFromAssets(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                                //  maxCrossAxisExtent: 150,
                                //crossAxisCount: 2,
                                shrinkWrap: true,
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        if (await DeviceApps.isAppInstalled('com.bss.gita')) {
                                          DeviceApps.openApp('com.bss.gita');
                                        } else {
                                          launch('https://play.google.com/store/apps/details?id=com.bss.gita');
                                        }
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            children: [
                                              Image.asset(
                                                Global.listOfChakraImage[0],
                                                height: 70,
                                                width: 70,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                                                child: Text(Global.gitaTitle(),
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        fontWeight: FontWeight.w600,
                                                        color: Global.normalTextColor())),
                                              )
                                            ],
                                          ))),
                                  GestureDetector(
                                      onTap: () async {
                                        if (await DeviceApps.isAppInstalled('com.bhartiyadarshan.upanishad')) {
                                          DeviceApps.openApp('com.bhartiyadarshan.upanishad');
                                        } else {
                                          launch(
                                              'https://play.google.com/store/apps/details?id=com.bhartiyadarshan.upanishad');
                                        }
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            children: [
                                              Image.asset(
                                                Global.listOfChakraImage[1],
                                                height: 50,
                                                width: 50,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                                child: Text(Global.upanishadTitle(),
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        fontWeight: FontWeight.w600,
                                                        color: Global.normalTextColor())),
                                              )
                                            ],
                                          ))),
                                  for (int indexOfText = 0; indexOfText < Global.veda().length; indexOfText++)
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TextReading(indexOfText),
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
                                                  Global.listOfChakraImage[indexOfText + 2],
                                                  height: 50,
                                                  width: 50,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                                  child: Text(
                                                      Global.veda()[indexOfText].toString().capitalizeFirstofEach,
                                                      style: TextStyle(
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.w600,
                                                          color: Global.normalTextColor())),
                                                )
                                              ],
                                            )))
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Column(
                                children: [Spacer(), CircularProgressIndicator(), Spacer()],
                              ),
                            );
                          }
                        })),
                Expanded(flex: 0, child: adsUnits.googleBannerAd())
              ],
            )
          ],
        ));
  }
}
