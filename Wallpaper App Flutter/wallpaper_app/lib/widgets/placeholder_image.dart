import 'package:flutter/material.dart';

Widget placeHolderImage(imageUrl) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey[400]!, blurRadius: 2, offset: const Offset(2, 2))
        ],
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)),
    child: Center(child: Icon(Icons.image, size: 35, color: Colors.grey[500])),
  );
}
