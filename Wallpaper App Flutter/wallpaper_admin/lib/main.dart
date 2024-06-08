import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/pages/home.dart';
import 'package:admin/pages/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminBloc>(create: (context) => AdminBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Muli',
          appBarTheme: AppBarTheme(
              color: Colors.white,
              // textTheme: TextTheme(
              //   headline6: TextStyle(
              //     fontFamily: 'Muli',
              //     color: Colors.grey[900],fontWeight: FontWeight.w700, fontSize: 18),
              // ),
              elevation: 0,
              actionsIconTheme: IconThemeData(
                color: Colors.grey[900],
              ),
              iconTheme: IconThemeData(color: Colors.grey[900])),
        ),
        home: MyApp1(),
      ),
    );
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminBloc ab = Provider.of<AdminBloc>(context);
    return ab.isSignedIn == false ? SignInPage() : HomePage();
  }
}
