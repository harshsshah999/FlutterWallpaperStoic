import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stoicwallpaper/blocs/ads_bloc.dart';
import 'package:stoicwallpaper/models/providermodel.dart';
import 'package:workmanager/workmanager.dart';
import './blocs/bookmark_bloc.dart';
import './blocs/data_bloc.dart';
import './blocs/internet_bloc.dart';
import './blocs/sign_in_bloc.dart';
import './blocs/userdata_bloc.dart';
import './pages/home.dart';
import './pages/sign_in_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Box box;

 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
   Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: false
  );
  
  // await AndroidAlarmManager.initialize();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDJjDinogigbt8XRSd_D6MrHgiBkGorRr8',
          appId: '1:502349033379:android:2c92114ca4d7a92d9af416',
          messagingSenderId: '502349033379',
          projectId: 'stoicwall-79c94'));
  await Hive.initFlutter();
  box = await Hive.openBox('box');
  await FlutterDownloader.initialize(debug: true);
  initializeSetting();

  //Checking if Autowallpaper feature is set or not
  var prefs = await SharedPreferences.getInstance();
  
  if (prefs.getBool("isAlarmOn") == null) {
    prefs.setBool("isAlarmOn", false);

    debugPrint("WATCH THIS: initial check called");
  } else {
    debugPrint("WATCH THIS: initial check not called");
  }

  runApp(const MyApp());
}

void initializeSetting() async {
  var initializeAndroid = const AndroidInitializationSettings('ic');
  var initializeSetting = InitializationSettings(android: initializeAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializeSetting);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
          ),
          ChangeNotifierProvider<ProviderModel>(
            create: (context) => ProviderModel(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<AdsBloc>(
            create: (context) => AdsBloc(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                color: Colors.white,
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              textTheme: const TextTheme(
                  titleLarge: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              )),
            ),
            home: const MyApp1()));
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    //checking if user is signed in or not
    return sb.isSignedIn == false && sb.guestUser == false
        ? const SignInPage()
        : const HomePage();
  }
}
