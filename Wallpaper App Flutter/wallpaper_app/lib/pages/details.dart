// details page

// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_app/blocs/ads_bloc.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/config.dart';
import '../models/icon_data.dart';
import '../utils/circular_button.dart';
// import '../widgets/ext_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DetailsPage extends StatefulWidget {
  final String? tag;
  final String? imageUrl;
  final String? catagory;
  final String? timestamp;

  DetailsPage(
      {Key? key,
      required this.tag,
      this.imageUrl,
      this.catagory,
      this.timestamp})
      : super(key: key);

  @override
  _DetailsPageState createState() =>
      _DetailsPageState(tag, imageUrl, catagory, timestamp);
}

class _DetailsPageState extends State<DetailsPage> {
  String? tag;
  String? imageUrl;
  String? catagory;
  String? timestamp;
  _DetailsPageState(this.tag, this.imageUrl, this.catagory, this.timestamp);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String progress = 'Set as Wallpaper or Download';
  bool downloading = false;
  int timerTime = 6;
  RewardedAd? _rewardedAd;
  late Stream<String> progressString;
  Icon dropIcon = const Icon(Icons.arrow_upward);
  Icon upIcon = const Icon(Icons.arrow_upward);
  Icon downIcon = const Icon(Icons.arrow_downward);
  PanelController pc = PanelController();
  PermissionStatus? status;

  openSetDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('SET AS'),
          contentPadding:
              const EdgeInsets.only(left: 30, top: 40, bottom: 20, right: 40),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: circularButton(Icons.format_paint, Colors.blueAccent),
              title: const Text('Set As Lock Screen'),
              onTap: () async {
                await _setLockScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: circularButton(Icons.donut_small, Colors.pinkAccent),
              title: const Text('Set As Home Screen'),
              onTap: () async {
                await _setHomeScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: circularButton(Icons.compare, Colors.orangeAccent),
              title: const Text('Set As Both'),
              onTap: () async {
                await _setBoth();
                Navigator.pop(context);
              },
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  //lock screen procedure
  _setLockScreen() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.ImageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting Your Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.lockScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });

      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Some Error");
    });
  }

  // home screen procedure
  _setHomeScreen() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.ImageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        //res = data;
        downloading = true;
        progress = 'Setting Your Home Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.homeScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });

      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Some Error");
    });
  }

  // both lock screen & home screen procedure
  _setBoth() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.ImageDownloadProgress(imageUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting your Both Home & Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.bothScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });

      openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      print("Some Error");
    });
  }

  handleStoragePermission() async {
    await Permission.storage.request().then((_) async {
      if (await Permission.storage.status == PermissionStatus.granted) {
        await handleDownload();
      } else if (await Permission.storage.status == PermissionStatus.denied) {
      } else if (await Permission.storage.status ==
          PermissionStatus.permanentlyDenied) {
        askOpenSettingsDialog();
      }
    });
  }

  void loadRewardAd() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-8872829619482545/4287226579',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
    Timer(Duration(seconds: timerTime), () {
      debugPrint('Reward loaded');
      loadRewardAd();
      timerTime += 5;
    });
  }

  showRewardAd(String tag) {
    // final AdsBloc ad = Provider.of<AdsBloc>(context, listen: false);
    _rewardedAd!.show(onUserEarnedReward: (ad, rewardItem) {
      print('User earned reward');
      if (tag == 'dl') {
        handleStoragePermission();
        debugPrint('Downloading');
      } else {
        openSetDialog();
      }
    });
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );
  }

  void openCompleteDialog() async {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        title: 'Complete',
        animType: AnimType.SCALE,
        padding: const EdgeInsets.all(30),
        body: Center(
          child: Container(
              alignment: Alignment.center,
              height: 80,
              child: Text(
                progress,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              )),
        ),
        btnOkText: 'Ok',
        dismissOnTouchOutside: false,
        btnOkOnPress: () {
          context
              .read<AdsBloc>()
              .showInterstitialAdAdmob(); //-------admob--------
          //context.read<AdsBloc>().showFbAdd();                        //-------fb--------
        }).show();
  }

  askOpenSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Grant Storage Permission to Download'),
            content: const Text(
                'You have to allow storage permission to download any wallpaper fro this app'),
            contentTextStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            actions: [
              TextButton(
                child: const Text('Open Settins'),
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void initializeSetting() async {
    var initializeAndroid = const AndroidInitializationSettings('icon_stoic');
    var initializeSetting = InitializationSettings(android: initializeAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializeSetting,
        onSelectNotification: selectNotification as void Function(String?)?);
  }

  Future<void> displayNotification(
      String title, String body, String imagePath) async {
    flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails('channel id', 'channel name',
              priority: Priority.max),
        ),
        payload: imagePath);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      OpenFile.open(payload);
    }
  }

  Future handleDownload() async {
    initializeSetting();
    final ib = context.read<InternetBloc>();
    await context.read<InternetBloc>().checkInternet();
    if (ib.hasInternet == true) {
      var path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_PICTURES);

      try {
        setState(() {
          progress = "Downloading...";
        });

        var status = await Permission.storage.status;
        if (status == PermissionStatus.granted) {
          var response = await Dio().get(imageUrl!,
              options: Options(responseType: ResponseType.bytes));
          // remove extension from file name
          var fileName = imageUrl!.split('/').last;
          var nameImg = fileName.split('.').first;

          var file = File('$path/$nameImg.jpg').path;

          final result = await ImageGallerySaver.saveImage(
              Uint8List.fromList(response.data),
              quality: 60,
              name: nameImg);
          var path2 = await result['filePath'];

          var path3 = path2.substring(7);

          log("PATH2: $path3");
          log("RESULT: $result");
          log("PATH: $file");
          log("PATH: $path");
          log("PATH: $nameImg");

          if (result['isSuccess'] == true) {
            await displayNotification(
                "Wallpaper Downloaded Successfully!", "Tap to open", file);

            setState(() {
              progress = "Download Complete";
            });
          } else if (ResultType.error == result) {
            setState(() {
              progress = "Download Failed";
            });
          }
        } else if (status == PermissionStatus.denied) {
          setState(() {
            progress = "Permission Denied";
          });
        } else if (status == PermissionStatus.permanentlyDenied) {
          setState(() {
            progress = "Permission Permanently Denied";
          });
        } else if (status == PermissionStatus.restricted) {
          setState(() {
            progress = "Permission Restricted";
          });
        }
        // setState(() {
        //   progress = "Downloading...";
        // });
        // // Saved with this method.
        // print("printingpathcheck");
        // print("print url ${imageUrl}");
        // var imageId = await ImageDownloader.downloadImage(imageUrl!);

        // if (imageId == null) {
        //   print("printingpathnull");

        //   return;

        // }

        // // Below is a method of obtaining saved image information.
        // var fileName = await ImageDownloader.findName(imageId);
        // var path2 = await ImageDownloader.findPath(imageId);
        // print("printingpath ${path2}");
        // print(path2);
        // await displayNotification(
        //     "Wallpaper Downloaded Successfully!", "Tap to open", path2!);
        // var size = await ImageDownloader.findByteSize(imageId);
        // var mimeType = await ImageDownloader.findMimeType(imageId);
      } catch (e) {
        print(e);
      }

      setState(() {
        progress = 'Download Complete!\nCheck Your Gallery';
      });

      await Future.delayed(const Duration(seconds: 2));
      openCompleteDialog();
    } else {
      setState(() {
        progress = 'Check your internet connection!';
      });
    }
  }

  // Future handleDownload() async {
  //   final ib = context.read<InternetBloc>();
  //   await context.read<InternetBloc>().checkInternet();
  //   if (ib.hasInternet == true) {
  //     try {
  //       var path = await (ExtStorage.getExternalStoragePublicDirectory(
  //           ExtStorage.DIRECTORY_PICTURES));
  //       await FlutterDownloader.enqueue(
  //         url: imageUrl!,
  //         savedDir: path!,
  //         fileName: '${Config().appName}-$catagory$timestamp',
  //         showNotification:
  //             true, // show download progress in status bar (for Android)
  //         openFileFromNotification:
  //             true, // click on notification to open downloaded file (for Android)
  //       );
  //     } catch (e) {
  //       setState(() {
  //         downloading = false;
  //         progress = 'Some Error Occured';
  //       });
  //     }

  //     setState(() {
  //       progress = 'Download Complete!\nCheck Your Status Bar';
  //     });

  //     await Future.delayed(const Duration(seconds: 2));
  //     openCompleteDialog();
  //   } else {
  //     setState(() {
  //       progress = 'Check your internet connection!';
  //     });
  //   }
  // }
  @override
  void initState() {
    super.initState();
    loadRewardAd();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final DataBloc db = Provider.of<DataBloc>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey,
        body: SlidingUpPanel(
          controller: pc,
          color: Colors.white.withOpacity(0.9),
          minHeight: 120,
          maxHeight: 450,
          backdropEnabled: false,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          body: panelBodyUI(h, w),
          panel: panelUI(db),
          onPanelClosed: () {
            setState(() {
              dropIcon = upIcon;
            });
          },
          onPanelOpened: () {
            setState(() {
              dropIcon = downIcon;
            });
          },
        ));
  }

  // floating ui
  Widget panelUI(db) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              width: double.infinity,
              child: CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: dropIcon,
              ),
            ),
            onTap: () {
              pc.isPanelClosed ? pc.open() : pc.close();
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Config().hashTag,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      '$catagory Wallpaper',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 22,
                    ),
                    StreamBuilder(
                      stream: firestore
                          .collection('contents')
                          .doc(timestamp)
                          .snapshots(),
                      builder: (context, AsyncSnapshot snap) {
                        if (!snap.hasData) return _buildLoves(0);
                        return _buildLoves(snap.data['loves']);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 10,
                                  offset: const Offset(2, 2))
                            ]),
                        child: const Icon(
                          Icons.format_paint,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final ib = context.read<InternetBloc>();
                        await context.read<InternetBloc>().checkInternet();
                        if (ib.hasInternet == false) {
                          setState(() {
                            progress = 'Check your internet connection!';
                          });
                        } else {
                          openSetDialog();

                          // if (RewardedAd == null) {
                          //   openSetDialog();
                          //   loadRewardAd();
                          //   // final snackBar = SnackBar(
                          //   //   content: const Text('Please Try After 10 Sec'),
                          //   //   action: SnackBarAction(
                          //   //     label: 'OK',
                          //   //     onPressed: () {
                          //   //       // Some code to undo the change.
                          //   //     },
                          //   //   ),
                          //   // );
                          //   //
                          //   // // Find the ScaffoldMessenger in the widget tree
                          //   // // and use it to show a SnackBar.
                          //   // ScaffoldMessenger.of(context)
                          //   //     .showSnackBar(snackBar);
                          // } else {
                          //   showRewardAd('wl');
                          // }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Set Wallpaper',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 10,
                                  offset: const Offset(2, 2))
                            ]),
                        child: const Icon(
                          Icons.donut_small,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        if (_rewardedAd != null) {
                          showRewardAd('dl');
                        } else {
                          handleStoragePermission();
                          debugPrint('Downloading');
                        }
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Watch Ads to Download',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 30,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      progress,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget _buildLoves(loves) {
    return Text(
      loves.toString(),
      style: const TextStyle(color: Colors.black54, fontSize: 16),
    );
  }

  // background ui
  Widget panelBodyUI(h, w) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          height: h,
          width: w,
          color: Colors.grey[200],
          child: Hero(
            tag: tag!,
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)),
              ),
              placeholder: (context, url) => const Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: InkWell(
            child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: _buildLoveIcon(sb.uid)),
            onTap: () {
              _loveIconPressed();
            },
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(
                Icons.close,
                size: 25,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget _buildLoveIcon(uid) {
    final sb = context.watch<SignInBloc>();
    if (sb.guestUser == false) {
      return StreamBuilder(
        stream: firestore.collection('users').doc(uid).snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) return LoveIcon().greyIcon;
          List d = snap.data['loved items'];

          if (d.contains(timestamp)) {
            return LoveIcon().pinkIcon;
          } else {
            return LoveIcon().greyIcon;
          }
        },
      );
    } else {
      return LoveIcon().greyIcon;
    }
  }

  _loveIconPressed() async {
    final sb = context.read<SignInBloc>();
    if (sb.guestUser == false) {
      context.read<UserBloc>().handleLoveIconClick(context, timestamp, sb.uid);
    } else {
      await showGuestUserInfo(context);
    }
  }
}
