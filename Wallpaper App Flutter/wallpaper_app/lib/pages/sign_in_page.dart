import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/config.dart';
import '../pages/home.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';

class SignInPage extends StatefulWidget {
  
  SignInPage({Key? key, this.closeDialog}) : super(key: key);

  final bool? closeDialog;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController _buttonController = RoundedLoadingButtonController();




  handleGuestUser() async {
    final sb = context.read<SignInBloc>();
    await sb.setGuestUser().then((_){
      if(widget.closeDialog == null || widget.closeDialog == false){
        Future.delayed(const Duration(milliseconds: 500))
        .then((value) => nextScreenReplace(context, const HomePage()));
      }else{
        Navigator.pop(context);
      }
    });
  }



  Future handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(_scaffoldKey, 'Check your internet connection!');
    } else {
      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          openSnacbar(_scaffoldKey, 'Something is wrong. Please try again.');
          _buttonController.reset();
        } else {
          sb.checkUserExists().then((isUserExisted) async {
            if (isUserExisted) {
              await sb.getUserDataFromFirebase(sb.uid)
              .then((value) => sb.guestSignout())
              .then((value) => sb.saveDataToSP()
              .then((value) => sb.setSignIn()
              .then((value) {
                _buttonController.success();
                handleAfterSignupGoogle();
              })));
            } else {
              sb.getTimestamp()
              .then((value) => sb.saveToFirebase()
              .then((value) => sb.increaseUserCount())
              .then((value) => sb.guestSignout())
              .then((value) => sb.saveDataToSP()
              .then((value) => sb.setSignIn()
              .then((value) {
                _buttonController.success();
                handleAfterSignupGoogle();
            }))));
            }
          });
        }
      });
    }
  }



  handleAfterSignupGoogle() {
    Future.delayed(const Duration(milliseconds: 1000)).then((f) {
      if(widget.closeDialog == null || widget.closeDialog == false){
        nextScreenReplace(context, const HomePage());
      }else{
        Navigator.pop(context);
      }
    });
  }
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          actions: [

            widget.closeDialog == null || widget.closeDialog == false ?
            TextButton(
                onPressed: () {
                  handleGuestUser();
                },
                child: const Text('Skip'))
            : Container()
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 90, left: 40, right: 40, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image(
                        image: AssetImage(Config().splashIcon),
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Welcome to ${Config().appName}!',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Explore hundreds of free stoic wallpapers for your phone and set them as your Lockscreen or HomeScreen anytime you want.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
                Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child: RoundedLoadingButton(
                            child: Wrap(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.google,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )
                              ],
                            ),
                            controller: _buttonController,
                            onPressed: () => handleGoogleSignIn(),
                            width: MediaQuery.of(context).size.width * 0.80,
                            color: Colors.blueAccent,
                            elevation: 0,
                            borderRadius: 25,
                          ),
                        ),



                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  
}
