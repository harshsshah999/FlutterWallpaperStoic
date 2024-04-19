import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataBloc extends ChangeNotifier {
  
  
  List _alldata = [];
  List get alldata => _alldata;


  List _categories = [];
  List get categories => _categories;

  DataBloc() {
    getData();
    getCategories();
  }

  getData() async {
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('contents').get();
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
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('categories').get();
    var x = snap.docs;
    
    _categories.clear();

    x.forEach((f) => _categories.add(f));
    notifyListeners();
  }


 
}
