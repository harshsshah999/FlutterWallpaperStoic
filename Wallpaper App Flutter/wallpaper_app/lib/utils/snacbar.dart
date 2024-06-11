import 'package:flutter/material.dart';

void openSnacbar(GlobalKey<ScaffoldState> scaffoldKey, snacMessage){
  if (scaffoldKey.currentState != null) {
    ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
      SnackBar(
    content: Container(
      alignment: Alignment.centerLeft,
      height: 60,
      child: Text(
        snacMessage,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ),
    action: SnackBarAction(
      label: 'Ok',
      textColor: Colors.blueAccent,
      onPressed: () {},
    ),
  )
    );}else {
    // Handle the case where scaffoldKey is null or has no state
    print('Could not find ScaffoldState to show snackbar');
  }
  
}


void openDownloadingSnacbar(scaffoldKey, snacMessage){
    if (scaffoldKey.currentState != null) {
    ScaffoldMessenger.of(scaffoldKey.currentState!.context).showSnackBar(
      SnackBar(
    content: Container(
      alignment: Alignment.centerLeft,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(width: 15,),
          Text(snacMessage,style: const TextStyle(fontSize: 14,)),
          
        ],
      )
    ),
    
  )
    );}else {
    // Handle the case where scaffoldKey is null or has no state
    print('Could not find ScaffoldState to show snackbar');
  }
  
}