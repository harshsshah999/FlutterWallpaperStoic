import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stoicwallpaper/models/config.dart';
import 'package:stoicwallpaper/pages/details.dart';
import 'package:stoicwallpaper/utils/snacbar.dart';
import 'package:stoicwallpaper/widgets/cached_image.dart';

//This file is for the New Tab in the Explore section of the app

class NewItems extends StatefulWidget {
  const NewItems({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _NewItemsState createState() => _NewItemsState();
}

class _NewItemsState extends State<NewItems> with AutomaticKeepAliveClientMixin {



  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  final List<DocumentSnapshot> _data = [];

  @override
  void initState() {
    // Initialize scroll controller and add listener for pagination
    controller = ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

   // Fetch data from Firestore
  Future<void> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      // Fetch the next batch of documents after the last visible documen
      data = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    } else {
      // Fetch the next batch of documents after the last visible document
      data = await firestore
          .collection('contents')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(10)
          .get();
    }

    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      openSnacbar(widget.scaffoldKey, 'No more contents!');
    }
    return;
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }


  // Listener for scroll events to implement infinite scroll/pagination
  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: StaggeredGridView.countBuilder(
            controller: controller,
            crossAxisCount: 4,
            itemCount: _data.length + 1,
            itemBuilder: (BuildContext context, int index){ 
            // Displaying item for each index of list
            if(index < _data.length){
              final DocumentSnapshot d = _data[index];
              return InkWell(
              child: Stack(
                children: <Widget>[
                  Hero(
                      tag: 'new$index',
                      child: cachedImage(d['image url'])),
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
                          d['category'],
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
                          d['loves'].toString(),
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
                              tag: 'new$index',
                              imageUrl: d['image url'],
                              category: d['category'],
                              timestamp: d['timestamp'],
                            )));
              },
            );
            }

            // Loading indicator at the end of the list
            return Center(
                      child: Opacity(
                        opacity: _isLoading ? 1.0 : 0.0,
                        child: const SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CupertinoActivityIndicator()),
                      ),
                    );
            
            
            },
            staggeredTileBuilder: (int index) =>
                StaggeredTile.count(2, index.isEven ? 4 : 3),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;



  
}
