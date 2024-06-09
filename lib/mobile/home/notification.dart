import 'package:flutter/material.dart';
import 'package:flutter_splim/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_splim/mobile/mypage/customerCenter/question.dart';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/secure_storage/secure_service.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/dto/NotificationListDTO.dart';

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
      ),
      body: FutureBuilder<List<NotificationListDTO>>(
        future: notificationList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                NotificationListDTO notification = snapshot.data![index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                  trailing: Text(notification.modifyDate.toString().substring(5, 19).replaceAll("T", " ")),
                );
              },
            );
          }
        },
      ),
    );
  }
}