// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:stoicwallpaper/blocs/internet_bloc.dart';
// import 'package:stoicwallpaper/models/config.dart';

// final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Widget panelUI(db, PanelController pc, Icon dropIcon, String category,
//     String timestamp, BuildContext context, String imageUrl) {
//   return Container(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         InkWell(
//           child: Container(
//             padding: const EdgeInsets.only(top: 10),
//             width: double.infinity,
//             child: CircleAvatar(
//               backgroundColor: Colors.grey[800],
//               child: dropIcon,
//             ),
//           ),
//           onTap: () {
//             pc.isPanelClosed ? pc.open() : pc.close();
//           },
//         ),
//         const SizedBox(
//           height: 5,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 20),
//           child: Row(
//             children: <Widget>[
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     Config().hashTag,
//                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   ),
//                   Text(
//                     '$category Wallpaper',
//                     style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600),
//                   )
//                 ],
//               ),
//               const Spacer(),
//               Row(
//                 children: <Widget>[
//                   const Icon(
//                     Icons.favorite,
//                     color: Colors.pinkAccent,
//                     size: 22,
//                   ),
//                   StreamBuilder(
//                     stream: firestore
//                         .collection('contents')
//                         .doc(timestamp)
//                         .snapshots(),
//                     builder: (context, AsyncSnapshot snap) {
//                       if (!snap.hasData) return _buildLoves(0);
//                       return _buildLoves(snap.data['loves']);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 30,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               Column(
//                 children: <Widget>[
//                   InkWell(
//                     child: Container(
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                           color: Colors.blueAccent,
//                           shape: BoxShape.circle,
//                           boxShadow: <BoxShadow>[
//                             BoxShadow(
//                                 color: Colors.grey[400]!,
//                                 blurRadius: 10,
//                                 offset: const Offset(2, 2))
//                           ]),
//                       child: const Icon(
//                         Icons.format_paint,
//                         color: Colors.white,
//                       ),
//                     ),
//                     onTap: () async {
//                       final ib = context.read<InternetBloc>();
//                       await context.read<InternetBloc>().checkInternet();
//                       if (ib.hasInternet == false) {
//                         progress =
//                             'Check your internet connection!';
//                       } else {
//                         wallpaperBloc.openSetDialog(context, imageUrl);

//                         // if (RewardedAd == null) {
//                         //   openSetDialog();
//                         //   loadRewardAd();
//                         //   // final snackBar = SnackBar(
//                         //   //   content: const Text('Please Try After 10 Sec'),
//                         //   //   action: SnackBarAction(
//                         //   //     label: 'OK',
//                         //   //     onPressed: () {
//                         //   //       // Some code to undo the change.
//                         //   //     },
//                         //   //   ),
//                         //   // );
//                         //   //
//                         //   // // Find the ScaffoldMessenger in the widget tree
//                         //   // // and use it to show a SnackBar.
//                         //   // ScaffoldMessenger.of(context)
//                         //   //     .showSnackBar(snackBar);
//                         // } else {
//                         //   showRewardAd('wl');
//                         // }
//                       }
//                     },
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Text(
//                     'Set Wallpaper',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w600),
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               Column(
//                 children: <Widget>[
//                   InkWell(
//                     child: Container(
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                           color: Colors.pinkAccent,
//                           shape: BoxShape.circle,
//                           boxShadow: <BoxShadow>[
//                             BoxShadow(
//                                 color: Colors.grey[400]!,
//                                 blurRadius: 10,
//                                 offset: const Offset(2, 2))
//                           ]),
//                       child: const Icon(
//                         Icons.donut_small,
//                         color: Colors.white,
//                       ),
//                     ),
//                     onTap: () {
//                       // if (_rewardedAd != null) {
//                       //   showRewardAd('dl');
//                       // } else {
//                       wallpaperBloc.handleStoragePermission(imageUrl, context);
//                       debugPrint('Downloading');
//                       // }
//                     },
//                   ),
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   Text(
//                     'Watch Ads to Download',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w600),
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//             ],
//           ),
//         ),
//         const Spacer(),
//         Padding(
//             padding: const EdgeInsets.only(left: 20, right: 10),
//             child: Row(
//               children: <Widget>[
//                 Container(
//                   width: 5,
//                   height: 30,
//                   color: Colors.blueAccent,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     wallpaperBloc.progress,
//                     style: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             )),
//         const SizedBox(
//           height: 40,
//         )
//       ],
//     ),
//   );
// }

// Widget _buildLoves(loves) {
//   return Text(
//     loves.toString(),
//     style: const TextStyle(color: Colors.black54, fontSize: 16),
//   );
// }
