import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/blocs/userdata_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import'../models/config.dart';
import '../pages/home.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {


  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool signInStartGoogle = false;
  double leftPaddingGoogle = 20;
  double rightPaddingGoogle = 20;
  bool signInCompleteGoogle = false;


  handleAnimationGoogle(){
    setState(() {
      leftPaddingGoogle = 10;
      rightPaddingGoogle = 10;
      signInStartGoogle = true;
    });
    
  }


  handleReverseAnimationGoogle (){
    setState(() {
      leftPaddingGoogle = 20;
      rightPaddingGoogle = 20;
      signInStartGoogle = false;
    });
  }



  handleGuestUser ()async{
    final sb = context.read<SignInBloc>();
    final ub = context.read<UserBloc>();
    await sb.setGuestUser();
    await sb.saveGuestUserData();
    await ub.getUserData().then((_) => nextScreenReplace(context, HomePage()));

    

  }


  
  



  handleGoogleSignIn() async{
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    await ib.checkInternet();
    if(ib.hasInternet == false){
      openSnacbar(_scaffoldKey, 'Check your internet connection!');
      
    }else{
      
      handleAnimationGoogle();
      await sb.signInWithGoogle().then((_){
        if(sb.hasError == true){
          openSnacbar(_scaffoldKey, 'Something is wrong. Please try again.');
          setState(() {signInStartGoogle = false;});
          handleReverseAnimationGoogle();

        }else {
          sb.checkUserExists().then((value){
          if(sb.userExists == true){
            sb.getUserData(sb.uid)
            .then((value) => sb.saveDataToSP()
            .then((value) => sb.setSignIn()
            .then((value){
              setState(()=> signInCompleteGoogle = true);
              handleAfterSignupGoogle();
            })));
          } else{
            sb.getTimestamp()
            .then((value) => sb.saveDataToSP()
            .then((value) => sb.saveToFirebase()
            .then((value) => sb.setSignIn()
            .then((value){
              setState(()=> signInCompleteGoogle = true);
              handleAfterSignupGoogle();
            }))));
          }
            });
          
        }
      });
    }
  }


  handleAfterSignupGoogle (){
    setState(() {
      leftPaddingGoogle = 20;
      rightPaddingGoogle = 20;
      Future.delayed(Duration(milliseconds: 1000)).then((f){
      nextScreenReplace(context, HomePage());
    });
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          FlatButton(
            onPressed: (){
              handleGuestUser();
            }, 
            child: Text('Skip'))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 90, left: 40, right: 40, bottom:20),
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

                      SizedBox(height: 40,),

                      Text('Welcome to ${Config().appName}!', 
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600
                        ),
                      
                      ),

                      SizedBox(height: 8,),

                      Text('Explore hundreds of free stoic wallpapers for your phone and set them as your Lockscreen or HomeScreen anytime you want.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600]
                      ),
                      
                      )
                    ],
                  ),
                ),

                


            Flexible(
              flex: 2,
              child: Column(
                //crossAxisAlignment: cr,
                children: <Widget>[
                  Container(
                        margin: EdgeInsets.only(top: 80),
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(25)),
                        child: AnimatedPadding(
                            padding: EdgeInsets.only(left: leftPaddingGoogle, right: rightPaddingGoogle, ),
                            duration: Duration(milliseconds: 1000),
                            child: AnimatedCrossFade(
                              
                              duration: Duration(milliseconds: 400),
                              firstChild: _firstChildGoogle(),
                              secondChild: signInCompleteGoogle == false ? _secondChildGoogle() : _firstChildGoogle(),
                              crossFadeState: signInStartGoogle == false 
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                            ))),
                ],
              )
              )


              
            ],
          ),
        ),
      )
    );
  }


    Widget _firstChildGoogle() {
    return FlatButton.icon(
      icon: signInCompleteGoogle == false ?
      Icon(FontAwesomeIcons.google, size: 22, color: Colors.white,):
      Icon(Icons.done, size: 25, color: Colors.white,),


      label: signInCompleteGoogle == false ? 
      Text(' Continue with Google', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),) :
      Text(' Completed', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),),
      onPressed: () {
        handleGoogleSignIn();
      },
    );
  }

  Widget _secondChildGoogle(){
    return Container(
      padding: EdgeInsets.all(10),
      height: 45,
      width: 45,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        backgroundColor: Colors.white,
      ));
  }
}
