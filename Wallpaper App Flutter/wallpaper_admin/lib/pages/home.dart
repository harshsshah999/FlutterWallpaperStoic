import 'package:admin/blocs/admin_bloc.dart';
import 'package:admin/models/config.dart';
import 'package:admin/pages/categories.dart';
import 'package:admin/pages/contents.dart';
import 'package:admin/pages/data_info.dart';
import 'package:admin/pages/sign_in.dart';
import 'package:admin/pages/upload_item.dart';
import 'package:admin/pages/users.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  
  final List<String> titles = [
    'Data Statistics',
    'All Items',
    'Upload Item',
    'Categories',
    'Users'
  ];
  
  final List icons = [
    LineIcons.pie_chart,
    LineIcons.leaf,
    LineIcons.arrow_circle_up,
    LineIcons.caret_square_o_right,
    LineIcons.users
  ];


  handleLogOut ()async{
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));

  }

  @override
  Widget build(BuildContext context) {
    final AdminBloc ab = Provider.of<AdminBloc>(context);
    return Scaffold(
      
      appBar: _appBar(ab),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.white,
                child: VerticalTabs(
                  tabBackgroundColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  tabsElevation: 10,
                  tabsShadowColor: Colors.grey[500],
                  tabsWidth: 200,
                  indicatorColor: Colors.deepPurpleAccent,
                  selectedTabBackgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
                  indicatorWidth: 5,
                  
                  tabs: <Tab>[
                    tab(titles[0], icons[0]),
                    tab(titles[1], icons[1]),
                    tab(titles[2], icons[2]),
                    tab(titles[3], icons[3]),
                    tab(titles[4], icons[4])

                    
                  ],
                  contents: <Widget>[
                    DataInfoPage(),
                    ContentsPage(),
                    UploadItem(),
                    CategoryPage(),
                    UsersPage()
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tab(title, icon) {
    return Tab(
        child: Container(
      padding: EdgeInsets.only(left: 10,),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon, size: 20, color: Colors.grey[800],
          ),
          SizedBox(
            width: 5,
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[900], fontWeight: FontWeight.w600),)
        ],
      ),
    ));
  }

  Widget tabsContent(String caption, [String description = '']) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Text(
            caption,
            style: TextStyle(fontSize: 25),
          ),
          Divider(
            height: 20,
            color: Colors.black45,
          ),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }


  Widget _appBar (ab){
    return PreferredSize(
    preferredSize: Size.fromHeight(80),
    child: Container(
      height: 60,
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey[300],
            blurRadius: 10,
            offset: Offset(0, 5)
          )
        ]
      ),
      child: Row(
        children: <Widget>[
          RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey[900], fontFamily: 'Muli'),
            text: Config().appName,
            children: <TextSpan>[
              TextSpan(
                text: ' - Admin Panel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800], fontFamily: 'Muli')
              )
            ])),
          Spacer(),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 10, right: 10,),
            decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey[400],
                blurRadius: 10,
                offset: Offset(2, 2)
              )
            ]

            ),
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: Icon(LineIcons.sign_out, color: Colors.white, size: 20,),
              label: Text('Logout', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),),
              onPressed: () => handleLogOut(), 
              ),
          ),
          SizedBox(width: 5,),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurpleAccent),
            borderRadius: BorderRadius.circular(20),
            

            ),
            child: FlatButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: Icon(LineIcons.user, color: Colors.grey[800], size: 20,),
              label: Text('Signed as ${ab.userType}', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.deepPurpleAccent, fontSize: 16),),
              onPressed: () => null, 
              ),
          ),
          SizedBox(width: 20,)
          
        ],
      ),
    )
      
  );
  }
}
