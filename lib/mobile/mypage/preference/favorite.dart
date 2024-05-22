import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    // 아이템 리스트
    List<String> _childLists = ['타일 7', '타일 8'];

    return Scaffold(
      body: ListView.builder(
        itemCount: _childLists.length,  // _childLists의 길이만큼 아이템을 생성
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_childLists[index]),  // 각 아이템을 ListTile로 변환하여 표시
          );
        },
      ),
    );
  }
}