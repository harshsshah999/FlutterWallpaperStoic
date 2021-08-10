import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {



  Future<List> getData () async{
    
    SharedPreferences sp = await SharedPreferences.getInstance();
    String _uid = sp.getString('uid');

    final DocumentReference ref = Firestore.instance.collection('users').document(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap.data['loved items'];
    List filteredData = [];
    if(d.isNotEmpty){
      await Firestore.instance
          .collection('contents')
          .where('timestamp', whereIn: d)
          .getDocuments()
          .then((QuerySnapshot snap){
            filteredData = snap.documents;
          });
    }

    notifyListeners();
    return filteredData;

    
  }
}