
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBloc extends ChangeNotifier {
  
  
 
  String _adminPass;
  String _userType = 'Admin';
  bool _isSignedIn = false;
  bool _testing = false;
  List _categories = [];
  List _categoryNames = [];

  
  

  AdminBloc() {
    checkSignIn();
    getAdminPass();
    getCategories();
    
  }


  

  String get adminPass => _adminPass;
  String get userType => _userType;
  bool get isSignedIn => _isSignedIn;
  bool get testing => _testing;
  List get categories => _categories;
  List get categoryNames => _categoryNames;



  

  void getAdminPass() {
    Firestore.instance
        .collection('admin')
        .document('user type')
        .get()
        .then((DocumentSnapshot snap) {
      String _aPass = snap.data['admin password'];
     _adminPass = _aPass;
      notifyListeners();
    });
  }

  







  


  Future deleteContent(timestamp) async {
    await Firestore.instance.collection('contents').document(timestamp).delete();
    
  }


  Future getCategories ()async{
    QuerySnapshot snap = await Firestore.instance.collection('categories').getDocuments();
    var x = snap.documents;
    
    _categories.clear();
    _categoryNames.clear();

    x.forEach((element) => _categoryNames.add(element['name']));

    x.forEach((f) => _categories.add(f));
    _categories.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    notifyListeners();
  }


  Future deleteCategory (timestamp) async{
    await Firestore.instance.collection('categories').document(timestamp).delete();
    getCategories();
  }









  

  

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed in', true);
    _isSignedIn = true;
    _userType = 'Admin';
    notifyListeners();
  }


  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed in') ?? false;
    notifyListeners();
  }



  Future setSignInForTesting() async {
    
    _testing = true;
    _userType = 'Tester';
    notifyListeners();
    
  }




}
