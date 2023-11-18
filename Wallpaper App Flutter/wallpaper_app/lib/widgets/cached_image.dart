import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../widgets/loading_animation.dart';

Widget cachedImage(imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[400]!, blurRadius: 2, offset: Offset(2, 2))
          ],
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
    ),
    placeholder: (context, url) => LoadingWidget1(),
    errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
  );
}
