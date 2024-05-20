import 'package:flutter/material.dart';
import 'package:flutter_splim/mypage/preference/all.dart';
import 'package:flutter_splim/mypage/preference/favorite.dart';
import 'package:flutter_splim/mypage/preference/banned.dart';

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
            title: TextField(
            onChanged: handleSearchChange, // 입력이 변경될 때마다 호출됨
            decoration: InputDecoration(
            hintText: "검색어를 입력하세요",
            border: InputBorder.none,
          ),
            style: TextStyle(color: Colors.black), // 검색어 색상 설정
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
              // 검색 버튼이 눌렸을 때 실행되는 동작 추가
              },
            ),
          ],
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