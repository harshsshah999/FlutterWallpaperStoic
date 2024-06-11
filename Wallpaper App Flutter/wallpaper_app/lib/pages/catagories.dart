import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/data_bloc.dart';
import '../pages/catagory_items.dart';

class CatagoryPage extends StatefulWidget {
  const CatagoryPage({super.key});

  @override
  _CatagoryPageState createState() => _CatagoryPageState();
}

class _CatagoryPageState extends State<CatagoryPage> {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<DataBloc>(); // Access the DataBloc using Provider
    double w = MediaQuery.of(context).size.width; // Get the width of the screen
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Categories',
            style: TextStyle(
              color: Colors.black,
            )),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: db.categories.length, // Number of items in the ListView
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
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
                      image: CachedNetworkImageProvider(db.categories[index]
                          ['thumbnail']), // Category thumbnail
                      fit: BoxFit.cover)),
              child: Align(
                child: Text(db.categories[index]['name'],
                    style: const TextStyle(
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
                            title: db.categories[index]['name'], // Category title
                            selectedCatagory: db.categories[index]['name'],
                          )));
            },
          );
        },
      ),
    );
  }
}
