import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/models/config.dart';

class SignInBloc extends ChangeNotifier {


  SignInBloc() {
    checkSignIn();
    checkGuestUser();
  }

  final FirebaseFirestore firestore= FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();

  bool? _guestUser = false;
  bool get guestUser => _guestUser ?? false;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String get errorCode => _errorCode ?? '';

  bool _userExists = false;
  bool get userExists => _userExists;

  String? _name;
  String get name => _name ?? '';

  String? _uid;
  String get uid => _uid ?? '';

  String? _email;
  String get email => _email ?? '';

  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';

  String? timestamp;




  

  Future signInWithGoogle() async {
    User? userDetails;

    final GoogleSignInAccount? googleUser = await _googlSignIn
        .signIn()
        .catchError((error) => print('error : $error'));
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        userDetails = userCredential.user;

        this._name = userDetails!.displayName;
        this._email = userDetails.email;
        this._imageUrl = userDetails.photoURL;
        this._uid = userDetails.uid;

        _hasError = false;
        notifyListeners();
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future checkUserExists() async {
    await firestore
        .collection('users')
        .get()
        .then((QuerySnapshot snap) {
      List values = snap.docs;
      List uids = [];
      values.forEach((element) {
        uids.add(element['uid']);
      });
      if (uids.contains(_uid)) {
        _userExists = true;
        print('User exists');
      } else {
        _userExists = false;
        print('new User');
      }
      notifyListeners();
    });
  }

  Future saveToFirebase() async {
    try {
    final DocumentReference ref = firestore.collection('users').doc(uid);
    await ref.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'timestamp': timestamp,
      'loved items': [],
    });
    // Show success message (optional)
  } catch (error) {
    print(error); // Log the error for debugging
    // Show error message to the user (optional)
  }
  }

  Future getTimestamp() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    timestamp = _timestamp;
  }

  Future saveDataToSP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.setString('name', _name!);
    await sharedPreferences.setString('email', _email!);
    await sharedPreferences.setString('image url', _imageUrl!);
    await sharedPreferences.setString('uid', _uid!);
  }

  Future getUserData(uid) async {
    try {
    final DocumentSnapshot snap = await firestore
        .collection('users')
        .doc(uid)
        .get();

    if (snap.exists) {
      final data=snap.data() as Map;
      this._uid = (data['uid'] as Map)['uid'];
      this._name = (data['name'] as Map)['name'];
      this._email = (data['email'] as Map)['email'];
      this._imageUrl = (data['image url']as Map)['image_url'];
      print(_name);
    } else {
      // Handle the case where the document doesn't exist
      print("User data not found");
    }
  } catch (error) {
    print(error); // Log the error for debugging
  }
  notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed in') ?? false;
    notifyListeners();
  }

  Future userSignout() async {
    await _firebaseAuth.signOut();
    await _googlSignIn.signOut();
    _isSignedIn = false;
    clearAllData();
    notifyListeners();
  }

  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest user', true);
    _guestUser = true;
    notifyListeners();
  }

  Future saveGuestUserData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('name', 'guest');
    await sp.setString('email', 'guestemail');
    await sp.setString('image url', Config().guestUserImage);
    await sp.setString('uid', 'guestuid');
  }

  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestUser = sp.getBool('guest user') ?? false;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future guestSignout() async {
    _guestUser = false;
    await clearAllData();
    notifyListeners();
  }
}
