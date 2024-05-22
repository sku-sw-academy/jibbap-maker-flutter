import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectedPage extends StatefulWidget {
  final String itemname;

  SelectedPage({required this.itemname});

  @override
  _SelectedPageState createState() => _SelectedPageState();
}

class _SelectedPageState extends State<SelectedPage> {
  List<String> kinds = [];
  List<List<String>> ranks = [];
  int? selectedKindIndex;
  int? selectedRankIndex;

  @override
  void initState() {
    super.initState();
    fetchKinds();
  }

  Future<void> fetchKinds() async {
    final response = await http.get(
      Uri.parse('http://121.165.186.226:8080/prices/kinds/${widget.itemname}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        kinds = List<String>.from(json.decode(responsebody));
        if (kinds.isNotEmpty) {
          selectedKindIndex = 0;
          fetchRanks(selectedKindIndex!); // 초기 선택된 종류의 등급을 가져옴
        }
      });
    } else {
      print('Failed to load kinds: ${response.statusCode}');
    }
  }

  Future<void> fetchRanks(int kindIndex) async {
    final response = await http.get(
      Uri.parse('http://121.165.186.226:8080/prices/ranks/${kinds[kindIndex]}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        String responsebody = utf8.decode(response.bodyBytes);
        List<String> rankList = List<String>.from(json.decode(responsebody));
        ranks.insert(kindIndex, rankList);
        selectedRankIndex = 0; // 등급 리스트의 첫 번째 값을 선택
      });
    } else {
      print('Failed to load ranks for ${kinds[kindIndex]}: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemname}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kinds.isNotEmpty)
              DropdownButton<int>(
                value: selectedKindIndex,
                onChanged: (int? newIndex) {
                  setState(() {
                    selectedKindIndex = newIndex;
                    if (newIndex != null) {
                      fetchRanks(newIndex); // 선택된 종류에 따라 등급 리스트 업데이트
                    }
                  });
                },
                items: List.generate(kinds.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(kinds[index]),
                    key: Key(kinds[index]),
                  );
                }),
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 20),

            if (selectedKindIndex != null && ranks[selectedKindIndex!] != null)
              DropdownButton<int>(
                value: selectedRankIndex,
                onChanged: (int? newIndex) {
                  setState(() {
                    selectedRankIndex = newIndex;
                  });
                  print('Selected item: ${ranks[selectedKindIndex!][selectedRankIndex!]}');
                },
                items: List.generate(ranks[selectedKindIndex!].length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(ranks[selectedKindIndex!][index]),
                    key: Key(ranks[selectedKindIndex!][index]),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
