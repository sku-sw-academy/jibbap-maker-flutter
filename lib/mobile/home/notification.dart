import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/dto/NotificationListDTO.dart';
import 'package:flutter_splim/mobile/mypage/customerCenter/center.dart';
import 'package:flutter_splim/mobile/home/detail.dart';

class NotificationListPage extends StatefulWidget {
  final int userId;

  NotificationListPage({required this.userId});
  
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  late Future<List<NotificationListDTO>> notificationList;

  @override
  void initState() {
    super.initState();
    notificationList = fetchNotificationList(widget.userId); // 사용자 ID를 1로 가정
  }

  Future<List<NotificationListDTO>> fetchNotificationList(int userId) async {
    final response = await http.get(Uri.parse('${Constants.baseUrl}/notification/list/$userId'));

    if (response.statusCode == 200) {
      var responseBody = utf8.decode(response.bodyBytes);
      List jsonResponse = json.decode(responseBody);
      return jsonResponse.map((data) => NotificationListDTO.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load notification list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<NotificationListDTO>>(
        future: notificationList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('알림 목록이 없습니다.'));
          } else {
            return Scrollbar(
                child:ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                NotificationListDTO notification = snapshot.data![index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      SizedBox(height: 5), // 간격을 위해 추가
                      Text(
                        notification.modifyDate.toString().substring(5, 16).replaceAll("T", " ").replaceAll("-", "/"),
                        style: TextStyle(color: Colors.grey, fontSize: 12), // 날짜 텍스트 스타일 조정
                      ),
                    ],
                  ),
                  onTap: () {
                    DateTime notificationDate = DateTime.parse(notification.modifyDate);
                    DateTime tenDaysAgo = DateTime.now().subtract(Duration(days: 10));

                    if(notification.title == "문의답변 완료")
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CenterPage())
                      );
                    if(notification.title == "업데이트" && notificationDate.isAfter(tenDaysAgo))
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DetailPage(regday: notification.modifyDate.toString().substring(0, 10)))
                      );
                  },
                );
              },
            ),
            );
          }
        },
      ),
    );
  }
}