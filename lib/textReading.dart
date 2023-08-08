import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:translator/translator.dart';
import 'package:veda/gTranslate.dart';
import 'package:veda/global.dart';
import 'package:share/share.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'adsUnits.dart';

class TextReading extends StatefulWidget {
  final title;
  final nameEnglish;
  TextReading(this.title, this.nameEnglish);

  @override
  State<StatefulWidget> createState() {
    return TextReadingState(title,nameEnglish);
  }
}
class TextReadingState extends State<TextReading> {
  final title;
  final nameEnglish;

  TextReadingState(this.title, this.nameEnglish);

  static ValueNotifier adNotifier = ValueNotifier(0);
  AdsUnits adsUnits = AdsUnits();

  var ctx;
  var dataBox;
  var translateBox;
  Map bookmarks = {};
  Map index = {};
  FlutterTts flutterTts = FlutterTts();
  bool versePlaying = false;
  int versePlayingIndex = 0;
  int ttsStartOffset = 0;
  int ttsEndOffset = 0;
  var fontSize;
  var listNotifier = ValueNotifier(0);
  var translateNotifier = ValueNotifier(0);
  ItemScrollController scrollController = ItemScrollController();
  Color buttonsColor = Colors.lightBlueAccent;

  @override
  void initState() {
    adsUnits.loadBanner3();
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    this.ctx = ctx;
    fontSize = Global.settings['textFontSize'];
    return WillPopScope(
        onWillPop: () async {
          flutterTts.stop();
          return true;
        },
        child: Scaffold(
            backgroundColor: Global.canvasColor(),
            appBar: AppBar(backgroundColor: Colors.lightBlueAccent,
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                    onPressed: () {
                      bookmarksDialog();
                    },
                    icon: Icon(Icons.bookmark_border, color: Colors.white)),
                IconButton(
                    onPressed: () {
                      if (fontSize < 22.0) {
                        fontSize++;
                      } else {
                        fontSize = 18.0;
                      }
                      Global.settings['textFontSize'] = fontSize;
                      listNotifier.value++;
                      Global.saveSettings();
                    },
                    icon: Icon(Icons.text_fields, color: Colors.white)),
              ],
              //  elevation: 0,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white),
                ),
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
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Expanded(
                          flex: 1,
                          child: FutureBuilder(
                              future: loadData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ValueListenableBuilder(
                                      valueListenable: listNotifier,
                                      builder: (context, number, child) {
                                        return Stack(
                                          children: [
                                            ScrollablePositionedList.builder(
                                              itemScrollController: scrollController,
                                              itemCount: dataBox.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                Map verseMap = dataBox.getAt(i);

                                                return TextButton(
                                                  style: ButtonStyle(
                                                      backgroundColor: versePlaying && i == versePlayingIndex
                                                          ? MaterialStateProperty.all(Color.fromRGBO(108, 190, 217, 0.15))
                                                          : MaterialStateProperty.all(Color.fromRGBO(10, 10, 10, 0))),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: versePlaying && i == versePlayingIndex
                                                        ? RichText(
                                                            textAlign: TextAlign.left,
                                                            text: TextSpan(children: <TextSpan>[
                                                              TextSpan(
                                                                  text: verseMap['data'].substring(0, ttsStartOffset),
                                                                  style: DataTextStylePlayed(verseMap)),
                                                              TextSpan(
                                                                  text: verseMap['data'].substring(ttsStartOffset, ttsEndOffset),
                                                                  style: DataTextStylePlayed(verseMap)),
                                                              TextSpan(
                                                                  text: verseMap['data'].substring(ttsEndOffset),
                                                                  style: DataTextStyleNotPlayed(verseMap)),
                                                            ]),
                                                          )
                                                        : Text(
                                                            verseMap['data'],
                                                            style: DataTextStyle(verseMap),
                                                          ),
                                                  ),
                                                  onPressed: () async {
                                                    showDialog(
                                                        context: ctx,
                                                        builder: (BuildContext cntxt) {
                                                          return Padding(
                                                              padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                                                              child: Column(
                                                                // alignment: Alignment.bottomCenter,
                                                                  children: [
                                                                    SizedBox(
                                                                      height: 60,
                                                                    ),
                                                                    adsUnits.googleBannerAd3(),
                                                                    Spacer(),
                                                                    Container(
                                                                      padding:  EdgeInsets.fromLTRB(10, 10, 10,10),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(5.0), color: Color.fromARGB(70, 0, 0, 0)),
                                                                      child: Text(
                                                                        verseMap['data'].toString().length > 120
                                                                            ? verseMap['data'].toString().substring(0, 119) + '...'
                                                                            : verseMap['data'].toString(),
                                                                        style:
                                                                        TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500
                                                                            ,inherit: false),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 20,
                                                                    ),
                                                                    Material(
                                                                      //  color: Color.fromARGB(0, 0, 0, 0),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(5.0), color: Global.canvasColor()),
                                                                          //  height: (MediaQuery.of(ctx).size.height * 2) / 3,
                                                                          child: Padding(
                                                                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                                              child: OptionsButtons(cntxt, verseMap, i, title)),
                                                                        ))
                                                                  ]));
                                                        });
                                                  },
                                                );
                                              },
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Row(
                                                children: [
                                                  if (index.length != 0)
                                                    GestureDetector(
                                                      child: Container(
                                                        margin: EdgeInsets.all(15),
                                                        height: 45,
                                                        width: 45,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(5.0)), color: Colors.lightBlueAccent),
                                                        child: Icon(
                                                          Icons.view_list_outlined,
                                                          size: 33,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        indexDialog(title, index, 1);
                                                      },
                                                    ),
                                                  Spacer(),
                                                  if (versePlaying)
                                                    GestureDetector(
                                                      child: Container(
                                                          height: 45,
                                                          width: 45,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(50.0)), color: Colors.lightBlueAccent),
                                                          child: Icon(
                                                            Icons.settings,
                                                            size: 28,
                                                            color: Colors.white,
                                                          )),
                                                      onTap: () {
                                                        flutterTts.stop();
                                                        versePlaying = false;
                                                        listNotifier.value++;
                                                        AndroidIntent intent = AndroidIntent(
                                                          action: "com.android.settings.TTS_SETTINGS",
                                                        );
                                                        intent.launch();
                                                      },
                                                    ),
                                                  Container(
                                                    width: 10,
                                                    height: 0,
                                                  ),
                                                  if (versePlaying)
                                                    GestureDetector(
                                                      child: Container(
                                                          height: 55,
                                                          width: 55,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(50.0)), color: Colors.lightBlueAccent),
                                                          child: Icon(
                                                            Icons.stop,
                                                            size: 30,
                                                            color: Colors.white,
                                                          )),
                                                      onTap: () {
                                                        flutterTts.stop();
                                                        versePlaying = false;
                                                        listNotifier.value++;
                                                      },
                                                    ),
                                                  Container(
                                                    width: 10,
                                                    height: 0,
                                                  ),
                                                  if (versePlaying)
                                                    GestureDetector(
                                                      child: Container(
                                                          height: 45,
                                                          width: 45,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(50.0)), color: Colors.lightBlueAccent),
                                                          child: Icon(
                                                            Icons.skip_next,
                                                            size: 28,
                                                            color: Colors.white,
                                                          )),
                                                      onTap: () {
                                                        flutterTts.stop();
                                                        speakButtonClick(versePlayingIndex + 1);
                                                        listNotifier.value++;
                                                        scrollController.scrollTo(
                                                            index: versePlayingIndex + 1,
                                                            duration: Duration(milliseconds: 1000),
                                                            curve: Curves.easeIn);
                                                      },
                                                    ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    child: Container(
                                                      margin: EdgeInsets.all(15),
                                                      height: 45,
                                                      width: 45,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(5.0)), color: Colors.lightBlueAccent),
                                                      child: Icon(
                                                        Icons.keyboard_arrow_up,
                                                        size: 40,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 500));
                                                    },
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                } else {
                                  return Center(
                                    child: Column(
                                      children: [Spacer(), CircularProgressIndicator(), Spacer()],
                                    ),
                                  );
                                }
                              }))
                    ],
                  ),
                )
              ],
            )));
  }

  bookmarkButtonClick(verseMap, i) {
    verseMap = dataBox.getAt(i);
    if (verseMap['bookmarked'] == null || verseMap['bookmarked'] == false) {
      verseMap['bookmarked'] = true;
    } else {
      verseMap['bookmarked'] = false;
    }
    bookmarks.clear();
    dataBox.putAt(i, verseMap);
    listNotifier.value++;
    translateNotifier.value++;
  }

  translationDialog(verseMap, i) {
    showDialog(
        context: ctx,
        builder: (BuildContext cntxt) {
          return ValueListenableBuilder(
              valueListenable: translateNotifier,
              builder: (context, number, child) {
                return FutureBuilder(
                    future: translateLanguage(),
                    builder: (context, snapshot) {
                      return Padding(
                          padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Material(
                                  color: Color.fromARGB(0, 0, 0, 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                  child: Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Global.canvasColor()),
                                      constraints: BoxConstraints(maxHeight: (MediaQuery.of(ctx).size.height * 2) / 3),
                                      //  height: (MediaQuery.of(ctx).size.height * 2) / 3,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(20, 23, 20, 0),
                                          child: Flex(
                                            direction: Axis.vertical,
                                            children: [
                                              Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                    padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                                    color: buttonsColor,
                                                    height: 40,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          title,
                                                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                                        )
                                                      ],
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: SingleChildScrollView(
                                                    child: SelectableText(
                                                      verseMap['data'] + '\n\n' + translateBox.getAt(i)['data'],
                                                      style: TextStyle(color: Global.normalTextColor(), fontSize: fontSize),
                                                    ),
                                                  )),
                                              Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                    // padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                    color: buttonsColor,
                                                    height: 1,
                                                  )),
                                              Expanded(
                                                  flex: 0,
                                                  child: ValueListenableBuilder(
                                                      valueListenable: translateNotifier,
                                                      builder: (context, number, child) {
                                                        return Container(
                                                          child: TextButton(
                                                            child: Flex(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              direction: Axis.horizontal,
                                                              children: [
                                                                Expanded(
                                                                  flex: 0,
                                                                  child: Text(
                                                                    'Choose Language : ',
                                                                    style: TextStyle(color: Global.bookmarkColor(), fontSize: 15),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 0,
                                                                  child: Text(
                                                                    Global.settings['translateLanguage'].toString().capitalizeFirstofEach,
                                                                    style: TextStyle(color: Global.normalTextColor(), fontSize: 17),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 0,
                                                                  child: Icon(
                                                                    Icons.arrow_right,
                                                                    size: 40,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context: ctx,
                                                                  builder: (BuildContext cntxt) {
                                                                    return Dialog(
                                                                      child: ListView(
                                                                        shrinkWrap: true,
                                                                        children: [
                                                                          for (int i = 0; i < Global.language.length; i++)
                                                                            ListTile(
                                                                              title: Text(Global.language[i].toString().capitalizeFirstofEach),
                                                                              onTap: () {
                                                                                Global.settings['translateLanguage'] = Global.language[i];
                                                                                translateNotifier.value++;
                                                                                Navigator.pop(cntxt);
                                                                                Global.saveSettings();
                                                                              },
                                                                            )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                          ),
                                                        );
                                                      }))
                                            ],
                                          ))))));
                    });
              });
        });
  }

  shareButtonClick(verseMap, title) {
    Share.share('${verseMap['data']}\n\n- $title', subject: 'A verse from $title');
  }

  speakButtonClick(i) async {
    ttsStartOffset = 0;
    ttsEndOffset = 0;
    flutterTts = new FlutterTts();
    // await flutterTts.setVolume(1.0);
    // await flutterTts.setPitch(0.9);
    if (Global.settings['language'] == Global.language[2]) {
      // await flutterTts.setSpeechRate(0.6);
      await flutterTts.setVoice({'name': 'hi-in-x-cfn-local', 'locale': 'hi-IN'});
    } else if (Global.settings['language'] == Global.language[1]) {
      // await flutterTts.setSpeechRate(0.78);
      await flutterTts.setVoice({'name': 'hi-in-x-cfn-local', 'locale': 'hi-IN'});
    } else {
      // await flutterTts.setSpeechRate(0.78);
      await flutterTts.setVoice({'name': 'en-in-x-cxx-local', 'locale': 'en-IN'});
    }
    //await flutterTts.setSilence(1);

    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      ttsStartOffset = startOffset;
      ttsEndOffset = endOffset;
      listNotifier.value++;
    });

    flutterTts.setCompletionHandler(() {
      if (i < dataBox.length - 1) {
        // versePlaying = false;
        versePlayingIndex = i + 1;
        speakButtonClick(i + 1);
        listNotifier.value++;
        scrollController.scrollTo(index: i + 1, duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
      } else {
        flutterTts.stop();
        versePlaying = false;
        versePlayingIndex = 0;
        listNotifier.value++;
      }
    });

    // TtsState ttsState = TtsState.stopped;

    var result = await flutterTts
        .speak(dataBox
            .getAt(i)['data']
            .toString()
            .replaceAll('(', ',')
            .replaceAll('् ', '  ')
            .replaceAll('!', ',')
            .replaceAll('.', ',')
            .replaceAll(RegExp(r'\[\d+\]$'), '   ')
            .replaceAll(RegExp(r'\[\d+-\d+\]$'), '   '))
        .then((value) {
      versePlaying = true;
      versePlayingIndex = i;
      listNotifier.value++;
    });
    // if (result == 1) ttsState = TtsState.playing;
    if (result == 1) {}

    // List list = await flutterTts.getVoices;
    // for (var item in list) {
    //   if (item['locale'].toString().contains('en-IN') && item['name'].toString().contains('local')) {
    //     print(item);
    //   }
    // }
  }

  gTranslateDialog(verseMap, i) {
    showDialog(
        context: ctx,
        builder: (BuildContext cntxt) {
          return Padding(
              padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                      color: Color.fromARGB(0, 0, 0, 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Global.canvasColor()),
                          constraints: BoxConstraints(maxHeight: (MediaQuery.of(ctx).size.height * 2) / 3),
                          //  height: (MediaQuery.of(ctx).size.height * 2) / 3,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 23, 20, 5),
                              child: Flex(
                                direction: Axis.vertical,
                                children: [
                                  Expanded(
                                      flex: 0,
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        color: buttonsColor,
                                        height: 40,
                                        child: Row(
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                            )
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: ValueListenableBuilder(
                                          valueListenable: translateNotifier,
                                          builder: (context, number, child) {
                                            return FutureBuilder(
                                                future: gTranslate(i),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return SingleChildScrollView(
                                                      child: SelectableText(
                                                        verseMap['data'] + '\n\n' + snapshot.data,
                                                        style: TextStyle(color: Global.normalTextColor(), fontSize: fontSize),
                                                      ),
                                                    );
                                                  } else {
                                                    return Center(
                                                      child: Column(
                                                        children: [Spacer(), CircularProgressIndicator(), Spacer()],
                                                      ),
                                                    );
                                                  }
                                                });
                                          })),
                                  Expanded(
                                      flex: 0,
                                      child: Container(
                                        // padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        color: buttonsColor,
                                        height: 1,
                                      )),
                                  Expanded(
                                      flex: 0,
                                      child: ValueListenableBuilder(
                                          valueListenable: translateNotifier,
                                          builder: (context, number, child) {
                                            return Container(
                                              child: TextButton(
                                                child: Flex(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  direction: Axis.horizontal,
                                                  children: [
                                                    Expanded(
                                                      flex: 0,
                                                      child: Text(
                                                        'Choose Language : ',
                                                        style: TextStyle(color: Global.bookmarkColor(), fontSize: 15),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 0,
                                                      child: Text(
                                                        GTranslate.languageMap[Global.settings['gTransLangCode']],
                                                        style: TextStyle(color: Global.normalTextColor(), fontSize: 17),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 0,
                                                      child: Icon(
                                                        Icons.arrow_right,
                                                        size: 40,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                      context: ctx,
                                                      builder: (BuildContext cntxt) {
                                                        return Dialog(
                                                          child: ListView(
                                                            children: [
                                                              for (int i = 0; i < GTranslate.languageMap.length; i++)
                                                                ListTile(
                                                                  title: Text(GTranslate.languageMap.values.toList()[i]),
                                                                  onTap: () {
                                                                    Global.settings['gTransLangCode'] = GTranslate.languageMap.keys.toList()[i];
                                                                    translateNotifier.value++;
                                                                    Navigator.pop(cntxt);
                                                                    Global.saveSettings();
                                                                  },
                                                                )
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                },
                                              ),
                                            );
                                          }))
                                ],
                              ))))));
        });
  }

  OptionsButtons(cntxt, verseMap, i, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            verseMap['bookmarked'] == true ? Icons.bookmark_remove : Icons.bookmark_add,
            size: 30,
            color: buttonsColor,
          ),
          onPressed: () {
            bookmarkButtonClick(verseMap, i);
            Navigator.pop(cntxt);
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            Icons.share,
            size: 28,
            color: buttonsColor,
          ),
          onPressed: () {
            shareButtonClick(verseMap, title);
            Navigator.pop(cntxt);
          },
        ),
        Spacer(),
        GestureDetector(
          child: Icon(
            Icons.play_circle_fill,
            size: 55,
            color: buttonsColor,
          ),
          onTap: () async {
            listNotifier.value++;
            speakButtonClick(i);
            Navigator.pop(cntxt);
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            Icons.translate,
            size: 28,
            color: buttonsColor,
          ),
          onPressed: () {
            Navigator.pop(cntxt);
            translationDialog(verseMap, i);
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            Icons.g_translate,
            size: 25,
            color: buttonsColor,
          ),
          onPressed: () {
            Navigator.pop(cntxt);
            gTransWarningDialog(verseMap, i);
          },
        ),
      ],
    );
  }

  loadData() async {

    dataBox = await Hive.openBox(nameEnglish + '_' + (Global.settings['language']));
    translateBox = await Hive.openBox(nameEnglish + '_' + (Global.settings['translateLanguage']));

    for (int i = 0; i < dataBox.length; i++) {
      if (dataBox.getAt(i)['type'] == 'title1') {
        index[i] = dataBox.getAt(i)['type'];
      }
    }
    return 'done';
  }

  translateLanguage() async {
    translateBox = await Hive.openBox(nameEnglish + '_' + (Global.settings['translateLanguage']));
  }

  gTransWarningDialog(verseMap, i) async {
    if (Global.settings['gTransWarning'] == null || Global.settings['gTransWarning'] == false) {
      Global.settings['gTransWarning'] = true;
      Global.saveSettings();
      showDialog(
          context: ctx,
          builder: (BuildContext cntxt) {
            return AlertDialog(
              title: Text('Warning'),
              content: Text(Global.gTransWarningText()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(cntxt);
                    },
                    child: Text('Ok'))
              ],
            );
          }).then((value) => gTranslateDialog(verseMap, i));
    } else {
      gTranslateDialog(verseMap, i);
    }
  }

  gTranslate(i) async {
    try {
      //checking internet connection
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print(Global.settings['gTransLangCode']);
        final translator = GoogleTranslator();
        //getting veda name in english and 'english' language for the box opening
        var box = await Hive.openBox(nameEnglish + '_' + (Global.language[1]));
        var input = await box.getAt(i)['data'];
        var translation = await translator.translate(input.toString(), from: 'hi', to: Global.settings['gTransLangCode']);
        return translation.text;
      }
    } on SocketException catch (_) {
      return 'No Internet...';
      print('not connected');
    }
  }

  bookmarksDialog() {
    for (int j = 0; j < dataBox.length; j++) {
      Map verseMap = dataBox.getAt(j);
      if (verseMap['bookmarked'] != null && verseMap['bookmarked'] == true) {
        bookmarks[j] = verseMap['data'];
      }
    }
    showDialog(
        context: ctx,
        builder: (BuildContext cntxt) {
          return Padding(
              padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                      color: Color.fromARGB(0, 0, 0, 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Global.canvasColor()),
                        height: (MediaQuery.of(ctx).size.height * 2) / 3,
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            Expanded(
                                flex: 0,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  color: buttonsColor,
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Text(title.toString().capitalizeFirstofEach +
                                            ' Bookmarks',
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                      )
                                    ],
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        for (int i = 0; i < bookmarks.length; i++)
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(cntxt);
                                                scrollController.scrollTo(
                                                    index: bookmarks.keys.toList()[i], duration: Duration(milliseconds: 400), curve: Curves.ease);
                                              },
                                              child: Text(
                                                bookmarks.values.toList()[i],
                                                style: TextStyle(fontSize: fontSize - 1, color: Global.normalTextColor()),
                                              ))
                                      ],
                                    ))),
                            Expanded(
                                flex: 0,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  color: buttonsColor,
                                  height: 1,
                                ))
                          ],
                        ),
                      ))));
        });
  }

  indexDialog(title, mapFitered, titleLevelCount) {
    showDialog(
        builder: (BuildContext cntxt) {
          return Dialog(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 15, 20, 5),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.blue),
                  ),
                ),
                for (int i = 0; i < mapFitered.length; i++)
                  ListTile(
                    onTap: () {
                      Navigator.pop(cntxt);
                      scrollController.scrollTo(index: mapFitered.keys.toList()[i], duration: Duration(milliseconds: 400));
                    },
                    title: Padding(
                      padding: EdgeInsets.all(0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              (i + 1).toString() + '. ' + dataBox.getAt(mapFitered.keys.toList()[i])['data'],
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if ((mapFitered.keys.toList()[i] + 1) < dataBox.length &&
                              dataBox.getAt(mapFitered.keys.toList()[i] + 1)['type'].contains('title'))
                            Expanded(
                                flex: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.view_list_outlined,
                                    size: 30,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () {
                                    Map nextMap = {};
                                    for (int k = mapFitered.keys.toList()[i] + 1; k < dataBox.length; k++) {
                                      if (dataBox.getAt(k)['type'] != 'title' + titleLevelCount.toString()) {
                                        if (dataBox.getAt(k)['type'] == 'title' + (titleLevelCount + 1).toString()) {
                                          nextMap[k] = dataBox.getAt(k)['type'];
                                        }
                                      } else {
                                        break;
                                      }
                                    }
                                    Navigator.pop(cntxt);
                                    indexDialog(title + ' > ' + dataBox.getAt(mapFitered.keys.toList()[i])['data'], nextMap, titleLevelCount + 1);
                                  },
                                ))
                        ],
                      ),
                    ),
                  )
              ],
            ),
          );
        },
        context: ctx);
  }

  DataTextStyle(verseMap) {
    return TextStyle(
      color: verseMap['bookmarked'] == true ? Global.bookmarkColor() : Global.normalTextColor(),
      fontSize: verseMap['type'] == 'title1'
          ? fontSize + 4
          : verseMap['type'] == 'title2'
              ? fontSize + 2
              : verseMap['type'] == 'title3'
                  ? fontSize + 2
                  : fontSize,
      fontWeight: verseMap['type'] == 'verse' ? FontWeight.w400 : FontWeight.w600,
    );
  }

  DataTextStylePlayed(verseMap) {
    return TextStyle(
      color: Global.bookmarkColor(),
      fontSize: verseMap['type'] == 'title1'
          ? fontSize + 4
          : verseMap['type'] == 'title2'
              ? fontSize + 2
              : verseMap['type'] == 'title3'
                  ? fontSize + 2
                  : fontSize,
      fontWeight: verseMap['type'] == 'verse' ? FontWeight.w400 : FontWeight.w600,
    );
  }

  DataTextStyleNotPlayed(verseMap) {
    return TextStyle(
      color: Global.normalTextColor(),
      fontSize: verseMap['type'] == 'title1'
          ? fontSize + 4
          : verseMap['type'] == 'title2'
              ? fontSize + 2
              : verseMap['type'] == 'title3'
                  ? fontSize + 2
                  : fontSize,
      fontWeight: verseMap['type'] == 'verse' ? FontWeight.w400 : FontWeight.w600,
    );
  }
}
