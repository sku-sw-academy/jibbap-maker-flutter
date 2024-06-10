import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> inquiry;
  DetailPage({required this.inquiry});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String answerContent = '';
  String day = "";
  String time = "";

  @override
  void initState() {
    super.initState();
    _fetchAnswer();
  }

  Future<void> _fetchAnswer() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/answer/question/${widget.inquiry["id"]}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      dynamic answer = json.decode(responseBody);
      if (answer != null && answer["content"] != null) {
        setState(() {
          answerContent = answer["content"];
          day = answer["modifyDate"].toString().substring(5, 10)
              .replaceAll("-", "월") +
              "일";
          time = answer["modifyDate"].toString().substring(11, 16);
        });
      }
    } else {
      throw Exception('Failed to load answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 문의"),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문의 내용',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(widget.inquiry['content'], style: TextStyle(fontSize: 15)),
            SizedBox(height: 20),

            if (answerContent.isNotEmpty)
              Row(children: [
                Expanded(child:
                  Container(
                  color: Colors.grey[100], // 배경 색상을 회색으로 설정합니다.
                    padding: EdgeInsets.all(16.0), // 내부 여백 설정
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ㄴ답변 내용',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      Text(answerContent, style: TextStyle(fontSize: 15)),
                      SizedBox(height: 15),
                      Text(
                        '${day} ${time}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                )
              ],

              ),
          ],
        ),
      ),
    );
  }
}
