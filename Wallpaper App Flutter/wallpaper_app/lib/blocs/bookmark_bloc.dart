import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {



  Future<List> getData () async{
    
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');

    final DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    final data = snap.data();
    List d = ((data as Map)['loved items'] as Map)['loved items'];
    List filteredData = [];
    if(d.isNotEmpty){
      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: d)
          .get()
          .then((QuerySnapshot snap){
            filteredData = snap.docs;
          });
    }

    notifyListeners();
    return filteredData;

    
  }
}