import 'package:flutter/material.dart';
import 'package:wallpaper_app/widgets/new_items.dart';
import 'package:wallpaper_app/widgets/popular_items.dart';
class ExplorePage extends StatefulWidget {

  ExplorePage({Key key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  


  ScrollController scrollController;
  var scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: scaffoldKey,
              body: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
              return <Widget>[
                SliverAppBar(
                  centerTitle: false,
                  titleSpacing: 0,
                  title: Text('Explore'),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxScrolled,
                  elevation: 2,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(35),
                                      child: TabBar(        
                      labelStyle: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                      tabs: <Widget>[
                        Tab(
                          
                          child: Text('Popular'),
                        ),
                        Tab(
                          child: Text(
                            'New',
                          ),
                        )
                      ],
                      labelColor: Colors.black,
                      indicatorColor: Colors.grey[900],
                      unselectedLabelColor: Colors.grey,
                    ),
                  ),
                )
              ];
            },
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      
                      PopularItems(),

                      NewItems()


                    
                    
                    ],
                  ),
                ),
              ],
            ),
          )),
        ));
  }

}





