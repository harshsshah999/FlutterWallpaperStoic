import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataInfoPage extends StatelessWidget {
  const DataInfoPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(left: w * 0.05, right: w * 0.05, top: w * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, AsyncSnapshot snap) {
              if (!snap.hasData) return card('TOTAL USER', 0);
              return card('TOTAL USER', snap.data.documents.length);
            },
          ),
          SizedBox(
            width: 20,
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('contents').snapshots(),
            builder: (context, AsyncSnapshot snap) {
              if (!snap.hasData) return card('TOTAL CONTENTS', 0);
              return card('TOTAL CONTENTS', snap.data.documents.length);
            },
          ),
          SizedBox(
            width: 20,
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('categories').snapshots(),
            builder: (context, AsyncSnapshot snap) {
              if (!snap.hasData) return card('TOTAL CATEGORIES', 0);
              return card('TOTAL CATEGORIES', snap.data.documents.length);
            },
          ),
        ],
      ),
    );
  }

  Widget card(String title, int number) {
    return Container(
      padding: EdgeInsets.all(30),
      height: 180,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey[300], blurRadius: 10, offset: Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            height: 2,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(15)),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.trending_up,
                size: 40,
                color: Colors.deepPurpleAccent,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                number.toString(),
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              )
            ],
          )
        ],
      ),
    );
  }
}
