import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  final String title;
  final icon;
  const EmptyPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 100, color: Colors.grey[400],),
          const SizedBox(height: 20,),
          Text(
            title, 
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: 16, 
            color: Colors.grey[600],
            
          ),)
        ],
      ),
    );
  }
}