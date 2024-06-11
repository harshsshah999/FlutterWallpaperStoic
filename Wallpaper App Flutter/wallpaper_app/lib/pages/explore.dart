import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:stoicwallpaper/blocs/ads_bloc.dart';
import 'package:stoicwallpaper/widgets/new_items.dart';
import 'package:stoicwallpaper/widgets/popular_items.dart';

//Explore View Page

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;

  BannerAd? bannerAd;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    bannerAd =context.read<AdsBloc>().createAdmobBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // Showing Banner ad
      bottomNavigationBar: bannerAd == null
          ? Container()
          : Container(
              height: 50,
              width: 320,
              child: AdWidget(
                ad: bannerAd!,
              ),
            ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          child: SafeArea(
            child: TabBar(
              controller: tabController,
              labelStyle: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500),
              tabs: const <Widget>[
                Tab(
                  child: Text('Popular'),
                ),
                Tab(
                  child: Text(
                    'New',
                  ),
                )
              ],
              labelColor: Colors.black,
              indicatorColor: Colors.grey[900],
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                //Popular Section Tab
                PopularItems(
                  scaffoldKey: scaffoldKey,
                ),
                //New Section Tab
                NewItems(
                  scaffoldKey: scaffoldKey,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
