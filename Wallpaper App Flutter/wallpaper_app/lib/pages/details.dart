// details page

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:open_file/open_file.dart';

import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fzwallpaper/fzwallpaper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wallpaper_app/blocs/ads_bloc.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/config.dart';
import '../models/icon_data.dart';
import '../utils/circular_button.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


class DetailsPage extends StatefulWidget {
  final String tag;
  final String imageUrl;
  final String catagory;
  final String timestamp;
  ReceivePort _port = ReceivePort();


  DetailsPage(
      {Key key,
        @required this.tag,
        this.imageUrl,
        this.catagory,
        this.timestamp})
      : super(key: key);

  @override
  _DetailsPageState createState() =>
      _DetailsPageState(this.tag, this.imageUrl, this.catagory, this.timestamp);


}

class _DetailsPageState extends State<DetailsPage> {


  String tag;
  String imageUrl;
  String catagory;
  String timestamp;
  int _progress = 0;
  _DetailsPageState(this.tag, this.imageUrl, this.catagory, this.timestamp);

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      setState(() {
        _progress = progress;

      });
    });

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);


  }

  void initializeSetting() async {
    var initializeAndroid = AndroidInitializationSettings('icon_stoic');
    var initializeSetting = InitializationSettings(android: initializeAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializeSetting,onSelectNotification: selectNotification);
  }

  Future<void> displayNotification(String title, String body, String imagePath) async {
    flutterLocalNotificationsPlugin.show(0, title, body,  NotificationDetails(
      android: AndroidNotificationDetails(
          'channel id', 'channel name', 'channel description',priority: Priority.high),
    ),payload:imagePath );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      OpenFile.open(payload);
    }

  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }



  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String progress = 'Set as Wallpaper or Download';
  bool downloading = false;
  Stream<String> progressString;
  Icon dropIcon = Icon(Icons.arrow_upward);
  Icon upIcon = Icon(Icons.arrow_upward);
  Icon downIcon = Icon(Icons.arrow_downward);
  PanelController pc = PanelController();
  PermissionStatus status;

  void openSetDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('SET AS'),
          contentPadding:
          EdgeInsets.only(left: 30, top: 40, bottom: 20, right: 40),
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.format_paint, Colors.blueAccent),
              title: Text('Set As Lock Screen'),
              onTap: () async {
                await _setLockScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.donut_small, Colors.pinkAccent),
              title: Text('Set As Home Screen'),
              onTap: () async {
                await _setHomeScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.compare, Colors.orangeAccent),
              title: Text('Set As Both'),
              onTap: () async {
                await _setBoth();
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: FlatButton(
                child: Text('Cancel'),
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
        : progressString = Fzwallpaper.imageDownloadProgress(imageUrl);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting Your Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Fzwallpaper.lockScreen();
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
        : progressString = Fzwallpaper.imageDownloadProgress(imageUrl);
    progressString.listen((data) {
      setState(() {
        //res = data;
        downloading = true;
        progress = 'Setting Your Home Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Fzwallpaper.homeScreen();
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
        : progressString = Fzwallpaper.imageDownloadProgress(imageUrl);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting your Both Home & Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Fzwallpaper.bothScreen();
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
      } else if (await Permission.storage.status == PermissionStatus.permanentlyDenied) {
        askOpenSettingsDialog();
      }
    });
  }




  void openCompleteDialog() async {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        tittle: 'Complete',
        animType: AnimType.SCALE,
        padding: EdgeInsets.all(30),
        body: Center(
          child: Container(
              alignment: Alignment.center,
              height: 80,
              child: Text(
                progress,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              )),
        ),
        btnOkText: 'Ok',
        dismissOnTouchOutside: false,
        btnOkOnPress: () {
          context.read<AdsBloc>().showAdmobInterstitialAd();        //-------admob--------
          //context.read<AdsBloc>().showFbAdd();                        //-------fb--------

        }).show();
  }

  askOpenSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Grant Storage Permission to Download'),
            content: Text(
                'You have to allow storage permission to download any wallpaper fro this app'),
            contentTextStyle:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            actions: [
              FlatButton(
                child: Text('Open Settins'),
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
              ),
              FlatButton(
                child: Text('Close'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }


  Future handleDownload() async {


    initializeSetting();
    final ib = context.read<InternetBloc>();
    await context.read<InternetBloc>().checkInternet();
    if(ib.hasInternet == true){

      var path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES);

      try {

        setState(() {
          progress="Downloading...";
        });
        // Saved with this method.
        var imageId = await ImageDownloader.downloadImage(imageUrl);
        if (imageId == null) {
          return;
        }


        // Below is a method of obtaining saved image information.
        var fileName = await ImageDownloader.findName(imageId);
        var path2 = await ImageDownloader.findPath(imageId);
        await displayNotification("Wallpaper Downloaded Successfully!", "Tap to open",path2);
        var size = await ImageDownloader.findByteSize(imageId);
        var mimeType = await ImageDownloader.findMimeType(imageId);


      } catch(e){
        print(e);
      }

      /*   var outcome= await FlutterDownloader.enqueue(
      url: imageUrl,
      savedDir: path,
      fileName: '${Config().appName}-$catagory$timestamp',
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );

    print("outcome"+outcome.toString());*/


      setState(() {
        progress = 'Download Complete!\nCheck Your Status Bar';
      });

      await Future.delayed(Duration(seconds: 2));
      openCompleteDialog();


    } else{
      setState(() {
        progress = 'Check your internet connection!';
      });
    }
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
          borderRadius: BorderRadius.only(
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
              padding: EdgeInsets.only(top: 10),
              width: double.infinity,
              child: CircleAvatar(
                backgroundColor: Colors.grey[800],
                child: dropIcon,
              ),
            ),
            onTap: () {
              pc.isPanelClosed() ? pc.open() : pc.close();
            },
          ),
          SizedBox(
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
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.favorite,
                      color: Colors.pinkAccent,
                      size: 22,
                    ),
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('contents')
                          .document(timestamp)
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return _buildLoves(0);
                        return _buildLoves(snap.data['loves']);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          SizedBox(
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
                                  color: Colors.grey[400],
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.format_paint,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final ib =  context.read<InternetBloc>();
                        await context.read<InternetBloc>().checkInternet();
                        if (ib.hasInternet == false) {
                          setState(() {
                            progress = 'Check your internet connection!';
                          });
                        } else{
                          openSetDialog();
                        }

                      },
                    ),
                    SizedBox(
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
                SizedBox(
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
                                  color: Colors.grey[400],
                                  blurRadius: 10,
                                  offset: Offset(2, 2))
                            ]),
                        child: Icon(
                          Icons.donut_small,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        handleStoragePermission();
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Download',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 30,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      progress,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget _buildLoves(loves) {
    return Text(
      loves.toString(),
      style: TextStyle(color: Colors.black54, fontSize: 16),
    );
  }

  // background ui
  Widget panelBodyUI(h, w) {
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          height: h,
          width: w,
          child: Hero(
            tag: tag,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)),
              ),
              placeholder: (context, url) => Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: InkWell(
            child: Container(
                height: 40,
                width: 40,
                decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: _buildLoveIcon(ub.uid)),
            onTap: () {
              _loveIconPressed();
            },
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
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
        stream:
        Firestore.instance.collection('users').document(uid).snapshots(),
        builder: (context, snap) {
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
    final ub = context.read<UserBloc>();
    if (sb.guestUser == false) {
      context.read<UserBloc>().handleLoveIconClick(context, timestamp);
    } else {
      await showGuestUserInfo(context, ub.userName, ub.email, ub.imageUrl);
    }
  }
}
