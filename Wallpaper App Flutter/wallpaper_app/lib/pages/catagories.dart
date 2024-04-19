import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/data_bloc.dart';
import '../pages/catagory_items.dart';

class CatagoryPage extends StatefulWidget {
  CatagoryPage({Key? key}) : super(key: key);

  @override
  _CatagoryPageState createState() => _CatagoryPageState();
}

class _CatagoryPageState extends State<CatagoryPage> {





  @override
  Widget build(BuildContext context) {
    final db = context.watch<DataBloc>();
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Categories',
            style: TextStyle(
              color: Colors.black,
            )),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(15),
        itemCount: db.categories.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 10,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
                  child: Container(
                    height: 140,
                    width: w,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                db.categories[index]['thumbnail']),
                            fit: BoxFit.cover)),
                    child: Align(
                      child: Text(db.categories[index]['name'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CatagoryItem(
                                  title: db.categories[index]['name'],
                                  selectedCatagory: db.categories[index]
                                      ['name'],
                                )));
                  },
                );
        },
      ),
    );
  }
}
