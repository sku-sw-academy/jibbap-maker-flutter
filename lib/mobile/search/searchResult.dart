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
  String? selectedKind;

  @override
  void initState() {
    super.initState();
    fetchKinds();
  }

  Future<void> fetchKinds() async {
    final response = await http.get(Uri.parse('http://localhost:8080/prices/kinds/${widget.itemname}'));
    if (response.statusCode == 200) {
      setState(() {
        kinds = List<String>.from(json.decode(response.body));
        // 기본값 설정
        if (kinds.isNotEmpty) {
          selectedKind = kinds.first;
        }
      });
    } else {
      throw Exception('Failed to load suggestions');
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
            if (kinds.isNotEmpty) // 데이터를 가져오면 첫 번째 DropdownButton을 보여줌
              DropdownButton<String>(
                value: selectedKind,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedKind = newValue;
                  });
                },
                items: kinds
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            else // 데이터가 없으면 로딩 중을 표시
              CircularProgressIndicator(),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: 'Item A', // 초기값 설정
              onChanged: (String? newValue) {
                // 선택된 값에 따라 동작 설정
                // 여기서는 콘솔에 선택된 값을 출력하도록 함
                print('Selected item: $newValue');
              },
              items: <String>['Item A', 'Item B', 'Item C']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
