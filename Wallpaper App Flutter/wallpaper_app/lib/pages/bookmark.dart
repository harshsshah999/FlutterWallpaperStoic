import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/models/config.dart';
import 'package:wallpaper_app/pages/details.dart';
import 'package:wallpaper_app/pages/empty_page.dart';
import 'package:wallpaper_app/widgets/cached_image.dart';

class FavouritePage extends StatefulWidget {
  FavouritePage({Key? key, required this.userUID}) : super(key: key);
  final String? userUID;

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  
  
  


  Future<List> _getData (List bookmarkedList)async {
    print('main list: ${bookmarkedList.length}]');

    List d = [];
    if(bookmarkedList.length <= 10){
      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: bookmarkedList)
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
      });

    }else if(bookmarkedList.length > 10){

      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
        });
      });

    }else if(bookmarkedList.length > 20){

      int size = 10;
      var chunks = [];

      for(var i = 0; i< bookmarkedList.length; i+= size){    
        var end = (i+size<bookmarkedList.length)?i+size:bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i,end));
      }

      await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[0])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
      }).then((value)async{
        await FirebaseFirestore.instance
        .collection('contents')
        .where('timestamp', whereIn: chunks[1])
        .get()
        .then((QuerySnapshot snap) {
          d.addAll(snap.docs);
        });
      }).then((value)async{
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

    final String _collectionName = 'users';
    final String _snapText = 'loved items';


    return Scaffold(
      appBar: AppBar(title: Text('Saved Items')),
      body: 
      
      context.read<SignInBloc>().guestUser == true || widget.userUID == null
      ? EmptyPage(
          icon: FontAwesomeIcons.heart,
          title: 'No wallpapers found.\n Sign in to access this feature',
        ) 
      : StreamBuilder(
          stream: FirebaseFirestore.instance.collection(_collectionName).doc(widget.userUID!).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snap) {
            if (!snap.hasData) return CircularProgressIndicator();
            
            List bookamrkedList = snap.data[_snapText];
            return FutureBuilder(
              future: _getData(bookamrkedList),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator());
                }else if (snapshot.hasError){
                  return Center(child: Text('Error'),);
                }else if (snapshot.hasData && snapshot.data.length == 0){
                  return EmptyPage(icon: FontAwesomeIcons.heart,title: 'No wallpapers found',);
                }else{
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
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      d[index]['category'],
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
      staggeredTileBuilder: (int index) => new StaggeredTile.count(2, index.isEven ? 4 : 3),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(15),
    );
  }
}
