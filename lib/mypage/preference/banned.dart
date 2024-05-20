import 'package:flutter/material.dart';

class BannedPage extends StatefulWidget {
  @override
  _BannedPageState createState() => _BannedPageState();
}

class _BannedPageState extends State<BannedPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<String> categories = ['식량작물', '채소류', '특용작물', '과일류', '축산물', '수산물'];

    List<List<String>> _childLists = [
      ['타일 2'],
      [ '타일 4', '타일 5'],
      ['타일 6', '타일 9'],
      ['타일 7', '타일 8'],
      ['타일 6',],
      [ '타일 7', '타일 8']
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text('${categories[index]}'),
            children: _childLists[index].map((childTitle) {
              return ListTile(
                title: Text(childTitle),

              );
            }).toList(),
          );
        },
      ),
    );
  }

}