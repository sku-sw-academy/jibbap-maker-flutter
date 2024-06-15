import 'package:flutter/material.dart';
import 'package:flutter_splim/mobile/search/searchResult.dart';
import 'package:flutter_splim/mobile/DB/DBHelper.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/service/itemservice.dart';
import 'package:flutter_splim/constant.dart';

class SearchResultPage extends StatefulWidget {
  final String searchText;
  final List<String> suggestions;
  SearchResultPage({required this.searchText, required this.suggestions});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<List<Record>> recentSearches;
  final ItemService itemService = ItemService();

  @override
  void initState() {
    super.initState(); // widget에서 dbHelper를 가져와서 초기화
    recentSearches = dbHelper.getRecords();
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredSuggestions = getFilteredSuggestions(widget.searchText);

    return Scaffold(
        appBar: AppBar(
          title: Text("통합검색 결과", style: TextStyle(fontSize: 25),),
          centerTitle: true,
          backgroundColor: Colors.grey[100],
          scrolledUnderElevation: 0,
        ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: EdgeInsets.only(
                top: 9,bottom: 4,
            left: 12),
            child: Text(
              '검색 결과: (${filteredSuggestions.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: filteredSuggestions.isEmpty
                ? Center(
              child: Text(
                '검색어가 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                String suggestion = filteredSuggestions[index];
                String lowerCaseSuggestion = suggestion.toLowerCase();
                String lowerCaseSearchText = widget.searchText.toLowerCase();

                List<TextSpan> textSpans = [];
                int startIndex = lowerCaseSuggestion.indexOf(lowerCaseSearchText);
                if (startIndex != -1) {
                  // 검색어가 포함된 경우에만 처리
                  int endIndex = startIndex + widget.searchText.length;
                  textSpans.add(TextSpan(text: suggestion.substring(0, startIndex)));
                  textSpans.add(TextSpan(
                    text: suggestion.substring(startIndex, endIndex),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ));
                  textSpans.add(TextSpan(text: suggestion.substring(endIndex)));
                } else {
                  textSpans.add(TextSpan(text: suggestion));
                }

                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: textSpans,
                    ),
                  ),
                  onTap: () async {
                    bool isExisting = await dbHelper.checkIfSuggestionExists(suggestion);

                    if (isExisting) {
                      // suggestion이 이미 존재하면 업데이트 수행
                      await dbHelper.updateRecord(Record(
                          name: suggestion,
                          date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                      setState(() {
                        recentSearches = dbHelper.getRecords();
                      });
                    } else {
                      // suggestion이 존재하지 않으면 데이터베이스에 삽입
                      await dbHelper.insertRecord(Record(
                          name: suggestion,
                          date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
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
                    ).then((value) => setState(() {

                    }));
                  },
                );
              },
            ),
          ),

        ],
      ),
    );

  }

  List<String> getFilteredSuggestions(String searchTerm) {
  // 입력된 검색어와 일치하는 자동완성 결과를 필터링하여 반환합니다.
  return widget.suggestions.where((suggestion) => suggestion.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }
}


