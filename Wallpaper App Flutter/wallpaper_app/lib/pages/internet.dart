import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/internet_bloc.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ib = context.watch<InternetBloc>();
    return Scaffold(
      body: Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.network_check, size : 100, color: Colors.blueAccent),
            SizedBox(height: 5,),
            Text('No Internet Connection!', style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600

            ),),
            SizedBox(height: 5,),
            Text('Enable your wifi/mobile data', style: TextStyle(
              color: Colors.grey,
              fontSize: 14,

            ),),

            SizedBox(height: 30,),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blueAccent)
              ),
              onPressed: (){
                ib.checkInternet();
              },
              child: Text('Check Again', style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),),
            )
          ],
        ),
      ),
    );
  }
}