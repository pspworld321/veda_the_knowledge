import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'global.dart';
import 'main.dart';
import 'textReading.dart';
import 'titleList.dart';

final bannerAdId1 = 'ca-app-pub-5704045408668888/2774815220';
final bannerAdId2 = 'ca-app-pub-5704045408668888/4213858662';
final bannerAdId3 = 'ca-app-pub-5704045408668888/1774300109';
final interAdId = 'ca-app-pub-5704045408668888/7636808407';

class AdsUnits {

  static bool admobInit = false;
  static bool interAdLoaded = false;
  static bool gAdClicked = false;

  var myBanner1;
  var myBanner2;
  var myBanner3;
  var adWidget1;
  var adWidget2;
  var adWidget3;
  var interstitialAd;

  loadInterAd() {
    InterstitialAd.load(
        adUnitId: interAdId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          this.interstitialAd = ad;
          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) => print('%ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
            },
            onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
          );

          AdsUnits.interAdLoaded = true;
        }, onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        }));
  }

  showInterAd() {
    if (AdsUnits.admobInit && !AdsUnits.gAdClicked && AdsUnits.interAdLoaded) {
      interstitialAd.show();
      loadInterAd();
    }
  }

  loadBanner1() async {
    myBanner1 = myBannerAd1;
    adWidget1 = AdWidget(ad: myBanner1);
    await myBanner1.load();
    MyHomePageState.adNotifier.value++;
  }

  loadBanner2() async {
    myBanner2 = myBannerAd2;
    adWidget2 = AdWidget(ad: myBanner2);
    await myBanner2.load();
    TextReadingState.adNotifier.value++;
  }

  loadBanner3() async {
    myBanner3 = myBannerAd3;
    adWidget3 = AdWidget(ad: myBanner3);
    await myBanner3.load();
    TitleListState.adNotifier.value++;
  }

  loadAds() async {
    try {
      MobileAds.instance.initialize().then((d) async {
        AdsUnits.admobInit = true;
        loadBanner1();
        loadBanner2();
        loadBanner3();
        loadInterAd();
        // loadInterAd();
      });
    } catch (e) {
      AdsUnits.admobInit = false;
    }
  }

  googleBannerAd1() {
    return ValueListenableBuilder(
      valueListenable: MyHomePageState.adNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return AdsUnits.admobInit
            ? Container(margin:  EdgeInsets.fromLTRB(0, 20, 0, 0),
          alignment: Alignment.center,
          child: adWidget1,

          width: myBannerAd1.size.width.toDouble(),
          height: myBannerAd1.size.height.toDouble(),
        )
            : Container(
          width: 0,
          height: 0,
          // width: 300,
        );
      },
    );
  }

  googleBannerAd2() {
    return ValueListenableBuilder(
      valueListenable: TextReadingState.adNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return AdsUnits.admobInit
            ? Container(margin:  EdgeInsets.fromLTRB(0, 20, 0, 0),
          alignment: Alignment.center,
          child: adWidget2,

          width: myBannerAd2.size.width.toDouble(),
          height: myBannerAd2.size.height.toDouble(),
        )
            : Container(
          width: 0,
          height: 0,
          // width: 300,
        );
      },
    );
  }

  googleBannerAd3() {
    return ValueListenableBuilder(
      valueListenable: TitleListState.adNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return AdsUnits.admobInit
            ? Container(
          alignment: Alignment.center,
          child: adWidget3,

          width: myBannerAd3.size.width.toDouble(),
          height: myBannerAd3.size.height.toDouble(),
        )
            : Container(
          width: 0,
          height: 0,
          // width: 300,
        );
      },
    );
  }

  BannerAd myBannerAd1 = BannerAd(
    adUnitId: bannerAdId1,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(onAdFailedToLoad: (Ad, err) {
      print('Ad error.' + err.toString());
    },
    ),
  );

  BannerAd myBannerAd2 = BannerAd(
    adUnitId: bannerAdId2,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(onAdFailedToLoad: (Ad, err) {
      print('Ad error.' + err.toString());
    },
    ),
  );

  BannerAd myBannerAd3 = BannerAd(
    adUnitId: bannerAdId3,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(onAdFailedToLoad: (Ad, err) {
      print('Ad error.' + err.toString());
    },
    ),
  );

}