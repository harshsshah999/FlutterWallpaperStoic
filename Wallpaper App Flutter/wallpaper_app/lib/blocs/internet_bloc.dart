import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class InternetBloc extends ChangeNotifier {
  
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;


  InternetBloc() {
    //checkInternet();
  }



  Future checkInternet() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      _hasInternet = false;
    } else {
      _hasInternet = true;
    }

    notifyListeners();
  }




}
