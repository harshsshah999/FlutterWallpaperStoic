import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List> getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');

    final DocumentReference ref = firestore.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap['loved items'];
    List filteredData = [];
    //List sublist = [];
    print('a');

    // if(d.isNotEmpty){
    //   for (var i in d) {

    //     await firestore.collection('contents').where('timestamp', isEqualTo: i).get().then((snap){
    //       sublist.add(snap.docs);
    //       print('filtered data: ${filteredData}');
    //     });
    // }
    //   filteredData = sublist;
    // }

    if (d.isNotEmpty) {
      await firestore
        .collection('contents')
        .where('timestamp', whereIn: d.take(10).toList())
        .limit(10)
        .get()
        .then((QuerySnapshot snap) {
          filteredData = snap.docs;
      });
    }

    notifyListeners();
    return filteredData;
  }
}
