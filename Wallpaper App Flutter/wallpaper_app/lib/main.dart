
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/blocs/ads_bloc.dart';
import 'package:wallpaper_app/models/providermodel.dart';
import './blocs/bookmark_bloc.dart';
import './blocs/data_bloc.dart';
import './blocs/internet_bloc.dart';
import './blocs/sign_in_bloc.dart';
import './blocs/userdata_bloc.dart';
import './pages/home.dart';
import './pages/sign_in_page.dart';
import 'package:flutter/services.dart';


import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: false 
  );
  
  
  await AndroidAlarmManager.initialize();
  var prefs = await SharedPreferences.getInstance();

  InAppPurchaseConnection.enablePendingPurchases();

  if(prefs.getBool("isAlarmOn") == null){
    prefs.setBool("isAlarmOn", false);
    print("WATCH THIS: initial check called");
  }else{
    print("WATCH THIS: initial check not called");
  }
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
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

          ChangeNotifierProvider(
            create: (context) => ProviderModel(),
          ),

        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              appBarTheme: AppBarTheme(
                brightness: Brightness.dark,
                color: Colors.white,
                textTheme: TextTheme(
                    headline6: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              textTheme: TextTheme(
                  headline6: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              )),
            ),
            home: MyApp1()));
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return sb.isSignedIn == false && sb.guestUser == false
    ? SignInPage() : HomePage();
  }
}
