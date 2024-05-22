import 'package:flutter/material.dart';

class BannedPage extends StatefulWidget {
  @override
  _BannedPageState createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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