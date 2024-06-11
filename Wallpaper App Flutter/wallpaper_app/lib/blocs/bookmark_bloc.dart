import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookmarkBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Retrieves data from Firestore based on a list of bookmarks.
  Future<List<DocumentSnapshot>> getData(List bookmarkedList) async {
    print('Main list length: ${bookmarkedList.length}');

    /// List to store all retrieved documents.
    final List<DocumentSnapshot> allDocs = [];

    /// Define the chunk size for retrieving data in parts.
    final int chunkSize = 10;

    if (bookmarkedList.length <= chunkSize) {
      /// Handle case where the list size is less than or equal to chunk size.
      final querySnapshot = await firestore
          .collection('contents')
          .where('timestamp', whereIn: bookmarkedList)
          .get();
      allDocs.addAll(querySnapshot.docs);
    } else {
      /// Handle case where the list size is greater than chunk size.
      final chunks = List.generate(
          (bookmarkedList.length / chunkSize).ceil(),
          (i) => bookmarkedList.sublist(i * chunkSize,
              min(i * chunkSize + chunkSize, bookmarkedList.length)));

      /// Use Future.wait to perform Firestore queries for all chunks concurrently.
      await Future.wait(chunks.map((chunk) async {
        final querySnapshot = await firestore
            .collection('contents')
            .where('timestamp', whereIn: chunk)
            .get();
        allDocs.addAll(querySnapshot.docs);
      }));
    }

    return allDocs;
  }
}
