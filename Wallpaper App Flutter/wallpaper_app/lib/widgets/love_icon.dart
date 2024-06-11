import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stoicwallpaper/blocs/sign_in_bloc.dart';
import 'package:stoicwallpaper/models/icon_data.dart';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

//function to show icon is liked/bookmarked or not
Widget buildLoveIcon(uid,BuildContext context,String timestamp) {
    final sb = context.watch<SignInBloc>();
    if (sb.guestUser == false) {
      return StreamBuilder(
        stream: firestore.collection('users').doc(uid).snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) return LoveIcon().greyIcon;
          List d = snap.data['loved items'];

          if (d.contains(timestamp)) {
            return LoveIcon().pinkIcon;
          } else {
            return LoveIcon().greyIcon;
          }
        },
      );
    } else {
      return LoveIcon().greyIcon;
    }
  }