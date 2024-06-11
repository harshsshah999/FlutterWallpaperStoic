import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Handles the click event on the love icon.
  ///
  /// This method updates the 'loved items' list for the user and the 'loves' count for the content.
  ///
  /// [context] - The BuildContext of the widget.
  /// [timestamp] - The timestamp of the content.
  /// [uid] - The unique identifier of the user.

  handleLoveIconClick(context, timestamp, uid) async {
    final DocumentReference ref = firestore.collection('users').doc(uid);
    final DocumentReference ref1 =
        firestore.collection('contents').doc(timestamp);

    // Get the current user data and content data from Firestore
    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();

    // Retrieve the 'loved items' list and 'loves' count
    List d = snap['loved items'];
    int? loves = snap1['loves'];

    // Check if the item is already loved by the user
    if (d.contains(timestamp)) {
      // If loved, remove the item from the 'loved items' list and decrement the 'loves' count
      List a = [timestamp];
      await ref.update({'loved items': FieldValue.arrayRemove(a)});
      ref1.update({'loves': loves! - 1});
    } else {
      // If not loved, add the item to the 'loved items' list and increment the 'loves' count
      d.add(timestamp);
      await ref.update({'loved items': FieldValue.arrayUnion(d)});
      ref1.update({'loves': loves! + 1});
    }

    notifyListeners();
  }
}
