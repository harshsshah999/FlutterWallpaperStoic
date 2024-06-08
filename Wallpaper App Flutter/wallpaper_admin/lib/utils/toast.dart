import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//sort length
void openToast(context, message) {
  //Toast.show(message, context, textColor: Colors.white, backgroundRadius: 20, duration: Toast.LENGTH_SHORT);
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

//long length
void openToast1(context, message) {
  //Toast.show(message, context, textColor: Colors.white, backgroundRadius: 20, duration: Toast.LENGTH_LONG);
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
