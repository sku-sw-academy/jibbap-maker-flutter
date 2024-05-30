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
          title: Text("통합검색 결과"),
          centerTitle: true,
          backgroundColor: Colors.amberAccent,
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
            child: ListView.builder(
              itemCount: filteredSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredSuggestions[index]),
                  onTap: () async{
                    bool isExisting = await dbHelper.checkIfSuggestionExists(filteredSuggestions[index]);
                    if (isExisting) {
                      await dbHelper.updateRecord(Record(name: filteredSuggestions[index], date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                    }

                    else {
                      await dbHelper.insertRecord(Record(name: filteredSuggestions[index], date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()).toString()));
                    }

                    await itemService.incrementItemCount(filteredSuggestions[index]);

                    setState(() {
                      recentSearches = dbHelper.getRecords();
                    });

                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => SelectedPage(itemname: filteredSuggestions[index]),
                    ),
                    );
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


