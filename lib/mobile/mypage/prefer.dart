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
            scrolledUnderElevation: 0,
            title: Text("식재료 목록"),
            centerTitle: true,
            backgroundColor: Colors.lightBlueAccent[100],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Container(
                color: Colors.white, // TabBar 배경색 설정
                child: TabBar(
                  labelColor: Colors.black, // 선택된 탭의 글자 색상
                  unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 글자 색상
                  indicatorColor: Colors.blue, // 선택된 탭의 하단 선 색상
                  indicatorWeight: 3.0, // 선택된 탭의 하단 선 두께
                  tabs: [
                    Tab(text: '전체'),
                    Tab(text: '선호'),
                    Tab(text: '차단'),
                  ],
                ),
              ),
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