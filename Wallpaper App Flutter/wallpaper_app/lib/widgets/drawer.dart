import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:stoicwallpaper/blocs/sign_in_bloc.dart';
import 'package:stoicwallpaper/pages/request_wall.dart';
import '../models/config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/explore.dart';
import '../pages/sign_in_page.dart';
import '../utils/next_screen.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    'Categories',
    'Explore',
    'Saved Items',
    "Custom Wallpaper",
    'About App',
    'Rate & Review'
  ];

  final List icons = [
    FontAwesomeIcons.dashcube,
    FontAwesomeIcons.solidCompass,
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.diceD20,
    FontAwesomeIcons.info,
    FontAwesomeIcons.star,
    FontAwesomeIcons.rightFromBracket,
  ];

  Future<void> _launchInsta() async {
    final url = Uri.parse('https://www.instagram.com/stoic.kings/');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not launch Instagram app. Please install it if not available.'),
      ));
      throw Exception('Could not launch $url');
    }
  }

  Future openLogoutDialog(context1) async {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text('Do you really want to Logout?'),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.grey.shade300)),
                child: const Text(
                  'Yes',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  Navigator.pop(context);
                  await sb.userSignout().then(
                      (_) => nextScreenReplace(context, const SignInPage()));
                },
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.grey.shade300)),
                child: const Text(
                  'No',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext coontext) {
          return AboutDialog(
            applicationVersion: Config().appVersion,
            applicationName: Config().appName,
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIcon),
            ),
            applicationLegalese: 'Wallpapers by Cillyfox',
          );
        });
  }

  void handleRating() {
    LaunchReview.launch(
        androidAppId: Config().packageName, iOSAppId: null, writeReview: true);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 50, left: 0),
                alignment: Alignment.center,
                height: 150,
                child: Text(
                  Config().hashTag.toUpperCase(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: title.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: SizedBox(
                        height: 45,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                icons[index],
                                color: Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(title[index],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (index == 0) {
                          nextScreeniOS(context, const CatagoryPage());
                        } else if (index == 1) {
                          nextScreeniOS(context, const ExplorePage());
                        } else if (index == 2) {
                          nextScreeniOS(
                              context,
                              FavouritePage(
                                  userUID: context.read<SignInBloc>().uid));
                        } else if (index == 3) {
                          nextScreeniOS(context, const RequestWallpaper());
                        } else if (index == 4) {
                          aboutAppDialog();
                        } else {
                          handleRating();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
              ),
              Row(
                children: [
                  const Text("Follow us on:"),
                  IconButton(
                    icon: const ImageIcon(
                      AssetImage('assets/images/insta.png'),
                      size: 30,
                    ),
                    onPressed: _launchInsta,
                  )
                ],
              ),
              Column(
                children: [
                  !context.watch<SignInBloc>().isSignedIn
                      ? Container()
                      : Column(
                          children: [
                            const Divider(),
                            InkWell(
                              child: const SizedBox(
                                height: 45,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.signOutAlt,
                                        color: Colors.grey,
                                        size: 22,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text('Logout',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                openLogoutDialog(context);
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ],
          )),
    );
  }
}
