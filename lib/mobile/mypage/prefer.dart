import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/mypage/preference/all.dart';
import 'package:flutter_splim/mobile/mypage/preference/favorite.dart';
import 'package:flutter_splim/mobile/mypage/preference/banned.dart';

class MyPrefer extends StatefulWidget {
  @override
  _MyPreferState createState() => _MyPreferState();
}

class _MyPreferState extends State<MyPrefer>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 3,
        child :
        Scaffold(
          appBar: AppBar(
            title: Text("식재료 목록"),
            centerTitle: true,
            backgroundColor: Colors.limeAccent,
            bottom: TabBar(
               tabs: [
                Tab(text: 'All'),
                Tab(text: 'Favorites'),
                Tab(text: 'Banned'),
            ],
            ),
          ),

          body: TabBarView(
            children: [
              IngredientAll(),
              FavoritePage(),
              BannedPage()
            ],
          ),
      )
    );
  }

}