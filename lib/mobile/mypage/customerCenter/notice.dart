import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoticePage extends StatefulWidget{
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  List<Map<String, dynamic>> notices = []; // FAQ 목록을 저장하는 리스트
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/notice/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> noticeList = json.decode(responseBody);
        setState(() {
          notices = noticeList.map((notice) {
            var noticeMap = notice as Map<String, dynamic>;
            noticeMap['isExpanded'] = false; // Initialize isExpanded to false
            return noticeMap;
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Notices');
      }
    } catch (e) {
      print('Error fetching Notices: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("공지사항 목록을 불러오는 데 실패했습니다."),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          var notice = notices[index];
          return ExpansionTile(
            title: Text(notice['title'] , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            children: [
              ListTile(
                title: Text(" "+notice['content'], style: TextStyle(fontSize: 16)),
              ),
            ],
            onExpansionChanged: (bool isExpanded) {
              setState(() {
                notice['isExpanded'] = isExpanded;
              });
            },
            initiallyExpanded: notice['isExpanded'] ?? false,
          );
        },
      ),
    );
  }

}