import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;



  handleLoveIconClick(context ,timestamp, uid) async {
    final DocumentReference ref = firestore.collection('users').doc(uid);
    final DocumentReference ref1 = firestore.collection('contents').doc(timestamp);

    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();
    List d = snap['loved items'];
    int? loves = snap1['loves'];

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({'loved items': FieldValue.arrayRemove(a)});
      ref1.update({'loves': loves! - 1});

    } else {

      d.add(timestamp);
      await ref.update({'loved items': FieldValue.arrayUnion(d)});
      ref1.update({'loves': loves! + 1});

    }

    notifyListeners();

    

  }



  

}