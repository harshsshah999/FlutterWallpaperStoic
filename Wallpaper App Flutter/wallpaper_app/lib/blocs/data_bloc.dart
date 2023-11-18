import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataBloc extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  
  final List _alldata = [];
  List get alldata => _alldata;


  final List _categories = [];
  List get categories => _categories;

  getData() async {
    QuerySnapshot snap = await firestore.collection('contents').orderBy('timestamp', descending: true).limit(100).get();
    //  QuerySnapshot snap = await Firestore.instance.collection('contents')
    //  .where("timestamp", isLessThanOrEqualTo: ['timestamp'])
    //  .orderBy('timestamp', descending: true)
    //  .limit(5).getDocuments();
    List x = snap.docs;
    x.shuffle();
    _alldata.clear();
    x.take(5).forEach((f) {
      _alldata.add(f);
    });
    notifyListeners();
  }


  Future getCategories ()async{
    QuerySnapshot snap = await firestore.collection('categories').get();
    var x = snap.docs;
    
    _categories.clear();

    for (var f in x) {
      _categories.add(f);
    }
    notifyListeners();
  }


 
}
