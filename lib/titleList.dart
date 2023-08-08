import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'adsUnits.dart';
import 'global.dart';
import 'textReading.dart';


class TitleList extends StatefulWidget {
  final pageTitle;
  TitleList(this.pageTitle);

  @override
  State<StatefulWidget> createState() {
    return TitleListState(pageTitle);
  }
}

class TitleListState extends State<TitleList> {
  final pageTitle;

  TitleListState(this.pageTitle);

  static ValueNotifier adNotifier = ValueNotifier(0);
  AdsUnits adsUnits = AdsUnits();
  var ctx;



  @override
  void initState() {
    adsUnits.loadBanner2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    //adsUnits.loadAds();
    return Scaffold(
        backgroundColor: Global.canvasColor(),
        appBar: AppBar(backgroundColor: Colors.lightBlueAccent,

          iconTheme: IconThemeData(color: Colors.white),
          //  elevation: 0,
          title: Text(
            pageTitle,
            style: TextStyle(color: Colors.white),
          ),
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
                Expanded(flex: 0, child: adsUnits.googleBannerAd2()),
                Expanded(
                    flex: 1,
                    child: FutureBuilder(
                        future: Global.loadingZipFromAssets(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List titles = Global.titles[pageTitle]['textTitles'][Global.settings['language']];
                            List englishTitles = Global.titles[pageTitle]['textTitles']['english'];
                            return Container(
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                                //  maxCrossAxisExtent: 150,
                                //crossAxisCount: 2,
                                shrinkWrap: true,
                                children: [
                                  for (int i = 0; i < titles.length; i++)
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TextReading(
                                                        titles[i], englishTitles[i].toLowerCase().replaceAll(' upanishad', '').replaceAll(' ', '_')),
                                              ));
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                            child: Wrap(
                                              alignment: WrapAlignment.start,
                                              children: [
                                                Image.asset(
                                                  Global.listOfChakraImage[Random().nextInt(6)],
                                                  height: 50,
                                                  width: 50,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                                  child: Text(titles[i].toString().capitalizeFirstofEach,
                                                      style: TextStyle(fontSize: titles[i].toString().length >23 ? 15 : titles.length > 6 ? 20 : 28, fontWeight: FontWeight.w600, color: Global.normalTextColor())),
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
                        }))
              ],
            )
          ],
        ));
  }
}
