import 'package:flutter/material.dart';
import 'package:flutter_splim/dto/PreferDTO.dart';
import 'package:flutter_splim/service/preferservice.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';

class IngredientAll extends StatefulWidget {
  @override
  _IngredientAllState createState() => _IngredientAllState();
}

class _IngredientAllState extends State<IngredientAll> {
  final PreferService preferService = PreferService();
  List<String> categories = ['식량작물', '채소류', '특용작물', '과일류', '축산물', '수산물'];
  List<PreferDTO> list = [];
  Map<String, List<PreferDTO>> categorizedPreferences = {};

  TextEditingController searchController = TextEditingController();
  List<String> filteredItems = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      preferService.getListPreferences(user.id).then((preferences) {
        setState(() {
          list = preferences;
          categorizePreferences();
        });
      });
    }
  }

  void categorizePreferences() {
    for (String category in categories) {
      categorizedPreferences[category] = [];
    }

    for (PreferDTO prefer in list) {
      String categoryName = prefer.item.category.categoryName;
      if (categorizedPreferences.containsKey(categoryName)) {
        categorizedPreferences[categoryName]!.add(prefer);
      }
    }
  }

  Color _getIconColor(PreferDTO prefer, int toggleIndex) {
    if (prefer.prefer == toggleIndex) {
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

  Color _getFillColor(PreferDTO prefer) {
    switch (prefer.prefer) {
      case 0:
        return Colors.green.withOpacity(0.2);
      case 1:
        return Colors.orangeAccent.withOpacity(0.2);
      case 2:
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.transparent;
    }
  }

  List<String> filterItems(String query) {
    List<String> filteredItems = [];
    for (var sublist in categorizedPreferences.values) {
      for (var item in sublist) {
        if (item.item.itemName.toLowerCase().contains(query.toLowerCase())) {
          filteredItems.add(item.item.itemName);
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
                    hintText: '검색어를 입력하세요',
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
            ],
          ),
          Expanded(
            child: isSearching
                ? Scrollbar(

                child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  String itemName = filteredItems[index];
                  PreferDTO? itemPrefer;

                  for (var sublist in categorizedPreferences.values) {
                    for (var item in sublist) {
                      if (item.item.itemName == itemName) {
                        itemPrefer = item;
                        break;
                      }
                    }
                  }

                  if (itemPrefer == null) return SizedBox.shrink(); // 리스트가 null일 때 원형 표시기 반환

                  List<TextSpan> textSpans = [];
                  int i = 0;
                  String lowerCaseSuggestion = itemName.toLowerCase();
                  String lowerCaseSearchText = searchController.text.toLowerCase();

                  while (i < itemName.length) {
                    int start = lowerCaseSuggestion.indexOf(lowerCaseSearchText, i);
                    if (start == -1) {
                      textSpans.add(TextSpan(text: itemName.substring(i)));
                      break;
                    }

                    textSpans.add(TextSpan(text: itemName.substring(i, start)));
                    textSpans.add(TextSpan(
                      text: itemName.substring(start, start + searchController.text.length),
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
                      isSelected: List.generate(3, (index) => index == itemPrefer!.prefer),
                      onPressed: (toggleIndex) async {
                        setState(() {
                          itemPrefer!.prefer = toggleIndex;
                        });
                        try {
                          await preferService.updatePrefer(itemPrefer!); // 새로운 정보를 서버로 전송합니다.

                        } catch (e) {
                          // 업데이트에 실패한 경우 에러 처리를 수행합니다.
                          // 이 코드는 선택적입니다. 실패한 경우 사용자에게 알림을 제공하거나 다른 작업을 수행할 수 있습니다.
                          print('Error updating preference: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('통신에 문제가 생겼습니다.')),
                          );
                        }

                      },
                      borderRadius: BorderRadius.circular(10),
                      constraints: BoxConstraints.tightFor(
                        width: 44,
                        height: 36,
                      ),
                      children: [
                        Icon(Icons.mood_sharp,
                            color: _getIconColor(itemPrefer!, 0)),
                        Icon(Icons.face,
                            color: _getIconColor(itemPrefer!, 1)),
                        Icon(Icons.mood_bad,
                            color: _getIconColor(itemPrefer!, 2)),
                      ],
                      color: Colors.grey,
                      selectedColor: Colors.white,
                      fillColor: _getFillColor(itemPrefer!),
                      selectedBorderColor: Colors.black,
                      borderColor: Colors.black,
                    ),
                  );
                },
              ),
            )
                : Scrollbar(
// 스크롤바 항상 표시
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  return ExpansionTile(
                    initiallyExpanded: index == 0,
                    title: Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    children: categorizedPreferences[category] != null && categorizedPreferences[category]!.isNotEmpty
                        ? categorizedPreferences[category]!.map((prefer) {
                      return ListTile(
                        title: Text(" ${prefer.item.itemName}"),
                        trailing: ToggleButtons(
                          isSelected: List.generate(3, (index) => index == prefer.prefer),
                          onPressed: (toggleIndex) async {
                            setState(() {
                              prefer.prefer = toggleIndex;
                            });

                            try {
                              await preferService.updatePrefer(prefer!); // 새로운 정보를 서버로 전송합니다.

                            } catch (e) {
                              // 업데이트에 실패한 경우 에러 처리를 수행합니다.
                              // 이 코드는 선택적입니다. 실패한 경우 사용자에게 알림을 제공하거나 다른 작업을 수행할 수 있습니다.
                              print('Error updating preference: $e');
                              setState(() {
                                prefer.prefer = toggleIndex;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          constraints: BoxConstraints.tightFor(
                            width: 44,
                            height: 36,
                          ),
                          children: [
                            Icon(Icons.mood_sharp,
                                color: _getIconColor(prefer, 0)),
                            Icon(Icons.face,
                                color: _getIconColor(prefer, 1)),
                            Icon(Icons.mood_bad,
                                color: _getIconColor(prefer, 2)),
                          ],
                          color: Colors.grey,
                          selectedColor: Colors.white,
                          fillColor: _getFillColor(prefer),
                          selectedBorderColor: Colors.black,
                          borderColor: Colors.black,
                        ),
                      );
                    }).toList()
                        : [SizedBox(width: double.infinity, height: 50, child: Center(child: CircularProgressIndicator()))], // 리스트가 null일 때 원형 표시기 반환
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
