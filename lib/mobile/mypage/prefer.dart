import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/mypage/preference/all.dart';
import 'package:flutter_splim/mobile/mypage/preference/favorite.dart';
import 'package:flutter_splim/mobile/mypage/preference/banned.dart';

class MyPrefer extends StatefulWidget {
  @override
  _MyPreferState createState() => _MyPreferState();
}

class _MyPreferState extends State<MyPrefer>{
  String searchText = '';

  List<String> suggestions = [];

  List<String> getFilteredSuggestions(String searchTerm) {
    // 입력된 검색어와 일치하는 자동완성 결과를 필터링하여 반환합니다.
    return suggestions
        .where((suggestion) =>
        suggestion.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 3,
        child :
        Scaffold(
          appBar: AppBar(
            title: Text("식재료 목록"),
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