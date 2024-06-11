import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/internet_bloc.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  //This Page is shown when the app does not has access to internet

  @override
  Widget build(BuildContext context) {
    final ib = context.watch<InternetBloc>();
    return Scaffold(
      body: Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.network_check, size : 100, color: Colors.blueAccent),
            const SizedBox(height: 5,),
            Text('No Internet Connection!', style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600

            ),),
            const SizedBox(height: 5,),
            const Text('Enable your wifi/mobile data', style: TextStyle(
              color: Colors.grey,
              fontSize: 14,

            ),),

            const SizedBox(height: 30,),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) => Colors.blueAccent)
              ),
              onPressed: (){
                ib.checkInternet(); //checking if internet is connected or not
              },
              child: const Text('Check Again', style: TextStyle(
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