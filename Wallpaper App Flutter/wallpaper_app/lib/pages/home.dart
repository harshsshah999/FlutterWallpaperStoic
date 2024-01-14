// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_power_manager/android_power_manager.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:stoicwallpaper/blocs/ads_bloc.dart';
import 'package:stoicwallpaper/blocs/sign_in_bloc.dart';
import 'package:stoicwallpaper/main.dart';
import 'package:stoicwallpaper/models/providermodel.dart';
import 'package:stoicwallpaper/utils/dialog.dart';
import '../blocs/data_bloc.dart';

import '../blocs/internet_bloc.dart';
// import 'package:power/power.dart';
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

import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as testingCache;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? URL;
final contentRef = FirebaseFirestore.instance.collection('contents');
List DocList = [];
FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final userRef = FirebaseFirestore.instance.collection('users');

const int helloAlarmID = 0;

String? _alarmDuration;
const Durations = [
  '15 minutes',
  '30 minutes',
  '60 minutes',
  '12 hours',
  '24 hours'
];

String? _locationToSet;
const Locations = ['Home', 'Lock', 'Both'];

String? _wallpapers;
const Wallpapers = ['Random', 'Saved'];

void initializeSetting() async {
  var initializeAndroid = const AndroidInitializationSettings('ic');
  var initializeSetting = InitializationSettings(android: initializeAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializeSetting);

}

Future<void> displayNotification(String title, String body) async {
  flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    const NotificationDetails(android: AndroidNotificationDetails('channel id', 'channel name', priority: Priority.high))
  );
}

checkInternetConnected() async {
  bool internetConnected = true;
  initializeSetting();
  await Firebase.initializeApp();
  try {
    final result = await InternetAddress.lookup("google.com");
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      internetConnected = true;
    } else {}
  } on SocketException catch (_) {
    print('not connected');
    internetConnected = false;
    await displayNotification(
        "No internet connection!", "Could not change wallpaper");
  }

  // final prefs = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  box = await Hive.openBox('box');
  _wallpapers = box.get("_wallpapers") as String?;
  debugPrint("hello $_wallpapers");
  if (_wallpapers.toString() == "Random" && internetConnected) {
    debugPrint("random block");
    contentRef.get().then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        DocList.add(documentSnapshot.id);
      }
      Random random = Random();
      int num = random.nextInt(DocList.length);
      debugPrint(DocList.elementAt(num));
      contentRef.doc(DocList.elementAt(num)).get().then((snapshot) async {
        URL = snapshot.data()!['image url'].toString();
        debugPrint("${URL!} : ${DateTime.now()}");
        int? location;
        _locationToSet = box.get("_location") as String?;
        // _locationToSet = prefs.get("_location") as String?;
        if (_locationToSet == 'Home') {
          location = WallpaperManager.HOME_SCREEN;
        } else if (_locationToSet == 'Lock') {
          location = WallpaperManager.LOCK_SCREEN;
        } else if (_locationToSet == 'Both') {
          location = WallpaperManager.BOTH_SCREEN;
        }
        var file = await testingCache.DefaultCacheManager().getSingleFile(URL!);
        WallpaperManager.setWallpaperFromFile(file.path, location!);
      });
    });
  } else if (_wallpapers.toString() == "Saved" && internetConnected) {
    debugPrint("saved block");
    User firebaseUser = _firebaseAuth.currentUser!;
    var uid = firebaseUser.uid;
    DocumentSnapshot documentSnapshot = await userRef.doc(uid).get();
    var savedList = (documentSnapshot.data() as dynamic)['loved items'];
    if (savedList.length == 0) {
      _wallpapers = "Random";
      checkInternetConnected();
    } else if (internetConnected) {
      debugPrint("default block");
      Random random = Random();
      int num = random.nextInt(savedList.length);
      contentRef.doc(savedList.elementAt(num)).get().then((snapshot) async {
        debugPrint(savedList.elementAt(num));
        URL = snapshot.data()!['image url'].toString();
        debugPrint("${URL!} : ${DateTime.now()}");
        int? location;
        _locationToSet = box.get("_location") as String?;
        // _locationToSet = prefs.get("_location") as String?;
        if (_locationToSet == 'Home') {
          location = WallpaperManager.HOME_SCREEN;
        } else if (_locationToSet == 'Lock') {
          location = WallpaperManager.LOCK_SCREEN;
        } else if (_locationToSet == 'Both') {
          location = WallpaperManager.BOTH_SCREEN;
        }
        var file = await testingCache.DefaultCacheManager().getSingleFile(URL!);
        WallpaperManager.setWallpaperFromFile(file.path, location!);
      });
    }
    debugPrint("end");
  }
}

void setPeriodicWallpaperChange(bool isSet, var scaffoldKey) async {
  await AndroidAlarmManager.initialize();
  final prefs = await SharedPreferences.getInstance();
  if (isSet) {
    if (_alarmDuration == "15 minutes") {
      await AndroidAlarmManager.periodic(
          const Duration(minutes: 1), helloAlarmID, checkInternetConnected,
          exact: true, allowWhileIdle: true, rescheduleOnReboot: true);
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 15 minutes');
    } else if (_alarmDuration == "15 seconds") {
      await AndroidAlarmManager.periodic(
          const Duration(seconds: 15), helloAlarmID, checkInternetConnected);
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 15 seconds');
    } else if (_alarmDuration == "30 minutes") {
      await AndroidAlarmManager.periodic(
        const Duration(minutes: 30),
        helloAlarmID,
        checkInternetConnected,
      );
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 30 minutes');
    } else if (_alarmDuration == "60 minutes") {
      await AndroidAlarmManager.periodic(
        const Duration(minutes: 60),
        helloAlarmID,
        checkInternetConnected,
      );
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 60 minutes');
    } else if (_alarmDuration == "12 hours") {
      await AndroidAlarmManager.periodic(
        const Duration(hours: 12),
        helloAlarmID,
        checkInternetConnected,
      );
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 12 hours');
    } else {
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        helloAlarmID,
        checkInternetConnected,
      );
      openSnacbar(scaffoldKey, 'Auto Wallpaper On, Interval: 24 hours');
    }
    checkInternetConnected();
    prefs.setBool("isAlarmOn", true);
  } else if (!isSet) {
    prefs.setBool("isAlarmOn", false);
    await AndroidAlarmManager.cancel(helloAlarmID);
  }
}

//NEW ADDED

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ProviderModel providerModel;
  int listIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //-------admob--------
  // InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  bool _lowPowerMode = false;

  Future<void> initPowerState() async {
    bool lowPowerMode;

    try {
      lowPowerMode = true;
    } on PlatformException {
      lowPowerMode = false;
    }

    if (!mounted) return;

    setState(() {
      _lowPowerMode = lowPowerMode;
      print("low power mode: $_lowPowerMode");
    });
  }

  void batterySaverPermission() async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    print("status: $status");
    if (status.isGranted) {
      if (_alarmDuration == null ||
          _locationToSet == null ||
          _wallpapers == null) {
        print("null");
      } else {
        setPeriodicWallpaperChange(true, _scaffoldKey);
        Navigator.pop(context);
      }
    } else {
      AndroidPowerManager.requestIgnoreBatteryOptimizations();
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: const Text("Permission"),
      //         content: const Text(
      //             "Please allow the app in battery optimization mode to continue"),
      //         actions: [
      //           TextButton(
      //               onPressed: () {
      //                 // please turn off battery saver and battery optimizer
      //                 OpenSettings.openIgnoreBatteryOptimizationSetting();

      //                 if (kDebugMode) {
      //                   print("open battery saver");
      //                 }
      //               },
      //               child: const Text("Open Settings")),
      //           TextButton(
      //               onPressed: () => Navigator.pop(context),
      //               child: const Text("Ok")),
      //         ],
      //       );
      //     });

    }
  }

  final InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future initAdmobAd() async {
    await MobileAds.instance
        .initialize()
        .then((value) => context.read<AdsBloc>().loadAdmobInterstitialAd());
  }

  Future<void> OpenAlert(var prod) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Auto Wallpaper Changer"),
            content: const Text(
                "This is a paid feature of the app, kindly purchase to enable it"),
            actions: [
              TextButton(
                  onPressed: () {
                    _buyProduct(prod);
                  },
                  child: const Text("Purchase")),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  Future<void> changerAlert(var scaffoldKey) async {
    var prefs = await SharedPreferences.getInstance();
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      openSnacbar(scaffoldKey, "Please login to use this feature");
    } else {
      if (prefs.getBool("isAlarmOn") == null) {
        prefs.setBool("isAlarmOn", false);
      }
      if (prefs.getBool("isAlarmOn") ?? false) {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("Auto Wallpaper Changer"),
                content: const Text("Turn off auto wallpaper changer?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        setPeriodicWallpaperChange(false, scaffoldKey);
                        Navigator.pop(context);
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                ]);
          },
        );
      } else {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text("Auto Wallpaper Changer"),
                content: Wrap(children: [
                  const Text("Turn on auto wallpaper changer?"),
                  durationDropdown(),
                  locationDropdown(),
                  wallpaperDropdown(),
                  //disbale battery saver
                  const Text(
                      "Please Note:\nThat this feature requires internet & battery saver must be disabled"),
                ]),
                actions: [
                  TextButton(
                      onPressed: () {
                        batterySaverPermission();
                      },
                      child: const Text("Yes")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
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
                  hint: const Text("Select Interval"),
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
                  hint: const Text("Select Location"),
                  value: _locationToSet,
                  isDense: true,
                  onChanged: (newValue) async {
                    setState(() {
                      _locationToSet = newValue;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    box.put("_location", newValue);
                    prefs.setString("_location", newValue!);
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
                  hint: const Text("Select Wallpaper"),
                  value: _wallpapers,
                  isDense: true,
                  onChanged: (newValue) async {
                    setState(() {
                      _wallpapers = newValue;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    box.put("_wallpapers", newValue);
                    prefs.setString("_wallpapers", newValue!);
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
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    AndroidAlarmManager.initialize();
    initDownloader();
    initPowerState();
    initOnesignal();
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.initialize();

    getData();
    initAdmobAd(); //-------admob--------
    //initFbAd();             //-------fb--------
  }

  initOnesignal() {
    // OneSignal.shared.setAppId(Config().onesignalAppId);
  }

  initDownloader() {
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future getData() async {
    Future.delayed(const Duration(milliseconds: 0)).then((f) {
      final sb = context.read<SignInBloc>();
      final db = context.read<DataBloc>();

      sb
          .getUserDatafromSP()
          .then((value) => db.getData())
          .then((value) => db.getCategories());
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    var provider = Provider.of<ProviderModel>(context, listen: false);
    // provider.subscription.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final db = context.watch<DataBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();
    final pm = Provider.of<ProviderModel>(context);

    return ib.hasInternet == false
        ? const NoInternetPage()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            endDrawer: const DrawerWidget(),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Text(
                            Config().appName,
                            style: const TextStyle(
                                fontSize: 27,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          InkWell(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: !context
                                              .watch<SignInBloc>()
                                              .isSignedIn ||
                                          context
                                                  .watch<SignInBloc>()
                                                  .imageUrl ==
                                              null
                                      ? DecorationImage(
                                          image:
                                              AssetImage(Config().guestAvatar))
                                      : DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              context
                                                  .watch<SignInBloc>()
                                                  .imageUrl!))),
                            ),
                            onTap: () {
                              !sb.isSignedIn
                                  ? showGuestUserInfo(context)
                                  : showUserInfo(
                                      context, sb.name, sb.email, sb.imageUrl);
                            },
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.stream,
                              size: 20,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState!.openEndDrawer();
                            },
                          )
                        ],
                      )),
                  Stack(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            initialPage: 0,
                            viewportFraction: 0.90,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            height: h * 0.70,
                            onPageChanged: (int index, reason) {
                              setState(() => listIndex = index);
                            }),
                        items: db.alldata.isEmpty
                            ? [0, 1]
                                .take(1)
                                .map((f) => const LoadingWidget())
                                .toList()
                            : db.alldata.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 0),
                                        child: InkWell(
                                          child: CachedNetworkImage(
                                            imageUrl: i['image url'],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Hero(
                                              tag: i['timestamp'],
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 50),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                          color:
                                                              Colors.grey[300]!,
                                                          blurRadius: 30,
                                                          offset: const Offset(
                                                              5, 20))
                                                    ],
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            bottom: 40),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              Config().hashTag,
                                                              style: const TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              i['category'],
                                                              style: const TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 25),
                                                            )
                                                          ],
                                                        ),
                                                        const Spacer(),
                                                        Icon(
                                                          Icons.favorite,
                                                          size: 25,
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                        ),
                                                        const SizedBox(
                                                            width: 2),
                                                        Text(
                                                          i['loves'].toString(),
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        )
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const LoadingWidget(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
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
                                                            timestamp: i[
                                                                'timestamp'])));
                                          },
                                        ));
                                  },
                                );
                              }).toList(),
                      ),
                      Positioned(
                        top: 40,
                        left: w * 0.23,
                        child: const Text(
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
                          padding: const EdgeInsets.all(12),
                          child: DotsIndicator(
                            dotsCount: 5,
                            position: listIndex,
                            decorator: DotsDecorator(
                              activeColor: Colors.black,
                              color: Colors.black,
                              spacing: const EdgeInsets.all(3),
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
                  const Spacer(),
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
                                    builder: (context) => const CatagoryPage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCompass,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ExplorePage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidHeart,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavouritePage(
                                        userUID:
                                            context.read<SignInBloc>().uid)));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.undo,
                              color: Colors.grey[600], size: 20),
                          onPressed: () {
                            print(context.read<SignInBloc>().uid);
                            // for (var prod in pm.products) {
                            //   debugPrint("prod.id: ${prod.id}");
                            //   changerAlert(_scaffoldKey);
                            // }
                            changerAlert(_scaffoldKey);
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
  }
}
