import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stoicwallpaper/models/config.dart';

class AdsBloc extends ChangeNotifier {
  @override
  void dispose() {
    disposeAdmobInterstitialAd();
    //admob
    //destroyFbAd();                       //fb
    super.dispose();
  }

  //admob Ads -------Start--------
  RewardedAd? _rewardedAd;
  RewardedAd? get rewardedAd => _rewardedAd;

  int rewardPoint = 0;
  int getReward() => rewardPoint;

  bool _admobAdLoaded = false;
  bool get admobAdLoaded => _admobAdLoaded;

  bool isbannerAdLoaded = false;
  bool get bannerAdLoaded => isbannerAdLoaded;

  BannerAd? bannerAd;

  InterstitialAd? interstitialAdAdmob;

  void createAdmobInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Config().admobInterstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('$ad onAdDismissedFullScreenContent.');
                ad.dispose();
                interstitialAdAdmob = null;
                _admobAdLoaded = false;
                notifyListeners();
                loadAdmobInterstitialAd();
              },
            );
            print('$ad loadedf with me');
            interstitialAdAdmob = ad;
            _admobAdLoaded = true;
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            interstitialAdAdmob = null;
            _admobAdLoaded = false;
            notifyListeners();
            loadAdmobInterstitialAd();
          },
        ));
  }

  // void showInterstitialAdAAdmob() {
  //   print("entering showad");
  //   try {
  //     if (_admobAdLoaded) {
  //       interstitialAdAdmob!.show();
  //     } else {
  //       print("add not loaded");
  //     }
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  BannerAd? createAdmobBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Config().admobBannerAdId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('$ad loadedf with me');
            bannerAd = ad as BannerAd?;
            isbannerAdLoaded = true;
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            print('BannerAd Failed to load: $error');
            ad.dispose();
            bannerAd = null;
            isbannerAdLoaded = false;
            notifyListeners();
          },
          onAdOpened: (ad) {
            print("Ad Opened");
          },
          onAdClosed: (ad) {
            print("Ad closed");
          },
        ),
        request: AdRequest());
    bannerAd?.load();
    print("bannerAd is: $bannerAd");
    return bannerAd!;
  }

  void showBannerAd() {}

  void showInterstitialAdAdmob() {
    if (interstitialAdAdmob != null) {
      interstitialAdAdmob!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            debugPrint('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('$ad onAdDismissedFullScreenContent.');
          ad.dispose();
          interstitialAdAdmob = null;
          _admobAdLoaded = false;
          notifyListeners();
          loadAdmobInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          interstitialAdAdmob = null;
          _admobAdLoaded = false;
          notifyListeners();
          loadAdmobInterstitialAd();
        },
      );
      interstitialAdAdmob!.show();
      interstitialAdAdmob = null;
      notifyListeners();
    }
  }

  Future loadAdmobBannerAd() async {
    if (isbannerAdLoaded == false) {
      createAdmobBannerAd();
    }
  }

  Future loadAdmobInterstitialAd() async {
    if (_admobAdLoaded == false) {
      createAdmobInterstitialAd();
    }
  }

  Future disposeAdmobInterstitialAd() async {
    interstitialAdAdmob?.dispose();
    notifyListeners();
  }

  //admob reward interstitial ad
  // void loadRewardAd() {
  //   RewardedAd.load(
  //       adUnitId: 'ca-app-pub-3940256099942544/5224354917',
  //       request: AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (RewardedAd ad) {
  //           print('$ad loaded.');
  //           // Keep a reference to the ad so you can show it later.
  //           this._rewardedAd = ad;
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           print('RewardedAd failed to load: $error');
  //         },
  //       ));
  // }

  // void showRewardAd() {
  //   _rewardedAd!.show(onUserEarnedReward: (ad, rewardItem) {
  //     // after user earned reward start downloading
  //     rewardPoint = rewardPoint + rewardItem.amount as int;

  //     notifyListeners();
  //   });
  //   _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (RewardedAd ad) =>
  //         print('$ad onAdShowedFullScreenContent.'),
  //     onAdDismissedFullScreenContent: (RewardedAd ad) {
  //       print('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //     },
  //     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //       print('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //     },
  //     onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
  //   );
  // }

  // disposeAdmobRewardAd() {
  //   _rewardedAd?.dispose();
  //   notifyListeners();
  // }

  // admob ads --------- end --------

  //fb ads ----------- start ----------

  // bool _fbadloaded = false;
  // bool get fbadloaded => _fbadloaded;

  // Future loadFbAd() async{
  //   FacebookInterstitialAd.loadInterstitialAd(
  //     placementId: Config().facebookInterstitialAdId,
  //     listener: (result, value) {
  //       debugPrint(result);
  //       if (result == InterstitialAdResult.LOADED){
  //         _fbadloaded = true;
  //         debugPrint('ads loaded');
  //         notifyListeners();
  //       }else if(result == InterstitialAdResult.DISMISSED && value["invalidated"] == true){
  //         _fbadloaded = false;
  //         debugPrint('ads dismissed');
  //         loadFbAd();
  //         notifyListeners();
  //       }

  //     }
  //   );
  // }

  // Future showFbAdd() async{
  //   if(_fbadloaded == true){
  //     await FacebookInterstitialAd.showInterstitialAd();
  //     _fbadloaded = false;
  //     notifyListeners();
  //   }

  // }

  // Future destroyFbAd() async{
  //   if (_fbadloaded == true) {
  //     FacebookInterstitialAd.destroyInterstitialAd();
  //     _fbadloaded = false;
  //     notifyListeners();
  //   }
  // }

  //fb ads ----------- end ----------
}
