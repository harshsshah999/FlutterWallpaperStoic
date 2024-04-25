import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetBloc extends ChangeNotifier {
  
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;


  InternetBloc() {
    //checkInternet();
  }



  Future checkInternet() async {
    final bool result = await InternetConnectionChecker().hasConnection;
    _hasInternet = result;

    notifyListeners();
  }




}
