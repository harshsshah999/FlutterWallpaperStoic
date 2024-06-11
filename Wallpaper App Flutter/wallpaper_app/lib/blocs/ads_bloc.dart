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
  // RewardedAd? _rewardedAd;
  // RewardedAd? get rewardedAd => _rewardedAd;

  // int rewardPoint = 0;
  // int getReward() => rewardPoint;

  bool _admobAdLoaded = false;
  bool get admobAdLoaded => _admobAdLoaded;

  bool isbannerAdLoaded = false;
  bool get bannerAdLoaded => isbannerAdLoaded;

  BannerAd? bannerAd; // Banner ad instance

  InterstitialAd? interstitialAdAdmob; // Interstitial ad instance

  // Method to create and load an AdMob interstitial ad
  void createAdmobInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Config().admobInterstitialAdId, // Ad unit ID from config
        request: const AdRequest(),
        //Defining what happens on different case of ad loading
        adLoadCallback: InterstitialAdLoadCallback(
          //if ad Loaded successfully
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
            print('$ad load');
            interstitialAdAdmob = ad;
            _admobAdLoaded = true;
            notifyListeners();
          },
          //if ad failed to Load
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            interstitialAdAdmob = null;
            _admobAdLoaded = false;
            notifyListeners();
            loadAdmobInterstitialAd();
          },
        ));
  }

  // Method to create and load an AdMob banner ad
  BannerAd? createAdmobBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner, // Banner ad size
        adUnitId: Config().admobBannerAdId, // Ad unit ID from config
        listener: BannerAdListener(
          //if Banner ad loaded successfully
          onAdLoaded: (ad) {
            print('$ad loaded');
            bannerAd = ad as BannerAd?;
            isbannerAdLoaded = true;
            notifyListeners(); // Notify listeners about the state change
          },
          //if Banner ad failed to Load
          onAdFailedToLoad: (ad, error) {
            print('BannerAd Failed to load: $error');
            ad.dispose();
            bannerAd = null;
            isbannerAdLoaded = false;
            notifyListeners();
          }
        ),
        request: AdRequest());
    bannerAd?.load();
    print("bannerAd is: $bannerAd");
    return bannerAd!;
  }

  // Method to display an AdMob interstitial ad
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

   // Method to load a banner ad if not already loaded
  Future loadAdmobBannerAd() async {
    if (isbannerAdLoaded == false) {
      createAdmobBannerAd();
    }
  }
  
  // Method to load an interstitial ad if not already loaded
  Future loadAdmobInterstitialAd() async {
    if (_admobAdLoaded == false) {
      createAdmobInterstitialAd();
    }
  }

  // Method to dispose of the AdMob interstitial ad
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
