import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/blocs/ads_bloc.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/details.dart';
import '../pages/explore.dart';
import '../pages/internet.dart';
import '../widgets/drawer.dart';
import '../widgets/loading_animation.dart';




class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  

  //-------admob--------

  initAdmobAd (){
    FirebaseAdMob.instance.initialize(appId: Config().admobAppId);
    context.read<AdsBloc>().loadAdmobInterstitialAd();
  }



  //------fb-------

  // initFbAd (){
  //   context.read<AdsBloc>().loadFbAd();
  // }



  


  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final ub = context.read<UserBloc>();
      ub.getUserData();
    });
    initAdmobAd();          //-------admob--------
    //initFbAd();              //-------fb--------
    OneSignal.shared.init(Config().onesignalAppId);      
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final db = context.watch<DataBloc>();
    final ub = context.watch<UserBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return ib.hasInternet == false
        ? NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            endDrawer: DrawerWidget(),
            body: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(
                      top: 30,
                      left: 30,
                      right: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    height: 110,
                    child: Row(
                      children: <Widget>[
                        Text(
                          Config().appName,
                          style: TextStyle(
                              fontSize: 27,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                        Spacer(),
                        InkWell(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(context.watch<UserBloc>().imageUrl)
                                    
                                  )),
                          ),
                          onTap: () {
                            sb.guestUser == true
                            ? showGuestUserInfo(context, ub.userName, ub.email, ub.imageUrl) 
                            : showUserInfo(context, ub.userName, ub.email, ub.imageUrl);
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.stream,
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState.openEndDrawer();
                          },
                        )
                      ],
                    )),
                Stack(
                  children: <Widget>[
                    CarouselSlider(
                      realPage: 0,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      onPageChanged: (index) {
                        setState(() {
                          listIndex = index;
                        });
                      },
                      height: h * 0.70,
                      enlargeCenterPage: true,
                      viewportFraction: 0.90,
                      items: db.alldata.length == 0
                          ? [0, 1].take(1).map((f) => LoadingWidget()).toList()
                          : db.alldata.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: InkWell(
                                        child: CachedNetworkImage(
                                          imageUrl: i['image url'],
                                          imageBuilder:
                                              (context, imageProvider) => Hero(
                                            tag: i['timestamp'],
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  top: 10,
                                                  bottom: 50),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(
                                                        color: Colors.grey[300],
                                                        blurRadius: 30,
                                                        offset: Offset(5, 20))
                                                  ],
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover)),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30, bottom: 40),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: <Widget>[
                                                      Flexible(


                                                      child:Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            Config().hashTag,
                                                            style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14),
                                                          ),
                                                          Text(
                                                            i['category'],
                                                            style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          )
                                                        ],
                                                      ),
                                              ),
                                                     Spacer(),
                                                      Icon(
                                                        Icons.favorite,
                                                        size: 25,
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        i['loves'].toString(),
                                                    style: TextStyle(
                                                    decoration: TextDecoration.none,
                                                    color: Colors.white.withOpacity(0.7), 
                                                    fontSize: 18, 
                                                    fontWeight: FontWeight.w600),
                                                  ),
                                                      SizedBox(
                                                        width: 15,
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              LoadingWidget(),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            size: 40,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsPage(
                                                          tag: i['timestamp'],
                                                          imageUrl:
                                                              i['image url'],
                                                          catagory:
                                                              i['category'],
                                                          timestamp:
                                                              i['timestamp'])));
                                        },
                                      ));
                                },
                              );
                            }).toList(),
                    ),
                    Positioned(
                      top: 40,
                      left: w * 0.23,
                      child: Text(
                        'WALL OF THE DAY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      left: w * 0.34,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: DotsIndicator(
                          dotsCount: 5,
                          position: listIndex.toDouble(),
                          decorator: DotsDecorator(
                            activeColor: Colors.black,
                            color: Colors.black,
                            spacing: EdgeInsets.all(3),
                            size: const Size.square(8.0),
                            activeSize: const Size(40.0, 6.0),
                            activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Container(
                  height: 50,
                  width: w * 0.80,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(FontAwesomeIcons.dashcube,
                            color: Colors.grey[600], size: 20),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CatagoryPage()));
                        },
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.solidCompass,
                            color: Colors.grey[600], size: 20),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExplorePage()));
                        },
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.solidHeart,
                            color: Colors.grey[600], size: 20),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookmarkPage()));
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          );
  }
}
