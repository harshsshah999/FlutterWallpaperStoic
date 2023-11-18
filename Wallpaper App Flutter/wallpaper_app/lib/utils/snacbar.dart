import 'package:flutter/material.dart';

void openSnacbar(_scaffoldKey, snacMessage){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
    content: Container(
      alignment: Alignment.centerLeft,
      height: 60,
      child: Text(
        snacMessage,
        style: TextStyle(
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
    );
  
}


void openDownloadingSnacbar(_scaffoldKey, snacMessage){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
    content: Container(
      alignment: Alignment.centerLeft,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(width: 15,),
          Text(snacMessage,style: TextStyle(fontSize: 14,)),
          
        ],
      )
    ),
    
  )
    );
  
}