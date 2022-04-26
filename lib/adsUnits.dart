import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'global.dart';
import 'main.dart';

final bannerAdId = 'ca-app-pub-5704045408668888/2774815220';
final interAdId = 'ca-app-pub-5704045408668888/7636808407';

class AdsUnits {

  static bool admobInit = false;
  static bool interAdLoaded = false;
  static bool gAdClicked = false;

  var myBanner;
  var interstitialAd;
  var adWidget;

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

  loadAds() async {
    try {
      MobileAds.instance.initialize().then((d) async {
        AdsUnits adUnits = AdsUnits();
        myBanner = adUnits.myBanner1;
        adWidget = AdWidget(ad: myBanner);
        await myBanner.load();
        await loadInterAd();
        AdsUnits.admobInit = true;
        //setState(() {});
        MyHomePageState.adNotifier.value++;
      });
    } catch (e) {
      AdsUnits.admobInit = false;
    }
  }

  googleBannerAd() {
    return ValueListenableBuilder(
      valueListenable: MyHomePageState.adNotifier,
      builder: (BuildContext context, value, Widget? child) {
        return AdsUnits.admobInit &&
            (Global.settings['gAdClickedTime'] == null ||
                DateTime.now().difference(Global.settings['gAdClickedTime']).inSeconds > 10)
            ? Container(padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
          alignment: Alignment.center,
          child: adWidget,
          width: myBanner1.size.width.toDouble(),
          height: myBanner1.size.height.toDouble(),
          // width: 300,
        )
            : Container(
          width: 0,
          height: 0,
          // width: 300,
        );
      },
    );
  }

  BannerAd myBanner1 = BannerAd(
    adUnitId: bannerAdId,
    size: AdSize.mediumRectangle,
    request: AdRequest(),
    listener: BannerAdListener(onAdFailedToLoad: (Ad, err) {
      print('Ad error.' + err.toString());
    },
      onAdOpened: (Ad ad) {
        print('Ad opened.');
        AdsUnits.gAdClicked = true;
        Global.settings['gAdClickedTime'] = DateTime.now();
        Global.saveSettings();
        print(AdsUnits.gAdClicked);
        MyHomePageState.adNotifier.value++;
      },
    ),
  );

}