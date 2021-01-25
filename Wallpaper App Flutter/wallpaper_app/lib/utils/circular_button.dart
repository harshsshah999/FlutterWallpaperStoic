import 'package:flutter/material.dart';

Widget circularButton(icon, color) {
  return Container(
    height: 45,
    width: 45,
    decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        ),
    child: Icon(
      icon,
      color: Colors.white,
    ),
  );
}
