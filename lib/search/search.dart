import 'package:flutter/material.dart';
import 'package:flutter_splim/DB/DBHelper.dart';
import 'package:flutter_splim/search/searchResult.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  String searchText = '';
  List<String> suggestions = ["고등어", "조기", "수입조기", "명태", "물오징어", "건멸치",
    "건오징어", "김", "건미역", "굴", "새우젓", "멸치액젓", "굵은소금", "꽁치", "전복", "새우",
    "삼치", "쌀", "찹쌀", "콩", "팥", "녹두", "고구마", "배추", "양배추", "알배기배추", "브로콜리",
    "감자", "참깨", "땅콩", "느타리버섯", "시금치", "상추", "얼갈이배추", "갓", "수박", "참외",
    "오이","호박", "토마토", "딸기", "무", "당근", "열무", "건고추", "풋고추", "붉은 고추",
    "깐마늘(국산)", "양파", "파", "생강", "고춧가루", "미나리", "깻잎", "피망", "파프리카", "멜론",
    "방울토마토", "팽이버섯", "새송이버섯", "호두", "아몬드", "사과", "배", "복숭아", "포도", "감귤",
    "단감", "바나나", "참다래", "파인애플", "오렌지", "자몽", "레몬", "체리", "건포도", "건블루베리",
    "망고", "아보카도", "소", "돼지", "수입 소고기", "수입 돼지고기", "닭", "계란", "우유",
    "즉석밥", "두부", "김치", "고추장", "된장", "간장", "맛김(조미김)", "콩나물", "apple", "banana"]; // 예시 자동완성 목록

  //List<String> recentSearches = ['사과'];
  late Future<List<Record>> recentSearches;

  @override
  void initState() {
    super.initState(); // widget에서 dbHelper를 가져와서 초기화
    recentSearches = dbHelper.getRecords();
    fetchSuggestions();
  }

  void handleSearchChange(String searchTerm) {
    setState(() {
      searchText = searchTerm;
    });
  }

  List<String> getFilteredSuggestions(String searchTerm) {
    // 입력된 검색어와 일치하는 자동완성 결과를 필터링하여 반환합니다.
    return suggestions
        .where((suggestion) =>
        suggestion.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  }

  Future<void> fetchSuggestions() async {
    final response = await http.get(Uri.parse('http://localhost:8080/items/names'));
    if (response.statusCode == 200) {
      setState(() {
        suggestions = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredSuggestions = getFilteredSuggestions(searchText);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: handleSearchChange, // 입력이 변경될 때마다 호출됨
          decoration: InputDecoration(
            hintText: "검색어를 입력하세요",
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black), // 검색어 색상 설정
        ),
      ),

      body: ListView(
        children: [
          // 검색어가 비어있지 않고 자동 완성 결과가 있을 때만 표시합니다.
          if (searchText.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "최근 검색어",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                FutureBuilder(
                  future: recentSearches,
                  builder: (context, AsyncSnapshot<List<Record>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<String> recentSearchList = snapshot.data!
                          .map((todo) => todo.name)
                          .toList();
                      return recentSearchList.isEmpty
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "검색어가 없습니다",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                          : Column(
                        children: recentSearchList.map((recentSearch) {
                          return ListTile(
                            title: Text(recentSearch),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await dbHelper.deleteRecord(recentSearch);
                                setState(() {
                                  recentSearches = dbHelper.getRecords();
                                });
                              },
                            ),

                            onTap: () async {
                              bool isExisting = await dbHelper.checkIfSuggestionExists(recentSearch);

                              if (isExisting) {
                                // suggestion이 이미 존재하면 업데이트 수행
                                await dbHelper.updateRecord(Record(name: recentSearch, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                              }

                              else {
                                // suggestion이 존재하지 않으면 데이터베이스에 삽입
                                await dbHelper.insertRecord(Record(name: recentSearch, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                              }

                              setState(() {
                                recentSearches = dbHelper.getRecords();
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectedPage(suggestion: recentSearch),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),

                Divider( // 여기에 선을 추가합니다.
                  thickness: 2.0,
                  color: Colors.grey[300],
                  indent: 16.0,
                  endIndent: 16.0,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "추천 검색어",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(

                ),
              ],
            ),


          if (searchText.isNotEmpty && filteredSuggestions.isNotEmpty)
            Column(
              children: filteredSuggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () async {
                    bool isExisting = await dbHelper.checkIfSuggestionExists(suggestion);

                    if (isExisting) {
                      // suggestion이 이미 존재하면 업데이트 수행
                      await dbHelper.updateRecord(Record(name: suggestion, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                      setState(() {
                        recentSearches = dbHelper.getRecords();
                      });
                    }

                    else {
                      // suggestion이 존재하지 않으면 데이터베이스에 삽입
                      await dbHelper.insertRecord(Record(name: suggestion, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                      setState(() {
                        recentSearches = dbHelper.getRecords();
                      });
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedPage(suggestion: suggestion),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
