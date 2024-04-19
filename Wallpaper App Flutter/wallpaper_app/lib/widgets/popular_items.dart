import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallpaper_app/models/config.dart';
import 'package:wallpaper_app/pages/details.dart';
import 'package:wallpaper_app/widgets/cached_image.dart';

class PopularItems extends StatefulWidget {
  PopularItems({Key? key}) : super(key: key);

  @override
  _PopularItemsState createState() => _PopularItemsState();
}

class _PopularItemsState extends State<PopularItems> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ScrollController controller= ScrollController();
  DocumentSnapshot? _lastVisible;
  // bool? _isLoading=false;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  List<DocumentSnapshot>? _data;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = ValueNotifier<bool>(true);
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection('contents')
          .orderBy('loves', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection('contents')
          .orderBy('loves', descending: true)
          .startAfter([_lastVisible!['loves']])
          .limit(10)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading =  ValueNotifier<bool>(false);
          _data!.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading =  ValueNotifier<bool>(false));
      if (scaffoldKey.currentContext != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('No more posts!'),
          ),
        );
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading.value) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading =  ValueNotifier<bool>(false));
        _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              // mainAxisExtent: _data[index]['height']?.toDouble() ?? 200.0, // Adjust based on your data
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _data!.length,
            itemBuilder: (BuildContext context, int index) {
              if (_isLoading.value) {
                return Center(
                  child: new Opacity(
                    opacity: _isLoading.value ? 1.0 : 0.0,
                    child: new SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                );
              }
              if (index < _data!.length) {
                final DocumentSnapshot d = _data![index];
                // ... rest of your code for building the item ...
                return InkWell(
                  child: Stack(
                    children: <Widget>[
                      Hero(
                          tag: 'popular$index',
                          child: cachedImage(d['image url'])),
                      Positioned(
                        bottom: 30,
                        left: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Config().hashTag,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                              d['category'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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
                                  tag: 'popular$index',
                                  imageUrl: d['image url'],
                                  catagory: d['category'],
                                  timestamp: d['timestamp'],
                                )));
                  },
                );
              }
            },
            padding: EdgeInsets.all(15),
          ),
        ),
        // Expanded(
        //   child: StaggeredGridView.countBuilder(
        //     controller: controller,
        //     crossAxisCount: 4,
        //     itemCount: _data.length + 1,
        //     itemBuilder: (BuildContext context, int index){

        //     if(index < _data.length){
        //       final DocumentSnapshot d = _data[index];
        //   return InkWell(
        //   child: Stack(
        //     children: <Widget>[
        //       Hero(
        //           tag: 'popular$index',
        //           child: cachedImage(d['image url'])),
        //       Positioned(
        //         bottom: 30,
        //         left: 10,
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: <Widget>[
        //             Text(
        //               Config().hashTag,
        //               style: TextStyle(color: Colors.white, fontSize: 14),
        //             ),
        //             Text(
        //               d['category'],
        //               style: TextStyle(color: Colors.white, fontSize: 18),
        //             )
        //           ],
        //         ),
        //       ),
        //       Positioned(
        //         right: 10,
        //         top: 20,
        //         child: Row(
        //           children: [
        //             Icon(Icons.favorite,
        //                 color: Colors.white.withOpacity(0.5), size: 25),
        //             Text(
        //               d['loves'].toString(),
        //               style: TextStyle(
        //                   color: Colors.white.withOpacity(0.7),
        //                   fontSize: 16,
        //                   fontWeight: FontWeight.w600),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        //   onTap: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => DetailsPage(
        //                   tag: 'popular$index',
        //                   imageUrl: d['image url'],
        //                   catagory: d['category'],
        //                   timestamp: d['timestamp'],
        //                 )));
        //   },
        // );
        // }

        //     return Center(
        //               child: new Opacity(
        //                 opacity: _isLoading ? 1.0 : 0.0,
        //                 child: new SizedBox(
        //                     width: 32.0,
        //                     height: 32.0,
        //                     child: CupertinoActivityIndicator()),
        //               ),
        //             );

        //     },
        //     staggeredTileBuilder: (int index) =>
        //         new StaggeredTile.count(2, index.isEven ? 4 : 3),
        //     mainAxisSpacing: 10,
        //     crossAxisSpacing: 10,
        //     padding: EdgeInsets.all(15),
        //   ),
        // ),
      ],
    );
  }
}
