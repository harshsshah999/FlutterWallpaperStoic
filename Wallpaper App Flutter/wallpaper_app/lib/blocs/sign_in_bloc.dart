import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInBloc extends ChangeNotifier {


  SignInBloc() {
    checkSignIn();
    checkGuestUser();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // User state variables
  bool _guestUser = false;
  bool get guestUser => _guestUser;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _name;
  String? get name => _name;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? timestamp;




  
  // Method to sign in with Google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googlSignIn.signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user!;

        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _uid = userDetails.uid;

        _hasError = false;
        notifyListeners();
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        print(e.toString());
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }


  // Method to check if user exists in Firestore
  Future<bool> checkUserExists() async {
    
    DocumentSnapshot snap = await firestore.collection('users').doc(_uid).get();
    if(snap.exists){
      print('User Exists');
      return true;
    }else{
      print('new user');
      return false;
    }
  }


  // Method to save user data to Firestore
  Future saveToFirebase() async {
    final DocumentReference ref = firestore.collection('users').doc(uid);
    await ref.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'timestamp': timestamp,
      'loved items': []
    });
  }

  // Method to get the current timestamp
  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    timestamp = timestamp;
  }

  // Method to save user data to SharedPreferences
  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString('name', _name!);
    await sharedPreferences.setString('email', _email!);
    await sharedPreferences.setString('image url', _imageUrl!);
    await sharedPreferences.setString('uid', _uid!);
  }

  // Method to get user data from SharedPreferences
  Future getUserDatafromSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    
    _name = sp.getString('name');
    _email = sp.getString('email');
    _uid = sp.getString('uid');
    _imageUrl = sp.getString('image url');
    notifyListeners();
  }



   // Method to get user data from Firestore
  Future getUserDataFromFirebase(uid) async {
    await firestore
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      _uid = snap['uid'];
      _name = snap['name'];
      _email = snap['email'];
      _imageUrl = snap['image url'];
      debugPrint("name: $_name, Image Url: $imageUrl ");
    });
    notifyListeners();
  }




  // Method to set the sign-in status in SharedPreferences
  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  // Method to check if the user is signed in from SharedPreferences
  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed in') ?? false;
    notifyListeners();
  }

  // Method to sign out the user
  Future userSignout() async {
    await _firebaseAuth.signOut();
    await _googlSignIn.signOut();
    _isSignedIn = false;
    _guestUser = false;
    clearAllData();
    notifyListeners();
  }


  // Method to set the guest user status in SharedPreferences
  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', true);
    _guestUser = true;
    notifyListeners();
  }

  // Method to check if the user is a guest from SharedPreferences
  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestUser = sp.getBool('guest user') ?? false;
    notifyListeners();
  }

  // Method to clear all data from SharedPreferences
  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  // Method to sign out a guest user
  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', false);
    _guestUser = false;
    notifyListeners();
  }

  // Method to get the total users count from Firestore
  Future<int> getTotalUsersCount () async {
    const String fieldName = 'count';
    final DocumentReference ref = firestore.collection('item_count').doc('users_count');
      DocumentSnapshot snap = await ref.get();
      if(snap.exists == true){
        int itemCount = snap[fieldName] ?? 0;
        return itemCount;
      }
      else{
        await ref.set({
          fieldName : 0
        });
        return 0;
      }
  }

  // Method to increase the users count in Firestore
  Future increaseUserCount () async {
    await getTotalUsersCount()
    .then((int documentCount)async {
      await firestore.collection('item_count')
      .doc('users_count')
      .update({
        'count' : documentCount + 1
      });
    });
  }


  
}
