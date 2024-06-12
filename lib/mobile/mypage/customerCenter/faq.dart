import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<Map<String, dynamic>> faqs = []; // FAQ 목록을 저장하는 리스트
  bool isLoading = true; // 로딩 상태를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/faq/all');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> faqList = json.decode(responseBody);
        setState(() {
          faqs = faqList.map((faq) {
            var faqMap = faq as Map<String, dynamic>;
            faqMap['isExpanded'] = false; // Initialize isExpanded to false
            return faqMap;
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      print('Error fetching FAQs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("FAQ 목록을 불러오는 데 실패했습니다."),
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
          : Scrollbar(child:
          ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          var faq = faqs[index];
          return ExpansionTile(
            title: Text(
              faq['title'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: faq['isExpanded'] ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            children: [
              Container(
                color: Colors.grey[50],
                child:ListTile(
                  title: Text(" "+faq['content'], style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
            onExpansionChanged: (bool isExpanded) {
              setState(() {
                faq['isExpanded'] = isExpanded;
              });
            },
            initiallyExpanded: faq['isExpanded'] ?? false,
          );
        },
      ),
      ),
    );
  }
}
