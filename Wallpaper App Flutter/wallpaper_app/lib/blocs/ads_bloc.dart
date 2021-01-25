import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:wallpaper_app/models/config.dart';

class AdsBloc extends ChangeNotifier {


  //admob Ads -------Start--------

  bool _admobInterstialAdClosed = false;
  bool get admobInterStitialAdClosed => _admobInterstialAdClosed;

  InterstitialAd _admobInterstitialAd;
  InterstitialAd get admobInterstitialAd => _admobInterstitialAd;

  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: [],
    //keywords: <String>['photo', 'image', 'wallpaper'],
    //contentUrl: '',
    childDirected: false,
    nonPersonalizedAds: true,
  );

  InterstitialAd createAdmobInterstitialAd() {
    return InterstitialAd(
      adUnitId: Config().admobInterstitialAdId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
        if (event == MobileAdEvent.closed) {
          loadAdmobInterstitialAd();
        } else if (event == MobileAdEvent.failedToLoad) {
          disposeAdmobInterstitialAd().then((_) {
            loadAdmobInterstitialAd();
          });
        }
        notifyListeners();
      },
    );
  }

  Future loadAdmobInterstitialAd() async {
    await _admobInterstitialAd?.dispose();
    _admobInterstitialAd = createAdmobInterstitialAd()..load();
    notifyListeners();
  }

  Future disposeAdmobInterstitialAd() async {
    _admobInterstitialAd?.dispose();
    notifyListeners();
  }

  showAdmobInterstitialAd() {
    _admobInterstitialAd?.show();
    notifyListeners();
  }

  // admob ads --------- end --------






  //fb ads ----------- start ----------

  // bool _fbadloaded = false;
  // bool get fbadloaded => _fbadloaded;


  // Future loadFbAd() async{
  //   FacebookInterstitialAd.loadInterstitialAd(
  //     placementId: Config().facebookInterstitialAdId,
  //     listener: (result, value) {
  //       print(result);
  //       if (result == InterstitialAdResult.LOADED){
  //         _fbadloaded = true;
  //         print('ads loaded');
  //         notifyListeners();
  //       }else if(result == InterstitialAdResult.DISMISSED && value["invalidated"] == true){
  //         _fbadloaded = false;
  //         print('ads dismissed');
  //         loadFbAd();
  //         notifyListeners();
  //       }
          
  //     }
  //   );
  // }



  // Future showFbAdd() async{
  //   if(_fbadloaded == true){
  //   await FacebookInterstitialAd.showInterstitialAd();
  //   _fbadloaded = false;
  //   notifyListeners();
  //   }
    
  // }



  // Future destroyFbAd() async{
  //   if (_fbadloaded == true) {
  //     FacebookInterstitialAd.destroyInterstitialAd();
  //     _fbadloaded = false;
  //     notifyListeners();
  //   }
  // }




  // admob ads --------- end --------







  @override
  void dispose() {
    disposeAdmobInterstitialAd();      //admob
    //destroyFbAd();                       //fb
    super.dispose();                     
  }
}
