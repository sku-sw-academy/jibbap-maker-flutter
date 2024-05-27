import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/DB/DBHelper.dart';
import 'package:flutter_splim/mobile/search/searchResult.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/service/itemservice.dart';
import 'package:flutter_splim/constant.dart';
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'package:flutter_splim/mobile/search/result.dart';
import 'package:mysql_client/mysql_client.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ItemService itemService = ItemService();
  final PriceService priceService = PriceService();
  String searchText = '';
  List<String> suggestions = []; // 예시 자동완성 목록
  late Future<List<Record>> recentSearches;
  late Future<List<PriceDTO>> futurePopularNames;


  @override
  void initState() {
    super.initState(); // widget에서 dbHelper를 가져와서 초기화
    recentSearches = dbHelper.getRecords();
    futurePopularNames = priceService.fetchPopularItemPrices9();
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
    final response = await http.get(Uri.parse('${Constants.baseUrl}/items/names'));
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        suggestions = List<String>.from(json.decode(responsebody));
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredSuggestions = getFilteredSuggestions(searchText);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (searchText.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultPage(searchText: searchText, suggestions: suggestions),
                  ),
                );
              } else {
                // 검색어가 없는 경우에 대한 처리
                // 예: Toast 메시지 또는 다른 알림을 표시하여 사용자에게 알림
              }
            },
          ),
        ],
      ),

      body: ListView(
        children: [
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
                      List<String> recentSearchList = snapshot.data!.map((todo) => todo.name).toList();
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

                              await itemService.incrementItemCount(recentSearch);

                              setState(() {
                                recentSearches = dbHelper.getRecords();
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SelectedPage(itemname: recentSearch),
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

                FutureBuilder<List<PriceDTO>>(
                  future: futurePopularNames,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data found'));
                    } else {
                      List<PriceDTO> popularPrices = snapshot.data!;
                      return Container(
                        height: screenHeight / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            for (var i = 0; i < 3; i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  for (var j = i * 3; j < (i * 3) + 3; j++)
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30), // 반지름 값을 버튼의 너비 또는 높이보다 작게 지정하여 원형으로 만듭니다.
                                            ),
                                            side: BorderSide(color: Colors.black, width: 2),
                                            elevation: 2.0,
                                            fixedSize: Size(100, 50),
                                            // 다른 스타일 속성들...
                                          ),
                                          onPressed: () async{
                                            bool isExisting = await dbHelper.checkIfSuggestionExists(popularPrices[j].itemCode.itemName);

                                            if (isExisting) {
                                              // suggestion이 이미 존재하면 업데이트 수행
                                              await dbHelper.updateRecord(Record(name: popularPrices[j].itemCode.itemName, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                                            }

                                            else {
                                              // suggestion이 존재하지 않으면 데이터베이스에 삽입
                                              await dbHelper.insertRecord(Record(name: popularPrices[j].itemCode.itemName, date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                                            }

                                            await itemService.incrementItemCount(popularPrices[j].itemCode.itemName);

                                            setState(() {
                                              recentSearches = dbHelper.getRecords();
                                            });

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SelectedPage(itemname: popularPrices[j].itemCode.itemName),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            popularPrices[j].itemCode.itemName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                  },
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

                    await itemService.incrementItemCount(suggestion);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedPage(itemname: suggestion),
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
