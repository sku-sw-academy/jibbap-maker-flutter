import 'package:flutter/material.dart';

class IngredientAll extends StatefulWidget {
  @override
  _IngredientAllState createState() => _IngredientAllState();
}

class _IngredientAllState extends State<IngredientAll> {
  List<String> categories = ['식량작물', '채소류', '특용작물', '과일류', '축산물', '수산물'];

  List<List<String>> _childLists = [
    ['쌀', '찹쌀'],
    ['배추', '시금치', '오이'],
    ['팽이버섯', '땅콩', '참깨'],
    ['바나나', '사과', '배', '토마토'],
    ['계란', '소'],
    ['굴', '고등어']
  ];

  // 각 ListTile에 대한 토글 버튼의 상태를 저장하는 3차원 리스트
  List<List<List<bool>>> isSelect = [];

  TextEditingController searchController = TextEditingController();
  List<String> filteredItems = [];
  bool isSearching = false;

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

  Color _getIconColor(int index, int subIndex, int toggleIndex) {
    if (isSelect[index][subIndex][toggleIndex]) {
      switch (toggleIndex) {
        case 0:
          return Colors.green;
        case 1:
          return Colors.orangeAccent;
        case 2:
          return Colors.red;
        default:
          return Colors.grey;
      }
    } else {
      return Colors.grey;
    }
  }

  Color _getFillColor(int index, int subIndex) {
    if (isSelect[index][subIndex][0]) {
      return Colors.green.withOpacity(0.2);
    } else if (isSelect[index][subIndex][1]) {
      return Colors.orangeAccent.withOpacity(0.2);
    } else if (isSelect[index][subIndex][2]) {
      return Colors.red.withOpacity(0.2);
    } else {
      return Colors.transparent;
    }
  }

  List<String> filterItems(String query) {
    List<String> filteredItems = [];
    for (var sublist in _childLists) {
      for (var item in sublist) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          filteredItems.add(item);
        }
      }
    }
    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 15,),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '검색',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        filteredItems = filterItems(value);
                        isSearching = true;
                      } else {
                        filteredItems.clear();
                        isSearching = false;
                      }
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  String query = searchController.text;
                  setState(() {
                    if (query.isNotEmpty) {
                      filteredItems = filterItems(query);
                      isSearching = true;
                    } else {
                      filteredItems.clear();
                      isSearching = false;
                    }
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: isSearching
                ? ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  String item = filteredItems[index];
                int categoryIndex = _childLists.indexWhere((sublist) => sublist.contains(item));
                int subIndex = _childLists[categoryIndex].indexOf(item);

                List<TextSpan> textSpans = [];
                int i = 0;
                String lowerCaseSuggestion = item.toLowerCase();
                String lowerCaseSearchText = searchController.text.toLowerCase();

                while (i < item.length) {
                  int start = lowerCaseSuggestion.indexOf(lowerCaseSearchText, i);
                  if (start == -1) {
                    textSpans.add(TextSpan(text: item.substring(i)));
                    break;
                  }

                  textSpans.add(TextSpan(text: item.substring(i, start)));
                  textSpans.add(TextSpan(
                    text: item.substring(start, start + searchController.text.length),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ));

                  i = start + searchController.text.length;
                }

                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: textSpans,
                    ),
                  ),
                  trailing: ToggleButtons(
                    isSelected: isSelect[categoryIndex][subIndex],
                    onPressed: (toggleIndex) {
                      setState(() {
                        for (int i = 0; i < isSelect[categoryIndex][subIndex].length; i++) {
                          isSelect[categoryIndex][subIndex][i] = i == toggleIndex;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    constraints: BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    children: [
                      Icon(Icons.mood_sharp,
                          color: _getIconColor(categoryIndex, subIndex, 0)),
                      Icon(Icons.face,
                          color: _getIconColor(categoryIndex, subIndex, 1)),
                      Icon(Icons.mood_bad,
                          color: _getIconColor(categoryIndex, subIndex, 2)),
                    ],
                    color: Colors.grey,
                    selectedColor: Colors.white,
                    fillColor: _getFillColor(categoryIndex, subIndex),
                    selectedBorderColor: Colors.transparent,
                    borderColor: Colors.transparent,
                  ),
                );
              },
            )
                : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    initiallyExpanded: index == 0,
                    title: Text(categories[index], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    children: _childLists[index].asMap().entries.map((entry) {
                    final int subIndex = entry.key;
                    final String childTitle = entry.value;
                    return ListTile(
                      title: Text(" $childTitle"),
                      trailing: ToggleButtons(
                        isSelected: isSelect[index][subIndex],
                        onPressed: (toggleIndex) {
                          setState(() {
                            for (int i = 0; i < isSelect[index][subIndex].length; i++) {
                              isSelect[index][subIndex][i] = i == toggleIndex;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        constraints: BoxConstraints.tightFor(
                          width: 44,
                          height: 36,
                        ),
                        children: [
                          Icon(Icons.mood_sharp,
                              color: _getIconColor(index, subIndex, 0)),
                          Icon(Icons.face,
                              color: _getIconColor(index, subIndex, 1)),
                          Icon(Icons.mood_bad,
                              color: _getIconColor(index, subIndex, 2)),
                        ],
                        color: Colors.grey,
                        selectedColor: Colors.white,
                        fillColor: _getFillColor(index, subIndex),
                        selectedBorderColor: Colors.black,
                        borderColor: Colors.black,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
