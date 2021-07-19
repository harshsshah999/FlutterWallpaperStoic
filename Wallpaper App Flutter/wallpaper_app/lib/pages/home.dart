import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/blocs/ads_bloc.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/models/providermodel.dart';
import 'package:wallpaper_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import 'dart:io';
import '../models/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/details.dart';
import '../pages/explore.dart';
import '../pages/internet.dart';
import '../widgets/drawer.dart';
import '../widgets/loading_animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//NEW ADDED
import '../utils/snacbar.dart';

import 'dart:math';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as testingCache;



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

String URL;
final contentRef = Firestore.instance.collection('contents');
List DocList = [];
FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection('users');

final int helloAlarmID = 0;

String _alarmDuration;
const Durations = [
  '15 minutes',
  '30 minutes',
  '60 minutes',
  '12 hours',
  '24 hours'
];

String _locationToSet;
const Locations = ['Home', 'Lock', 'Both'];

String _wallpapers;
const Wallpapers = ['Random', 'Saved'];

void initializeSetting() async {
  var initializeAndroid = AndroidInitializationSettings('icon_stoic');
  var initializeSetting = InitializationSettings(android: initializeAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializeSetting);
}


Future<void> displayNotification(String title, String body) async {
  flutterLocalNotificationsPlugin.show(0, title, body,  NotificationDetails(
    android: AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',priority: Priority.high),
  ),);
}
getUsers() async {

  bool internetConnected=true;
  initializeSetting();
  try {
    final result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      internetConnected=true;
    }else{

    }
  } on SocketException catch (_) {
  print('not connected');
  internetConnected=false;
  await displayNotification("No internet connection!", "Could not change wallpaper");

  }


  final prefs = await SharedPreferences.getInstance();
  _wallpapers = prefs.get("_wallpapers");
  print("hello "+_wallpapers.toString());
  if (_wallpapers.toString() == "Random" && internetConnected) {
    print("random block");
    contentRef.getDocuments().then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
        DocList.add(documentSnapshot.documentID);
      });
      Random random = new Random();
      int num = random.nextInt(DocList.length);
      print(DocList.elementAt(num));
      contentRef.document(DocList.elementAt(num)).get().then((snapshot) async {
        URL = snapshot.data['image url'].toString();
        print(URL + " : " + DateTime.now().toString());
        int location;
        _locationToSet = prefs.get("_location");
        if (_locationToSet ==  'Home') {
          location = WallpaperManager.HOME_SCREEN;
        } else if (_locationToSet == 'Lock') {
          location = WallpaperManager.LOCK_SCREEN;
        } else if (_locationToSet == 'Both') {
          location = WallpaperManager.BOTH_SCREENS;
        }
        var file = await testingCache.DefaultCacheManager().getSingleFile(URL);
        WallpaperManager.setWallpaperFromFile(file.path, location);
      });
    });
  } else if (_wallpapers.toString() == "Saved" && internetConnected) {
    print("saved block");
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    var uid = firebaseUser.uid;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    var savedList = documentSnapshot.data['loved items'];
    if (savedList.length == 0) {
      _wallpapers = "Random";
      getUsers();
    } else if(internetConnected) {
      print("default block");
      Random random = new Random();
      int num = random.nextInt(savedList.length);
      contentRef
          .document(savedList.elementAt(num))
          .get()
          .then((snapshot) async {
        print(savedList.elementAt(num));
        URL = snapshot.data['image url'].toString();
        print(URL + " : " + DateTime.now().toString());
        int location;
        _locationToSet = prefs.get("_location");
        if (_locationToSet ==  'Home') {
          location = WallpaperManager.HOME_SCREEN;
        } else if (_locationToSet == 'Lock') {
          location = WallpaperManager.LOCK_SCREEN;
        } else if (_locationToSet == 'Both') {
          location = WallpaperManager.BOTH_SCREENS;
        }
        var file = await testingCache.DefaultCacheManager().getSingleFile(URL);
        WallpaperManager.setWallpaperFromFile(file.path, location);
      });
    }
    print("end");
  }
}

void printHello(bool isSet, var _scaffoldKey) async {
  await AndroidAlarmManager.initialize();
  final prefs = await SharedPreferences.getInstance();
  if (isSet) {
    if (_alarmDuration == "15 minutes") {
      await AndroidAlarmManager.periodic(
          const Duration(minutes: 15), helloAlarmID, getUsers);
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 15 minutes');
    }
    else if (_alarmDuration == "15 seconds") {
      await AndroidAlarmManager.periodic(
          const Duration(seconds: 15), helloAlarmID, getUsers );
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 15 seconds');
    }
    else if (_alarmDuration == "30 minutes") {
      await AndroidAlarmManager.periodic(
          const Duration(minutes: 30), helloAlarmID, getUsers,);
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 30 minutes');
    } else if (_alarmDuration == "60 minutes") {
      await AndroidAlarmManager.periodic(
          const Duration(minutes: 60), helloAlarmID, getUsers, );
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 60 minutes');
    } else if (_alarmDuration == "12 hours") {
      await AndroidAlarmManager.periodic(
          const Duration(hours: 12), helloAlarmID, getUsers, );
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 12 hours');
    } else {
      await AndroidAlarmManager.periodic(
          const Duration(hours: 24), helloAlarmID, getUsers, );
      openSnacbar(_scaffoldKey, 'Auto Wallpaper On, Interval: 24 hours');
    }
    getUsers();
    prefs.setBool("isAlarmOn", true);
  } else if (!isSet) {
    prefs.setBool("isAlarmOn", false);
    await AndroidAlarmManager.cancel(helloAlarmID);
  }
}

//NEW ADDED

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int listIndex = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  //-------admob--------
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  initAdmobAd() {
    FirebaseAdMob.instance.initialize(appId: Config().admobAppId);
    context.read<AdsBloc>().loadAdmobInterstitialAd();
  }

  Future<void> OpenAlert(var prod) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Auto Wallpaper Changer"),
            content: Text(
                "This is a paid feature of the app, kindly purchase to enable it"),
            actions: [
              TextButton(
                  onPressed: () {
                    _buyProduct(prod);
                  },
                  child: Text("Purchase")),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"))
            ],
          );
        });
  }

  Future<void> ChangerAlert(var _scaffoldKey) async {
    var prefs = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    if (firebaseUser == null) {
      openSnacbar(_scaffoldKey, "Please login to use this feature");
    } else {
      if (prefs.getBool("isAlarmOn") == null) {
        prefs.setBool("isAlarmOn", false);
      }
      if (prefs.getBool("isAlarmOn")) {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Auto Wallpaper Changer"),
                content: Text("Turn off auto wallpaper changer?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        printHello(false, _scaffoldKey);
                        Navigator.pop(context);
                      },
                      child: Text("Yes")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel")),
                ]);
          },
        );
      } else {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Auto Wallpaper Changer"),
                content: Wrap(children: [
                  Text("Turn on auto wallpaper changer?"),
                  durationDropdown(),
                  locationDropdown(),
                  wallpaperDropdown()
                ]),
                actions: [
                  TextButton(
                      onPressed: () {
                        if (_alarmDuration == null ||
                            _locationToSet == null ||
                            _wallpapers == null) {
                        } else {
                          printHello(true, _scaffoldKey);
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Yes")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel")),
                ]);
          },
        );
      }
    }
  }

  Widget durationDropdown() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Select Interval"),
                  value: _alarmDuration,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      _alarmDuration = newValue;
                    });
                  },
                  items: Durations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget locationDropdown() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Select Location"),
                  value: _locationToSet,
                  isDense: true,
                  onChanged: (newValue) async {
                    setState(() {
                      _locationToSet = newValue;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("_location", newValue);
                  },
                  items: Locations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget wallpaperDropdown() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Select Wallpaper"),
                  value: _wallpapers,
                  isDense: true,
                  onChanged: (newValue) async {
                    setState(() {
                      _wallpapers = newValue;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString("_wallpapers", newValue);
                  },
                  items: Wallpapers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  //------fb-------

  // initFbAd (){
  //   context.read<AdsBloc>().loadFbAd();
  // }

  @override
  void initState() {
    initializeSetting();
    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final ub = context.read<UserBloc>();
      ub.getUserData();
    });
    initAdmobAd(); //-------admob--------
    //initFbAd();              //-------fb--------
    OneSignal.shared.init(Config().onesignalAppId);
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.initialize();

    super.initState();
  }




  @override
  void dispose() {
    // TODO: implement dispose
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.subsription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final db = context.watch<DataBloc>();
    final ub = context.watch<UserBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();
    final pm = Provider.of<ProviderModel>(context);

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
                                    image: CachedNetworkImageProvider(
                                        context.watch<UserBloc>().imageUrl))),
                          ),
                          onTap: () {
                            sb.guestUser == true
                                ? showGuestUserInfo(
                                    context, ub.userName, ub.email, ub.imageUrl)
                                : showUserInfo(context, ub.userName, ub.email,
                                    ub.imageUrl);
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
                                                        child: Column(
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
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.7),
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
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
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.undo,
                            color: Colors.grey[600], size: 20),
                        onPressed: () {
                          for (var prod in pm.products) {
                            if (pm.hasPurchased(prod.id) != null) {
                              ChangerAlert(_scaffoldKey);
                            } else {
                              OpenAlert(prod);
                            }
                          }
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
