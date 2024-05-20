import 'package:flutter/material.dart';

class IngredientAll extends StatefulWidget {
  @override
  _IngredientAllState createState() => _IngredientAllState();
}

class _IngredientAllState extends State<IngredientAll> {
  List<String> categories = ['식량작물', '채소류', '특용작물', '과일류', '축산물', '수산물'];

  List<List<String>> _childLists = [
    ['타일 1', '타일 2'],
    ['타일 3', '타일 4', '타일 5'],
    ['타일 6', '타일 7', '타일 8', '타일 9'],
    ['타일 7', '타일 8', '타일 10'],
    ['타일 6', '타일 9'],
    ['타일 6', '타일 7', '타일 8']
  ];

  // 각 ListTile에 대한 토글 버튼의 상태를 저장하는 3차원 리스트
  List<List<List<bool>>> isSelect = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < categories.length; i++) {
      isSelect.add([]);
      for (int j = 0; j < _childLists[i].length; j++) {
        isSelect[i].add([false, true, false]); // 중앙 버튼이 초기 선택 상태
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(categories[index]),
            children: _childLists[index].asMap().entries.map((entry) {
              final int subIndex = entry.key;
              final String childTitle = entry.value;
              return ListTile(
                title: Text(childTitle),
                trailing: ToggleButtons(
                  isSelected: isSelect[index][subIndex],
                  onPressed: (toggleIndex) {
                    setState(() {
                      for (int i = 0; i < isSelect[index][subIndex].length; i++) {
                        isSelect[index][subIndex][i] = i == toggleIndex;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  constraints: BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  children: [
                    Icon(Icons.mood_sharp),
                    Icon(Icons.face),
                    Icon(Icons.mood_bad),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
