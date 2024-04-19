import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/models/config.dart';

class UserBloc extends ChangeNotifier {


  String _userName = 'Name';
  String _email = 'email';
  String _uid = 'uid';
  String _imageUrl = Config().guestUserImage;





  String get userName => _userName;
  String get email => _email;
  String get uid => _uid;
  String get imageUrl => _imageUrl;



  Future getUserData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    
    _userName = sp.getString('name')?? '';
    _email = sp.getString('email')?? '';
    _uid = sp.getString('uid')?? '';
    _imageUrl = sp.getString('image url')?? '';
    notifyListeners();
  }





  handleLoveIconClick(context ,timestamp) async {
    final FirebaseFirestore firestore= FirebaseFirestore.instance;
    final DocumentReference ref = firestore.collection('users').doc(_uid);
    final DocumentReference ref1 = firestore.collection('contents').doc(timestamp);

    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();
    // List d = snap.data['loved items'];
    final data = snap.data();
    List d = ((data as Map)['loved items'] as Map)['loved items'];
    int _loves = snap1['loves'];

    if (d.contains(timestamp)) {

      List a = [timestamp];
      await ref.update({'loved items': FieldValue.arrayRemove(a)});
      ref1.update({'loves': _loves - 1});

    } else {

      d.add(timestamp);
      await ref.update({'loved items': FieldValue.arrayUnion(d)});
      ref1.update({'loves': _loves + 1});

    }

    notifyListeners();

    

  }



  

}