import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:stoicwallpaper/blocs/sign_in_bloc.dart';
import 'package:stoicwallpaper/models/config.dart';
import 'package:stoicwallpaper/pages/details.dart';
import 'package:stoicwallpaper/pages/empty_page.dart';
import 'package:stoicwallpaper/widgets/cached_image.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key, required this.userUID});
  final String? userUID;

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  Future<List> _getData(List bookmarkedList) async {
    print('main list: ${bookmarkedList.length}]');

    List d = [];
    if (bookmarkedList.length <= 10) {
      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: bookmarkedList)
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs);
      });
    } else if (bookmarkedList.length > 10) {
      int size = 10;
      var chunks = [];

      for (var i = 0; i < bookmarkedList.length; i += size) {
        var end = (i + size < bookmarkedList.length)
            ? i + size
            : bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i, end));
      }

      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: chunks[0])
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs);
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[1])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
        });
      });
    } else if (bookmarkedList.length > 20) {
      int size = 10;
      var chunks = [];

      for (var i = 0; i < bookmarkedList.length; i += size) {
        var end = (i + size < bookmarkedList.length)
            ? i + size
            : bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i, end));
      }

      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: chunks[0])
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs);
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[1])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
        });
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[2])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
        });
      });
    }

    return d;
  }

  @override
  Widget build(BuildContext context) {
    const String collectionName = 'users';
    const String snapText = 'loved items';

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Items')),
      body: context.read<SignInBloc>().guestUser == true ||
              widget.userUID == null
          ? const EmptyPage(
              icon: FontAwesomeIcons.heart,
              title: 'No wallpapers found.\n Sign in to access this feature',
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(collectionName)
                  .doc(widget.userUID!)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snap) {
                if (!snap.hasData) return const CircularProgressIndicator();

                List bookamrkedList = snap.data[snapText];
                return FutureBuilder(
                    future: _getData(bookamrkedList),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData) {
                        return const EmptyPage(
                          icon: FontAwesomeIcons.heart,
                          title: 'No wallpapers found',
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error'),
                        );
                      } else {
                        return _buildList(snapshot);
                      }
                    });
              },
            ),
    );
  }

  Widget _buildList(snapshot) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        List d = snapshot.data;

        return InkWell(
          child: Stack(
            children: <Widget>[
              Hero(
                  tag: 'bookmark$index',
                  child: cachedImage(d[index]['image url'])),
              Positioned(
                bottom: 30,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Config().hashTag,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      d[index]['category'],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 20,
                child: Row(
                  children: [
                    Icon(Icons.favorite,
                        color: Colors.white.withOpacity(0.5), size: 25),
                    Text(
                      d[index]['loves'].toString(),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(
                          tag: 'bookmark$index',
                          imageUrl: d[index]['image url'],
                          catagory: d[index]['category'],
                          timestamp: d[index]['timestamp'],
                        )));
          },
        );
      },
      staggeredTileBuilder: (int index) =>
          StaggeredTile.count(2, index.isEven ? 4 : 3),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: const EdgeInsets.all(15),
    );
  }
}
